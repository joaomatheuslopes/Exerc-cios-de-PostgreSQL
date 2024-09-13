DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

drop table if exists joao_e_lucas.cliente;
create table joao_e_lucas.cliente(
                        id int primary key,
                        nome varchar not null
);

drop table if exists joao_e_lucas.conta_corrente;
create table joao_e_lucas.conta_corrente(
                               id int primary key,
                               abertura timestamp not null,
                               encerramento timestamp
);

drop table if exists joao_e_lucas.correntista;
create table joao_e_lucas.correntista(
                            cliente int references
                                cliente(id),
                            conta_corrente int references
                                conta_corrente(id),
                            primary key(cliente,
                                        conta_corrente)
);

drop table if exists joao_e_lucas.limite_credito;
create table joao_e_lucas.limite_credito(
                               conta_corrente int references
                                   conta_corrente(id),
                               valor float not null,
                               inicio timestamp not null,
                               fim timestamp
);

drop table if exists joao_e_lucas.movimento;
create table joao_e_lucas.movimento(
                          conta_corrente int references
                              conta_corrente(id),
                          "data" timestamp,
                          valor float not null,
                          primary key (conta_corrente,"data")
);


DROP TABLE IF EXISTS temp_contas_verificar;
CREATE TEMP TABLE temp_contas_verificar (
    conta_corrente int primary key
);

DROP FUNCTION IF EXISTS joao_e_lucas.calcular_saldo(conta int, dia date) CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.calcular_saldo(conta int, dia date)
    RETURNS FLOAT AS $$
DECLARE
    saldo float;
BEGIN
    SELECT sum(valor) INTO saldo
    FROM movimento
    WHERE conta_corrente = conta AND DATE("data") = dia;

    IF saldo IS NULL THEN
        saldo := 0;
    END IF;

    RETURN saldo;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS joao_e_lucas.verificar_limite(conta int, dia date) CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.verificar_limite(conta int, dia date)
    RETURNS VOID AS $$
DECLARE
    limite float;
    saldo float;
BEGIN
    saldo := calcular_saldo(conta, dia);

    SELECT valor INTO limite
    FROM limite_credito
    WHERE conta_corrente = conta
      AND inicio <= dia
      AND (fim IS NULL OR fim >= dia)
    ORDER BY inicio DESC
    LIMIT 1;

    IF saldo < -limite THEN
        RAISE EXCEPTION 'O saldo da conta % no dia % é % e excede o limite de crédito de %', conta, dia, saldo, limite;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS joao_e_lucas.registra_conta() CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.registra_conta()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO temp_contas_verificar (conta_corrente)
    VALUES (NEW.conta_corrente);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS joao_e_lucas.verifica_limite() CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.verifica_limite()
    RETURNS TRIGGER AS $$
DECLARE
    conta int;
    dia date;
BEGIN
    FOR conta IN (SELECT conta_corrente FROM temp_contas_verificar) LOOP
            FOR dia IN (SELECT DISTINCT DATE("data") FROM movimento WHERE conta_corrente = conta) LOOP
                    PERFORM verificar_limite(conta, dia);
                END LOOP ;
        END LOOP ;

    TRUNCATE TABLE temp_contas_verificar;

    RETURN new;
END ;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_registra_conta
    AFTER INSERT OR UPDATE ON movimento
    FOR EACH ROW
EXECUTE FUNCTION joao_e_lucas.registra_conta();

CREATE TRIGGER trigger_verifica_conta
    AFTER INSERT OR UPDATE ON movimento
    FOR EACH ROW
EXECUTE FUNCTION joao_e_lucas.verifica_limite();

INSERT INTO joao_e_lucas.cliente (id, nome) VALUES (1, 'Joao'), (2, 'Lucas');

INSERT INTO joao_e_lucas.conta_corrente (id, abertura) VALUES (1, '2023-01-01'), (2, '2023-01-02');

INSERT INTO joao_e_lucas.correntista (cliente, conta_corrente) VALUES (1, 1), (2, 2);

INSERT INTO joao_e_lucas.limite_credito (conta_corrente, valor, inicio, fim) VALUES
                                                                                 (1, 500, '2023-01-01', NULL),
                                                                                 (2, 1000, '2023-01-02', NULL);

INSERT INTO joao_e_lucas.movimento (conta_corrente, "data", valor) VALUES
                                                                       (1, '2023-01-01 10:00:00', 100),
                                                                       (1, '2023-01-01 12:00:00', -200),
                                                                       (1, '2023-01-01 14:00:00', 1000),
                                                                       (2, '2023-01-02 10:00:00', 300);

UPDATE joao_e_lucas.movimento
SET valor = 200
WHERE conta_corrente = 1 AND "data" = '2023-01-01 10:00:00';

INSERT INTO joao_e_lucas.movimento (conta_corrente, "data", valor) VALUES
    (1, '2023-01-02 10:00:00', 100);

INSERT INTO joao_e_lucas.movimento (conta_corrente, "data", valor) VALUES
    (1, '2023-01-02 12:00:00', -700);
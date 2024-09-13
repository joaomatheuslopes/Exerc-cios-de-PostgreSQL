DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

DROP TABLE IF EXISTS joao_e_lucas.hotel;
CREATE TABLE joao_e_lucas.hotel (
                       numero integer NOT NULL,
                       nome TEXT NOT NULL,
                       CONSTRAINT hotel_pk PRIMARY KEY (numero)
);

DROP TABLE IF EXISTS joao_e_lucas.reserva;
CREATE TABLE joao_e_lucas.reserva (
                         numero integer NOT NULL,
                         hotel integer NOT NULL,
                         cpf_cnpj integer NOT NULL,
                         inicio timestamp not null,
                         fim timestamp not null,
                         CONSTRAINT reserva_pk PRIMARY KEY
                             (numero),
                         CONSTRAINT reserva_hotel_fk FOREIGN KEY
                             (hotel) REFERENCES hotel (numero)
);

DROP TABLE IF EXISTS joao_e_lucas.estadia;
CREATE TABLE joao_e_lucas.estadia (
                         numero integer NOT NULL,
                         quarto text not null,
                         inicio timestamp not null,
                         fim timestamp,
                         CONSTRAINT estadia_pk PRIMARY KEY (numero),
                         CONSTRAINT estadia_reserva_fk FOREIGN KEY
                             (numero)
                             REFERENCES reserva (numero) ON DELETE
                                 RESTRICT ON UPDATE CASCADE
);

DROP FUNCTION IF EXISTS joao_e_lucas.check_estadia() CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.check_estadia()
    RETURNS TRIGGER AS $check_estadia$
DECLARE
    inicio_r TIMESTAMP;
    fim_r TIMESTAMP;
BEGIN

    SELECT inicio, fim INTO inicio_r, fim_r
    FROM reserva
    WHERE numero = NEW.numero;


    IF NEW.inicio IS NOT NULL and NEW.inicio < inicio_r OR NEW.inicio >= inicio_r + $$1 day$$::INTERVAL THEN
        RAISE EXCEPTION 'A estadia não está começando no período de reserva';
    END IF;


    IF NEW.fim IS NOT NULL AND NEW.fim > fim_r THEN
        RAISE EXCEPTION 'A estadia está acabando fora do fim de reserva';
    END IF;

    RETURN NEW;
END;
$check_estadia$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_check_estadia
    BEFORE INSERT OR UPDATE ON joao_e_lucas.estadia
    FOR EACH ROW
EXECUTE FUNCTION joao_e_lucas.check_estadia();

DROP FUNCTION IF EXISTS joao_e_lucas.check_reserva() CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.check_reserva()
    RETURNS TRIGGER AS $check_reserva$
BEGIN

    IF NEW.fim IS NOT NULL and NEW.inicio IS NOT NULL and NEW.fim < NEW.inicio THEN
        RAISE EXCEPTION 'A data final da reserva não está igual ou posterior a data de início';
    END IF;

    RETURN NEW;
END;
$check_reserva$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_reserva
    BEFORE INSERT OR UPDATE ON joao_e_lucas.reserva
    FOR EACH ROW
EXECUTE FUNCTION joao_e_lucas.check_reserva();

INSERT INTO joao_e_lucas.hotel (numero, nome) VALUES (1, 'Hotel Teste');
INSERT INTO joao_e_lucas.reserva (numero, hotel, cpf_cnpj, inicio, fim) VALUES (1, 1, 123, '2024-06-01 14:00:00', '2024-06-10 12:00:00');
INSERT INTO joao_e_lucas.estadia (numero, quarto, inicio, fim) VALUES (1, '101', '2024-06-01 15:00:00', '2024-06-05 11:00:00');
INSERT INTO joao_e_lucas.reserva (numero, hotel, cpf_cnpj, inicio, fim) VALUES (2, 1, 123, '2024-06-10 14:00:00', '2024-06-01 12:00:00');
INSERT INTO joao_e_lucas.estadia (numero, quarto, inicio, fim) VALUES (1, '101', '2024-06-02 15:00:00', '2024-06-05 11:00:00');
INSERT INTO joao_e_lucas.estadia (numero, quarto, inicio, fim) VALUES (1, '101', '2024-06-01 15:00:00', '2024-06-11 11:00:00');
DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

DROP TABLE IF EXISTS joao_e_lucas.tabela;

CREATE TABLE IF NOT EXISTS joao_e_lucas.tabela(
    numero INTEGER
);

CREATE OR REPLACE FUNCTION joao_e_lucas.criar_tabela(N INTEGER) RETURNS VOID AS $$
DECLARE
BEGIN
FOR i IN 1..N LOOP
        INSERT INTO joao_e_lucas.tabela(numero) VALUES (FLOOR(RANDOM()*100));
END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION joao_e_lucas.histograma() RETURNS TABLE(numero INTEGER, freq_rel FLOAT) AS $$
DECLARE
total_num INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_num FROM joao_e_lucas.tabela;
    RETURN QUERY
    SELECT joao_e_lucas.tabela.numero, COUNT(joao_e_lucas.tabela.numero)::FLOAT/total_num AS freq_rel
    FROM joao_e_lucas.tabela
    GROUP BY joao_e_lucas.tabela.numero
    ORDER BY joao_e_lucas.tabela.numero;
END;
$$ LANGUAGE plpgsql;


SELECT joao_e_lucas.criar_tabela(1000);
SELECT * FROM joao_e_lucas.tabela;
SELECT * FROM joao_e_lucas.histograma();

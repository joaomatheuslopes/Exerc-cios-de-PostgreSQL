DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

drop table if exists joao_e_lucas.campeonato cascade;
CREATE TABLE joao_e_lucas.campeonato (
    codigo text NOT NULL,
    nome TEXT NOT NULL,
    ano integer not null,
    CONSTRAINT campeonato_pk PRIMARY KEY (codigo));

drop table if exists joao_e_lucas.time_ cascade;
CREATE TABLE joao_e_lucas.time_ (
    sigla text NOT NULL,
    nome TEXT NOT NULL,
    CONSTRAINT time_pk PRIMARY KEY (sigla));

drop table if exists joao_e_lucas.jogo cascade;
CREATE TABLE joao_e_lucas.jogo (
    campeonato text not null,
    numero integer NOT NULL,
    time1 text NOT NULL,
    time2 text NOT NULL,
    gols1 integer not null,
    gols2 integer not null,
    data_ date not null,
    CONSTRAINT jogo_pk PRIMARY KEY (campeonato,numero),
    CONSTRAINT jogo_campeonato_fk FOREIGN KEY (campeonato) REFERENCES joao_e_lucas.campeonato (codigo),
    CONSTRAINT jogo_time_fk1 FOREIGN KEY (time1) REFERENCES joao_e_lucas.time_ (sigla),
    CONSTRAINT jogo_time_fk2 FOREIGN KEY (time2) REFERENCES joao_e_lucas.time_ (sigla));

drop table if exists joao_e_lucas.tabela_nova cascade;
CREATE Table joao_e_lucas.tabela_nova(
    sigla text,
    pontos integer,
    vitorias integer
);

INSERT INTO joao_e_lucas.campeonato (codigo, nome, ano)
VALUES
    ('CDB', 'Copa do Brasil', 2024),
    ('BRA', 'Brasileirão', 2024),
    ('CAR', 'Carioca', 2024);

INSERT INTO joao_e_lucas.time_ (sigla, nome)
VALUES
    ('FLA', 'Flamengo'),
    ('VAS', 'Vasco da Gama'),
    ('FLU', 'Fluminense'),
    ('BOT', 'Botafogo'),
    ('PAL', 'Palmeiras'),
    ('COR', 'Corinthians'),
    ('SAO', 'São Paulo'),
    ('SAN', 'Santos'),
    ('GRE', 'Grêmio'),
    ('INT', 'Internacional');

INSERT INTO joao_e_lucas.jogo (campeonato, numero, time1, time2, gols1, gols2, data_)
VALUES
    ('CDB', 1, 'FLA', 'VAS', 2, 1, '2024-04-01'),
    ('CDB', 2, 'FLU', 'BOT', 3, 0, '2024-04-01'),
    ('CDB', 3, 'PAL', 'COR', 1, 1, '2024-04-02'),
    ('CDB', 4, 'SAO', 'SAN', 0, 2, '2024-04-02'),
    ('CDB', 5, 'GRE', 'INT', 2, 1, '2024-04-03'),
    ('CDB', 6, 'FLA', 'FLU', 1, 1, '2024-04-03'),
    ('CDB', 7, 'VAS', 'BOT', 3, 0, '2024-04-04'),
    ('CDB', 8, 'PAL', 'SAO', 2, 1, '2024-04-04'),
    ('CDB', 9, 'FLA', 'BOT', 2, 0, '2024-04-05'),
    ('CDB', 10, 'FLU', 'VAS', 1, 2, '2024-04-05');

INSERT INTO joao_e_lucas.jogo (campeonato, numero, time1, time2, gols1, gols2, data_)
VALUES
    ('BRA', 1, 'FLA', 'VAS', 2, 1, '2024-04-01'),
    ('BRA', 2, 'FLU', 'BOT', 3, 0, '2024-04-01'),
    ('BRA', 3, 'PAL', 'COR', 1, 1, '2024-04-02'),
    ('BRA', 4, 'SAO', 'SAN', 0, 2, '2024-04-02'),
    ('BRA', 5, 'GRE', 'INT', 2, 1, '2024-04-03'),
    ('BRA', 6, 'FLA', 'FLU', 1, 1, '2024-04-03'),
    ('BRA', 7, 'VAS', 'BOT', 3, 0, '2024-04-04'),
    ('BRA', 8, 'PAL', 'SAO', 2, 1, '2024-04-04'),
    ('BRA', 9, 'FLA', 'BOT', 2, 0, '2024-04-05'),
    ('BRA', 10, 'FLU', 'VAS', 1, 2, '2024-04-05');

INSERT INTO joao_e_lucas.jogo (campeonato, numero, time1, time2, gols1, gols2, data_)
VALUES
    ('CAR', 1, 'FLA', 'VAS', 2, 1, '2024-04-01'),
    ('CAR', 2, 'FLU', 'BOT', 3, 0, '2024-04-01'),
    ('CAR', 3, 'VAS', 'FLA', 1, 1, '2024-04-02'),
    ('CAR', 4, 'BOT', 'FLU', 2, 2, '2024-04-02'),
    ('CAR', 5, 'FLA', 'FLU', 3, 1, '2024-04-03'),
    ('CAR', 6, 'VAS', 'BOT', 2, 0, '2024-04-03'),
    ('CAR', 7, 'FLU', 'FLA', 1, 2, '2024-04-04'),
    ('CAR', 8, 'BOT', 'VAS', 0, 1, '2024-04-04'),
    ('CAR', 9, 'FLA', 'BOT', 2, 0, '2024-04-05'),
    ('CAR', 10, 'VAS', 'FLU', 1, 2, '2024-04-05');

CREATE OR REPLACE FUNCTION joao_e_lucas.classificacao_campeonato( campeonato_codigo text, posicao_inicial integer, posicao_final integer) RETURNS TABLE ( posicao integer, time_sigla text, pontos integer, vitorias integer) AS $$
BEGIN
    INSERT INTO joao_e_lucas.tabela_nova(sigla, pontos, vitorias)
    SELECT
        joao_e_lucas.jogo.time1,
        CASE
            WHEN joao_e_lucas.jogo.gols1>joao_e_lucas.jogo.gols2 THEN 3
            WHEN joao_e_lucas.jogo.gols1=joao_e_lucas.jogo.gols2 THEN 1
            ELSE 0
        END::INTEGER,
        CASE
            WHEN joao_e_lucas.jogo.gols1>joao_e_lucas.jogo.gols2 THEN 1
            ELSE 0
            END::INTEGER
    FROM joao_e_lucas.jogo
    WHERE joao_e_lucas.jogo.campeonato=campeonato_codigo

    UNION ALL

    SELECT joao_e_lucas.jogo.time2,
        CASE
            WHEN joao_e_lucas.jogo.gols2>joao_e_lucas.jogo.gols1 THEN 3
            WHEN joao_e_lucas.jogo.gols2=joao_e_lucas.jogo.gols1 THEN 1
            ELSE 0
        END::INTEGER,
        CASE
            WHEN joao_e_lucas.jogo.gols2>joao_e_lucas.jogo.gols1 THEN 1
            ELSE 0
            END::INTEGER
    FROM joao_e_lucas.jogo
    WHERE joao_e_lucas.jogo.campeonato=campeonato_codigo;
    RETURN QUERY
        SELECT
            row_number() over (ORDER BY sum(joao_e_lucas.tabela_nova.pontos) DESC, sum(joao_e_lucas.tabela_nova.vitorias) DESC)::INTEGER,
            joao_e_lucas.tabela_nova.sigla,
            sum(joao_e_lucas.tabela_nova.pontos)::INTEGER,
            sum(joao_e_lucas.tabela_nova.vitorias)::INTEGER
        FROM joao_e_lucas.tabela_nova
        GROUP BY joao_e_lucas.tabela_nova.sigla
        ORDER BY sum(joao_e_lucas.tabela_nova.pontos) DESC, sum(joao_e_lucas.tabela_nova.vitorias) DESC
        LIMIT posicao_final - posicao_inicial + 1 OFFSET posicao_inicial - 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM joao_e_lucas.classificacao_campeonato('CAR',1,3);
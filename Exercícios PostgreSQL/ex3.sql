DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

DROP TABLE IF EXISTS joao_e_lucas.cidade CASCADE;
CREATE TABLE joao_e_lucas.cidade(
                              numero INT NOT NULL PRIMARY KEY,
                              nome VARCHAR NOT NULL
);

DROP TABLE IF EXISTS joao_e_lucas.bairro CASCADE;
CREATE TABLE joao_e_lucas.bairro(
                              numero INT NOT NULL PRIMARY KEY,
                              nome VARCHAR NOT NULL,
                              cidade INT NOT NULL,
                              FOREIGN KEY (cidade) REFERENCES joao_e_lucas.cidade(numero)
);

DROP TABLE IF EXISTS joao_e_lucas.pesquisa CASCADE;
CREATE TABLE joao_e_lucas.pesquisa(
                                numero INT NOT NULL PRIMARY KEY,
                                descricao VARCHAR NOT NULL
);

DROP TABLE IF EXISTS joao_e_lucas.pergunta CASCADE;
CREATE TABLE joao_e_lucas.pergunta(
                                pesquisa INT NOT NULL,
                                numero INT NOT NULL,
                                descricao VARCHAR NOT NULL,
                                PRIMARY KEY (pesquisa, numero),
                                FOREIGN KEY (pesquisa) REFERENCES joao_e_lucas.pesquisa(numero)
);

DROP TABLE IF EXISTS joao_e_lucas.resposta CASCADE;
CREATE TABLE joao_e_lucas.resposta(
                                pesquisa INT NOT NULL,
                                pergunta INT NOT NULL,
                                numero INT NOT NULL,
                                descricao VARCHAR NOT NULL,
                                PRIMARY KEY (pesquisa, pergunta, numero),
                                FOREIGN KEY (pesquisa, pergunta)
                                    REFERENCES joao_e_lucas.pergunta(pesquisa, numero)
);

DROP TABLE IF EXISTS joao_e_lucas.entrevista CASCADE;
CREATE TABLE joao_e_lucas.entrevista(
                                  numero INT NOT NULL PRIMARY KEY,
                                  data_hora TIMESTAMP NOT NULL,
                                  bairro INT NOT NULL,
                                  FOREIGN KEY (bairro) REFERENCES joao_e_lucas.bairro(numero)
);

DROP TABLE IF EXISTS joao_e_lucas.escolha CASCADE;
CREATE TABLE joao_e_lucas.escolha(
                               entrevista INT NOT NULL,
                               pesquisa INT NOT NULL,
                               pergunta INT NOT NULL,
                               resposta INT NOT NULL,
                               PRIMARY KEY (entrevista, pesquisa, pergunta),
                               FOREIGN KEY (entrevista) REFERENCES joao_e_lucas.entrevista (numero),
                               FOREIGN KEY (pesquisa, pergunta, resposta)
                                   REFERENCES joao_e_lucas.resposta (pesquisa, pergunta, numero)
);

INSERT INTO joao_e_lucas.cidade (numero, nome) VALUES
                                                   (1, 'Niterói'),
                                                   (2, 'Rio de Janeiro'),
                                                   (3, 'São Gonçalo');
INSERT INTO joao_e_lucas.bairro (numero, nome, cidade) VALUES
                                                           (1, 'Icaraí', 1),
                                                           (2, 'Ilha do Governador', 2),
                                                           (3, 'Arsenal', 3);
INSERT INTO joao_e_lucas.pesquisa (numero, descricao) VALUES
                                                          (1, 'Futebol'),
                                                          (2, 'Desenho');
INSERT INTO joao_e_lucas.pergunta (pesquisa, numero, descricao) VALUES
                                                                    (1, 1, 'Qual seu time?'),
                                                                    (1, 2, 'Qual estádio preferido'),
                                                                    (1, 3, 'Quantos jogos de futebol você já foi?'),
                                                                    (1, 4, 'Qual jogador preferido?'),
                                                                    (2, 1, 'Você ainda assiste desenho?'),
                                                                    (2, 2, 'Qual seu desenho favorito'),
                                                                    (2, 3, 'Qual seu personagem favorito?'),
                                                                    (2, 4,'Você tem pijama de desenho?');
INSERT INTO joao_e_lucas.resposta (pesquisa, pergunta, numero, descricao) VALUES
                                                                              (1, 1, 1, 'Flamengo'),
                                                                              (1, 1, 2, 'Fluminense'),
                                                                              (1, 1, 3, 'Vasco'),

                                                                              (1, 2, 1, 'Maracanã'),
                                                                              (1, 2, 2, 'Engenhão'),

                                                                              (1, 3, 1, 'Menos de 10'),
                                                                              (1, 3, 2, 'Mais de 10'),

                                                                              (1, 4, 1, 'Pelé'),
                                                                              (1, 4, 2, 'Maradona'),

                                                                              (2, 1, 1, 'Sim'),
                                                                              (2, 1, 2, 'Não'),

                                                                              (2, 2, 1, 'Naruto'),
                                                                              (2, 2, 2, 'One Piece'),

                                                                              (2, 3, 1, 'Naruto'),
                                                                              (2, 3, 2, 'Luffy'),
                                                                              (2, 3, 3, 'Danzou'),

                                                                              (2, 4, 1, 'Sim'),
                                                                              (2, 4, 2, 'Não');
INSERT INTO joao_e_lucas.entrevista (numero, data_hora, bairro) VALUES
                                                                    (1, '2024-04-10 09:00:00', 1),
                                                                    (2, '2024-04-10 10:30:00', 2),
                                                                    (3, '2024-04-10 14:00:00', 3),
                                                                    (4, '2024-04-11 11:15:00', 1),
                                                                    (5, '2024-04-12 09:00:00', 2),
                                                                    (6, '2024-04-12 10:30:00', 3);

INSERT INTO joao_e_lucas.escolha (entrevista, pesquisa, pergunta, resposta) VALUES
                                                                                (1, 1, 1, 1),
                                                                                (1, 1, 2, 1),
                                                                                (1, 1, 3, 2),
                                                                                (1, 1, 4, 1),
                                                                                (2, 2, 1, 2),
                                                                                (2, 2, 2, 1),
                                                                                (2, 2, 3, 2),
                                                                                (2, 2, 4, 2),
                                                                                (3, 1, 1, 3),
                                                                                (3, 1, 2, 2),
                                                                                (3, 1, 3, 1),
                                                                                (3, 1, 4, 2),
                                                                                (4, 1, 1, 2),
                                                                                (4, 1, 2, 1),
                                                                                (4, 1, 3, 2),
                                                                                (4, 1, 4, 1),
                                                                                (5, 2, 1, 2),
                                                                                (5, 2, 2, 2),
                                                                                (5, 2, 3, 1),
                                                                                (5, 2, 4, 1),
                                                                                (6, 2, 1, 1),
                                                                                (6, 2, 2, 1),
                                                                                (6, 2, 3, 2),
                                                                                (6, 2, 4, 2);

DROP FUNCTION IF EXISTS  joao_e_lucas.resultado(p_pesquisa int, p_bairros varchar[], p_cidades varchar[]) CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.resultado(p_pesquisa int, p_bairros varchar[], p_cidades varchar[]) RETURNS TABLE(pergunta int, histograma float[]) AS $$
DECLARE
    perguntas integer[];
    i integer;
    qtdTotalRespostas integer;
    respostas integer[];
    todasRespostas integer[];
    resposta_individual integer;
BEGIN
    IF p_bairros is NULL THEN
        p_bairros:= ARRAY(SELECT joao_e_lucas.bairro.nome FROM joao_e_lucas.bairro);
    END IF;

    IF p_cidades is NULL THEN
        p_cidades:= ARRAY(SELECT joao_e_lucas.cidade.nome FROM joao_e_lucas.cidade);
    END IF;

    SELECT ARRAY(
                   SELECT joao_e_lucas.escolha.pergunta
                   FROM joao_e_lucas.escolha
                   WHERE joao_e_lucas.escolha.pesquisa = p_pesquisa
                     and joao_e_lucas.escolha.entrevista IN (SELECT joao_e_lucas.entrevista.numero
                                                             FROM joao_e_lucas.entrevista
                                                             WHERE joao_e_lucas.entrevista.bairro IN
                                                                   (SELECT joao_e_lucas.bairro.numero
                                                                    FROM joao_e_lucas.bairro
                                                                    WHERE joao_e_lucas.bairro.nome = ANY (p_bairros)
                                                                      and joao_e_lucas.bairro.cidade IN
                                                                          (SELECT joao_e_lucas.cidade.numero
                                                                           FROM joao_e_lucas.cidade
                                                                           WHERE joao_e_lucas.cidade.nome = ANY (p_cidades))))
                   GROUP BY joao_e_lucas.escolha.pergunta
           ) INTO perguntas;

    FOREACH i IN ARRAY perguntas LOOP
            SELECT ARRAY(
                           SELECT joao_e_lucas.resposta.numero
                           FROM joao_e_lucas.resposta
                           WHERE joao_e_lucas.resposta.pesquisa=p_pesquisa and joao_e_lucas.resposta.pergunta=i
                   ) INTO todasRespostas;

            SELECT count(joao_e_lucas.escolha.resposta)::int
            INTO qtdTotalRespostas
            FROM joao_e_lucas.escolha
            WHERE joao_e_lucas.escolha.pergunta=i and joao_e_lucas.escolha.pesquisa=p_pesquisa and joao_e_lucas.escolha.entrevista IN (
                SELECT joao_e_lucas.entrevista.numero
                FROM joao_e_lucas.entrevista
                WHERE joao_e_lucas.entrevista.bairro IN (
                    SELECT joao_e_lucas.bairro.numero
                    FROM joao_e_lucas.bairro
                    WHERE joao_e_lucas.bairro.nome=ANY(p_bairros) and joao_e_lucas.bairro.cidade IN (
                        SELECT joao_e_lucas.cidade.numero
                        FROM joao_e_lucas.cidade
                        WHERE joao_e_lucas.cidade.nome=ANY(p_cidades)
                    )
                )
            );

            SELECT ARRAY(
                           SELECT joao_e_lucas.escolha.resposta
                           FROM joao_e_lucas.escolha
                           WHERE joao_e_lucas.escolha.pergunta=i and joao_e_lucas.escolha.pesquisa=p_pesquisa and joao_e_lucas.escolha.entrevista IN (
                               SELECT joao_e_lucas.entrevista.numero
                               FROM joao_e_lucas.entrevista
                               WHERE joao_e_lucas.entrevista.bairro IN (
                                   SELECT joao_e_lucas.bairro.numero
                                   FROM joao_e_lucas.bairro
                                   WHERE joao_e_lucas.bairro.nome=ANY(p_bairros) and joao_e_lucas.bairro.cidade IN (
                                       SELECT joao_e_lucas.cidade.numero
                                       FROM joao_e_lucas.cidade
                                       WHERE joao_e_lucas.cidade.nome=ANY(p_cidades)
                                   )
                               )
                           )
                           group by joao_e_lucas.escolha.resposta
                   ) INTO respostas;

            FOREACH resposta_individual IN ARRAY respostas LOOP
                    todasRespostas := array_remove(todasRespostas, resposta_individual);
                END LOOP;

            CREATE TEMP TABLE tabela_auxiliar(pergunta int, resposta int, freq float);

            INSERT INTO tabela_auxiliar(pergunta, resposta, freq)
            SELECT joao_e_lucas.escolha.pergunta, joao_e_lucas.escolha.resposta::int, COALESCE(count(joao_e_lucas.escolha.resposta)::float / qtdTotalRespostas,0)
            FROM joao_e_lucas.escolha
            WHERE joao_e_lucas.escolha.pergunta = i
              and joao_e_lucas.escolha.pesquisa = p_pesquisa
              and joao_e_lucas.escolha.entrevista IN (SELECT joao_e_lucas.entrevista.numero
                                                      FROM joao_e_lucas.entrevista
                                                      WHERE joao_e_lucas.entrevista.bairro IN
                                                            (SELECT joao_e_lucas.bairro.numero
                                                             FROM joao_e_lucas.bairro
                                                             WHERE joao_e_lucas.bairro.nome = ANY (p_bairros)
                                                               and joao_e_lucas.bairro.cidade IN
                                                                   (SELECT joao_e_lucas.cidade.numero
                                                                    FROM joao_e_lucas.cidade
                                                                    WHERE joao_e_lucas.cidade.nome = ANY (p_cidades))))
            GROUP BY joao_e_lucas.escolha.pergunta, joao_e_lucas.escolha.resposta;

            FOREACH resposta_individual IN ARRAY todasRespostas LOOP
                    INSERT INTO tabela_auxiliar(pergunta, resposta, freq) values (i, resposta_individual,0);
                END LOOP;

            RETURN QUERY SELECT tabela_auxiliar.pergunta, ARRAY_AGG(ARRAY[tabela_auxiliar.resposta, tabela_auxiliar.freq] ORDER BY tabela_auxiliar.resposta)  FROM tabela_auxiliar GROUP BY tabela_auxiliar.pergunta;

            DROP TABLE IF EXISTS tabela_auxiliar;
        END LOOP;

END;
$$ LANGUAGE plpgsql;

select * from joao_e_lucas.resultado(1,ARRAY['Icaraí'],ARRAY ['Niterói','Rio de Janeiro']);
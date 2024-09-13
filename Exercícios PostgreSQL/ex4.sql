DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

drop table if exists joao_e_lucas.venda cascade;
create table joao_e_lucas.venda(
                      ano_mes int not null,
                      unidade int not null,
                      vendedor int not null,
                      produto int not null,
                      valor float not null
);


INSERT INTO joao_e_lucas.venda (ano_mes, unidade, vendedor, produto, valor) VALUES
                                                                   (202101, 1, 101, 1, 1500.00),
                                                                   (202102, 2, 102, 1, 2000.00),
                                                                   (202103, 3, 103, 1, 1800.00),
                                                                   (202104, 1, 101, 1, 2200.00),
                                                                   (202105, 2, 102, 1, 2500.00),
                                                                   (202106, 3, 103, 1, 2700.00),
                                                                   (202107, 1, 101, 1, 3000.00),
                                                                   (202108, 2, 102, 1, 3200.00),
                                                                   (202109, 3, 103, 1, 3400.00);

DROP FUNCTION IF EXISTS joao_e_lucas.transposta(matriz int[][]);
CREATE OR REPLACE FUNCTION transposta(matriz int[][]) RETURNS int[][] AS $$
DECLARE
    qtdLinhas int := array_length(matriz, 1);
    qtdColunas int := array_length(matriz, 2);
    resultante int[][] := array_fill(0, ARRAY[qtdColunas, qtdLinhas]);
BEGIN
    FOR i IN 1..qtdLinhas LOOP
            FOR j IN 1..qtdColunas LOOP
                    resultante[j][i] := matriz[i][j];
                END LOOP;
        END LOOP;

    RETURN resultante;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS joao_e_lucas.projecao(p_produto INT, p_ano_mes INT);
CREATE OR REPLACE FUNCTION projecao(p_produto INT, p_ano_mes INT) RETURNS float AS $$
    DECLARE
        dataMin int;
        contador int:=0;
        x int[][];
        xt int[][];
        xtx float[][];
        xtxInversa float[][];
        xtr float[][];
        r float[][];
        sistemaLinear float[];
        determinante float;
        M float;
        x1 float;
        x2 float;
    BEGIN
        --criando tabela REF
        select min(ano_mes) into dataMin from joao_e_lucas.venda where produto = p_produto;

        create temp table REF(ano_mes integer, seq integer);

        for i in dataMin..p_ano_mes LOOP
                insert into REF values(dataMin,contador);
                contador:=contador+1;
                dataMin:=dataMin+1;
            end loop;

        --criando matriz x
        with
            t1 as (select ano_mes, sum(venda.valor) as valor
                         from joao_e_lucas.venda
                         where produto = p_produto
                         group by ano_mes),
            t2 as (select ano_mes, 1 as c2
                   from t1),
            ref as (select * from REF) select array_agg(array[seq,1]) into x from t2 natural join ref;

        raise notice 'x %',x;

        --criando transposta xt
        xt:=joao_e_lucas.transposta(x);

        raise notice 'xt %',xt;

        --criando matriz r
        with
            t1 as (select ano_mes, sum(venda.valor) as valor
                   from joao_e_lucas.venda
                   where produto = p_produto
                   group by ano_mes) select array_agg(array[valor]) into r from t1;

        raise notice 'r %',r;

        --calculando sistema linear
        -- multiplicando xt*x
        xtx := array_fill(0, ARRAY[array_length(xt, 2), array_length(x, 2)]);
        FOR i IN 1..array_length(xt, 1) LOOP
                FOR j IN 1..array_length(x, 2) LOOP
                        FOR k IN 1..array_length(x, 1) LOOP
                                xtx[i][j] := xtx[i][j] + xt[i][k] * x[k][j];
                            END LOOP;
                    END LOOP;
            END LOOP;
        raise notice 'xtx %',xtx;

        -- multiplicando xt*r
        xtr := array_fill(0, ARRAY[array_length(xt, 2), array_length(r, 2)]);
        FOR i IN 1..array_length(xt, 1) LOOP
                FOR j IN 1..array_length(r, 2) LOOP
                        FOR k IN 1..array_length(r, 1) LOOP
                                xtr[i][j] := xtr[i][j] + xt[i][k] * r[k][j];
                            END LOOP;
                    END LOOP;
            END LOOP;
        raise notice 'xtr %',xtr;

        -- achando a inversa de xt*x
        determinante := xtx[1][1] * xtx[2][2] - xtx[1][2] * xtx[2][1];
        xtxInversa := array[
            array[xtx[2][2] / determinante, -xtx[1][2] / determinante],
            array[-xtx[2][1] / determinante, xtx[1][1] / determinante]
            ];

        raise notice 'xtrInversa %',xtxInversa;

        --resolvendo sistema multiplicando a inversa de xt*x com xt*r
        sistemaLinear := array_fill(0, ARRAY[array_length(xtxInversa, 1), array_length(xtr, 2)]);
        FOR i IN 1..array_length(xtxInversa, 1) LOOP
                FOR j IN 1..array_length(xtr, 2) LOOP
                        FOR k IN 1..array_length(xtxInversa, 2) LOOP
                                sistemaLinear[i][j] := sistemaLinear[i][j] + xtxInversa[i][k] * xtr[k][j];
                            END LOOP;
                    END LOOP;
            END LOOP;

        raise notice 'x1 %', sistemaLinear[1][1];
        raise notice 'x2 %', sistemaLinear[2][1];

        select seq into M from REF where ano_mes=p_ano_mes;
        x1:=sistemaLinear[1][1];
        x2:=sistemaLinear[2][1];
        drop table if exists REF;

        --calculando projeção
        return  M * x1 + x2;
    END;
$$ LANGUAGE plpgsql;


SELECT joao_e_lucas.projecao(1, 202110);
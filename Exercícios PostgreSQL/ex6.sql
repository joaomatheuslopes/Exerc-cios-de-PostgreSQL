DROP SCHEMA IF EXISTS joao_e_lucas CASCADE;
CREATE SCHEMA joao_e_lucas;

DROP TABLE IF EXISTS joao_e_lucas.restaurante;
CREATE TABLE joao_e_lucas.restaurante (
                             cnpj integer NOT NULL,
                             endereco character varying NOT NULL,
                             CONSTRAINT rest_pk PRIMARY KEY (cnpj));

DROP TABLE IF EXISTS joao_e_lucas.prato;
CREATE TABLE joao_e_lucas.prato (
                       prato_id integer NOT NULL,
                       nome character varying NOT NULL,
                       CONSTRAINT prato_pk PRIMARY KEY
                           (prato_id));

DROP TABLE IF EXISTS joao_e_lucas.menu;
CREATE TABLE joao_e_lucas.menu (
                      cnpj integer NOT NULL,
                      prato_id integer NOT NULL,
                      preco real NOT NULL,
                      CONSTRAINT menu_pk PRIMARY KEY
                          (cnpj,prato_id),
                      CONSTRAINT menu_rest_fk FOREIGN KEY
                          (cnpj) REFERENCES restaurante (cnpj),
                      CONSTRAINT menu_prato_fk FOREIGN KEY
                          (prato_id) REFERENCES prato (prato_id));

DROP TABLE IF EXISTS joao_e_lucas.pedido;
CREATE TABLE joao_e_lucas.pedido (
                        pedido_id integer NOT NULL,
                        cnpj integer NOT NULL,
                        CONSTRAINT pedido_pk PRIMARY KEY
                            (pedido_id),
                        CONSTRAINT pedido_rest_fk FOREIGN KEY
                            (cnpj) REFERENCES restaurante (cnpj));

DROP TABLE IF EXISTS joao_e_lucas.item_pedido;
CREATE TABLE joao_e_lucas.item_pedido (
                             pedido_id integer NOT NULL,
                             item integer NOT NULL,
                             cnpj integer NOT NULL,
                             prato_id integer NOT NULL,
                             qtd integer NOT NULL,
                             CONSTRAINT item_pk PRIMARY KEY
                                 (pedido_id,item),
                             CONSTRAINT item_pedido_fk FOREIGN KEY
                                 (pedido_id) REFERENCES pedido
                                     (pedido_id),
                             CONSTRAINT item_menu_fk FOREIGN KEY
                                 (cnpj,prato_id) REFERENCES menu
                                     (cnpj,prato_id));

DROP FUNCTION IF EXISTS joao_e_lucas.check_cnpj_item() CASCADE;
CREATE OR REPLACE FUNCTION joao_e_lucas.check_cnpj_item()
    RETURNS TRIGGER AS $check_cnpj_item$
DECLARE
    cnpj_pedido integer;
BEGIN

    SELECT cnpj INTO cnpj_pedido
    FROM joao_e_lucas.pedido
    WHERE pedido_id = NEW.pedido_id;

    IF NEW.cnpj != cnpj_pedido THEN
        RAISE EXCEPTION 'O cnpj do item deve ter o mesmo cnpj do pedido a qual pertence';
    END IF;

    RETURN NEW;
END;
$check_cnpj_item$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_unicidade_cpf
    BEFORE INSERT OR UPDATE ON item_pedido
    FOR EACH ROW EXECUTE FUNCTION joao_e_lucas.check_cnpj_item();


INSERT INTO restaurante values (123, 'rua 1');
INSERT INTO restaurante values (124, 'rua 2');
INSERT INTO prato values (1, 'comida');
INSERT INTO menu values (123, 1, 1);
INSERT INTO menu values (124, 1, 1);
INSERT INTO pedido values (1, 123);
INSERT INTO item_pedido values (1, 1, 123, 1, 5);
INSERT INTO item_pedido values (1, 2, 124, 1, 5);
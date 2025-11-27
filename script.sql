/*-------------------------------------------------------------------------------------------------
CRIAÇÃO
-------------------------------------------------------------------------------------------------*/

CREATE TABLE estado (
    codigo INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    CONSTRAINT pk_estado PRIMARY KEY(codigo)
);

CREATE TABLE municipio (
    geocodigo INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    codigo_estado INTEGER NOT NULL,
    CONSTRAINT fk_municipio FOREIGN KEY (codigo_estado) REFERENCES estado(codigo),
    CONSTRAINT pk_municipio PRIMARY KEY(geocodigo) 
);

CREATE TABLE bioma (
    codigo INTEGER NOT NULL,
    nome varchar(100) NOT NULL,
    clima varchar(100) NOT NULL,
    relevo varchar(100) NOT NULL,
    CONSTRAINT pk_bioma PRIMARY KEY(codigo)
);

CREATE TABLE municipio_bioma (
    cod_municipio INTEGER NOT NULL,
    cod_bioma INTEGER NOT NULL,
    CONSTRAINT pk_municipio_bioma PRIMARY KEY(cod_municipio,cod_bioma),
    CONSTRAINT fk_municipio FOREIGN KEY(cod_municipio) REFERENCES municipio(geocodigo),
    CONSTRAINT fk_bioma FOREIGN KEY(cod_bioma) REFERENCES bioma(codigo)
);

CREATE TABLE setor_emissor (
    codigo INTEGER NOT NULL,
    nome VARCHAR(50) NOT NULL,
	CONSTRAINT pk_setor_emissor PRIMARY KEY(codigo)
);

CREATE TABLE categoria_emissora (
    codigo INTEGER NOT NULL,
    nome VARCHAR(100),
    codigo_setor_emissor INTEGER NOT NULL,
	CONSTRAINT pk_categoria_emissora PRIMARY KEY(codigo),
    CONSTRAINT fk_categoria_emissora FOREIGN KEY(codigo_setor_emissor) REFERENCES setor_emissor(codigo)
);

CREATE TABLE categoria_subcategoria (
    cod_categoria INTEGER NOT NULL,
    cod_subcategoria INTEGER NOT NULL,
    CONSTRAINT pk_categoria_subcategoria PRIMARY KEY (cod_categoria, cod_subcategoria),
    CONSTRAINT fk_categoria FOREIGN KEY (cod_categoria) REFERENCES categoria_emissora(codigo),
    CONSTRAINT fk_subcategoria FOREIGN KEY (cod_subcategoria) REFERENCES categoria_emissora(codigo)
);

CREATE TABLE atividade_geral (
    codigo INTEGER NOT NULL,
    nome VARCHAR(100),
    codigo_setor_emissor INTEGER NOT NULL,
	CONSTRAINT pk_atividade_geral PRIMARY KEY(codigo),
    CONSTRAINT fk_atividade_geral FOREIGN KEY(codigo_setor_emissor) REFERENCES setor_emissor(codigo)
);

CREATE TABLE produto(
    codigo INTEGER NOT NULL,
    nome VARCHAR(100),
    cod_atividade_geral INTEGER NOT NULL,
    CONSTRAINT pk_produto PRIMARY KEY(codigo),
    CONSTRAINT fk_produto FOREIGN KEY(cod_atividade_geral) REFERENCES atividade_geral(codigo)
);


CREATE TABLE fluxo_gas_efeito_estufa (
    codigo INTEGER NOT NULL,
    tipo VARCHAR(10) NOT NULL, -- emissão, remoção ou bunker
    codigo_setor_emissor INTEGER NOT NULL,
    codigo_municipio INTEGER NOT NULL,
    codigo_bioma INTEGER NOT NULL,
	CONSTRAINT pk_fluxo_gas PRIMARY KEY(codigo),
    CONSTRAINT fk_setor_emissor FOREIGN KEY(codigo_setor_emissor) REFERENCES setor_emissor(codigo),
    CONSTRAINT fK_municipio_bioma FOREIGN KEY (codigo_municipio, codigo_bioma) REFERENCES municipio_bioma (cod_municipio, cod_bioma)
);

CREATE TABLE gas_efeito_estufa(
    codigo INTEGER NOT NULL,
    nome varchar(100) NOT NULL,
    formula varchar(20) NOT NULL,
    CONSTRAINT pk_gas_efeito_estufa PRIMARY KEY(codigo)
);

CREATE TABLE historico_emissao(
    codigo INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    total_fluxo DOUBLE PRECISION NOT NULL,
	CONSTRAINT pk_historico PRIMARY KEY(codigo)
);

CREATE TABLE gas_fluxo(
    cod_historico_emissao INTEGER NOT NULL,
    cod_fluxo_gas INTEGER NOT NULL,
    cod_gas INTEGER NOT NULL,
    CONSTRAINT pk_gas_fluxo PRIMARY KEY(cod_historico_emissao,cod_fluxo_gas,cod_gas),
    CONSTRAINT fk_historico_emissao FOREIGN KEY(cod_historico_emissao) REFERENCES historico_emissao(codigo),
    CONSTRAINT fk_fluxo_gas FOREIGN KEY(cod_fluxo_gas) REFERENCES fluxo_gas_efeito_estufa(codigo),
    CONSTRAINT fk_gas FOREIGN KEY(cod_gas) REFERENCES gas_efeito_estufa(codigo)
);

/*-------------------------------------------------------------------------------------------------
INSERÇÃO
-------------------------------------------------------------------------------------------------*/
--códigos do IBGE para as UFs
INSERT INTO estado (codigo, nome)
VALUES 
    (29, 'Bahia'),
    (43, 'Rio Grande do Sul'),
    (51, 'Mato Grosso'),
    (31, 'Minas Gerais'),
    (22, 'Piauí');


INSERT INTO bioma (codigo, nome, clima, relevo)
VALUES
    (1, 'Amazônia', 'Equatorial úmido', 'Planícies, depressões e planaltos baixos'),
    (2, 'Cerrado', 'Tropical sazonal', 'Planaltos e chapadas'),
    (3, 'Caatinga', 'Semiárido', 'Planaltos e depressões intermontanas'),
    (4, 'Mata Atlântica', 'Tropical úmido', 'Serras e planaltos costeiros'),
    (5, 'Pampa', 'Subtropical', 'Planalto, coxilhas e áreas suavemente onduladas'),
    (6, 'Pantanal', 'Tropical com inundações sazonais', 'Planície alagável');


INSERT INTO gas_efeito_estufa (codigo, nome, formula)
VALUES
    (1, 'Metano', 'CH4'),
    (2, 'Óxido Nitroso', 'N2O'),
    (3, 'Dióxido de Carbono', 'CO2'),
    (4, 'Monóxido de Carbono', 'CO'),
    (5, 'Compostos Orgânicos Voláteis não Metânicos', 'COVNM');


--id do território
INSERT INTO municipio (geocodigo, nome, codigo_estado)
VALUES
    (12901908, 'Aporá', 29),
    (14311205, 'Júlio de Castilhos', 43),
    (15106307, 'Paranatinga', 51),
    (13141009, 'Mato Verde', 31);


INSERT INTO municipio_bioma (cod_municipio, cod_bioma)
VALUES 
    (12901908, 3),
    (12901908, 4),
    (14311205, 5),
    (15106307, 2),
    (13141009, 3);

INSERT INTO setor_emissor (codigo, nome)
VALUES
    (1, 'Agropecuária'),
    (2, 'Energia'),
    (3, 'Mudança de Uso da Terra e Floresta'),
    (4, 'Processos Industriais'),
    (5, 'Resíduos');

INSERT INTO categoria_emissora (codigo, nome, codigo_setor_emissor)
VALUES
    (1, 'Cultivo de arroz', 1),
    (2, 'Cultivo em sistema irrigado inundado', 1),
    (3, 'Fermentação entérica', 1),
    (4, 'Processo de digestão de animais ruminantes', 1),
    (5, 'Transportes', 2),
    (6, 'Rodoviário', 2),
    (7, 'Remoção por mudança de uso da terra', 3),
    (8, 'Outras mudanças de uso da terra', 3),
    (9, 'Solos Manejados', 1),
    (10, 'Deposição de dejetos em pastagem', 1);

INSERT INTO categoria_subcategoria (cod_categoria, cod_subcategoria)
VALUES
    (1, 2),
    (3, 4),
    (5, 6),
    (7, 8),
    (9, 10);

INSERT INTO atividade_geral (codigo, nome, codigo_setor_emissor)
VALUES
    (1, 'Agricultura', 1),
    (2, 'Pecuária', 1),
    (3, 'Transporte de passageiros', 2);


INSERT INTO produto (codigo, nome, cod_atividade_geral)
VALUES
    (1, 'Arroz', 1),
    (2, 'Asinino', 2),
    (3, 'Diesel de petróleo', 3),
    (4, 'Área sem vegetação -- Uso agropecuário', 1),
    (5, 'Gado de corte', 2);


INSERT INTO fluxo_gas_efeito_estufa (codigo, tipo, codigo_setor_emissor, codigo_municipio, codigo_bioma)
VALUES 
    (1, 'Emissão', 1, 12901908, 3),
    (2, 'Emissão', 1, 12901908, 4),
    (3, 'Emissão', 2, 14311205, 5),
    (4, 'Remoção', 3, 15106307, 2),
    (5, 'Emissão', 1, 13141009, 3);

INSERT INTO historico_emissao (codigo, ano, total_fluxo)
VALUES
    (1, 1976, 91.70),
    (2, 1979, 15.02),
    (3, 2007, 27.56),
    (4, 1984, 0.0),
    (5, 1988, 80.98);

INSERT INTO gas_fluxo (cod_historico_emissao, cod_fluxo_gas, cod_gas)
VALUES 
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 4),
    (4, 4, 3),
    (5, 5, 2);



/*-------------------------------------------------------------------------------------------------
Alterações para parte 2 do trabalho
-------------------------------------------------------------------------------------------------*/

/*Tabela auxiliar para conversões*/
CREATE TABLE gwp_ar6(
	codigo INTEGER,
 	gwp100 DOUBLE PRECISION NOT NULL,
	CONSTRAINT pk_gwp PRIMARY KEY(codigo)
);

--Fatores de conversão gwp
INSERT INTO gwp_ar6 (codigo, gwp100) VALUES
(1, 27.2) ,    -- CH4
(2, 273),    -- N2O
(3, 1.0);      -- CO2

INSERT INTO municipio (geocodigo, nome, codigo_estado) VALUES
    (12903501, 'Alagoinhas', 29),
    (12904509, 'Catu', 29),

    (14321009, 'Santa Maria', 43),
    (14332007, 'Bagé', 43),

    (15150502, 'Sorriso', 51),
    (15161002, 'Sinop', 51),

    (13122003, 'Montes Claros', 31),
    (13193006, 'Uberaba', 31),

    (22077009, 'Picos', 22),
    (22019001, 'Campo Maior', 22);

INSERT INTO municipio_bioma (cod_municipio, cod_bioma) VALUES
    (12903501, 4),
    (12904509, 4),

    (14321009, 5),
    (14332007, 5),

    (15150502, 2),
    (15161002, 2),
    (15161002, 1),

    (13122003, 3),
    (13193006, 4),

    (22077009, 3),
    (22019001, 3);

INSERT INTO fluxo_gas_efeito_estufa 
(codigo, tipo, codigo_setor_emissor, codigo_municipio, codigo_bioma)
VALUES
    (6, 'Emissão', 1, 12903501, 4),
    (7, 'Emissão', 2, 12903501, 4),
    (8, 'Emissão', 1, 12904509, 4),
    (9, 'Emissão', 3, 12904509, 4),

    (10, 'Emissão', 2, 14321009, 5),
    (11, 'Emissão', 1, 14321009, 5),
    (12, 'Remoção', 3, 14332007, 5),

    (13, 'Emissão', 1, 15150502, 2),
    (14, 'Emissão', 1, 15161002, 2),
    (15, 'Emissão', 2, 15161002, 1),

    (16, 'Emissão', 1, 13122003, 3),
    (17, 'Remoção', 3, 13122003, 3),
    (18, 'Emissão', 2, 13193006, 4),

    (19, 'Emissão', 1, 22077009, 3),
    (20, 'Emissão', 2, 22077009, 3),
    (21, 'Emissão', 1, 22019001, 3),
    (22, 'Remoção', 3, 22019001, 3);

INSERT INTO historico_emissao (codigo, ano, total_fluxo) VALUES
    (6, 1990, 12.5),
    (7, 1991, 25.3),
    (8, 2001, 18.7),
    (9, 2005, -5.2),

    (10, 2010, 55.9),
    (11, 1998, 32.1),
    (12, 2015, -40.3),

    (13, 2020, 102.6),
    (14, 2021, 110.4),
    (15, 2018, 88.2),

    (16, 2012, 24.7),
    (17, 2013, -12.9),
    (18, 2007, 75.6),

    (19, 2011, 41.3),
    (20, 2003, 63.8),
    (21, 2008, 22.4),
    (22, 2014, -18.6);

INSERT INTO gas_fluxo (cod_historico_emissao, cod_fluxo_gas, cod_gas) VALUES
    (6, 6, 1),
    (7, 7, 3),
    (8, 8, 1),
    (9, 9, 3),

    (10, 10, 3),
    (11, 11, 1),
    (12, 12, 3),

    (13, 13, 1),
    (14, 14, 1),
    (15, 15, 3),

    (16, 16, 1),
    (17, 17, 3),
    (18, 18, 3),

    (19, 19, 1),
    (20, 20, 3),
    (21, 21, 1),
    (22, 22, 3);


/*INSERÇÕES CONSULTA 5*/
INSERT INTO municipio (geocodigo, nome, codigo_estado) VALUES
	(4305108, 'Caxias do Sul', 43),
	(4309100, 'Gramado', 43),
	(4304408, 'Canela', 43),
	(4300703, 'Anta Gorda', 43);
	
INSERT INTO municipio_bioma (cod_municipio, cod_bioma) VALUES
	(4305108, 4),
	(4309100, 4),
	(4304408, 4),
	(4300703, 4);

INSERT INTO fluxo_gas_efeito_estufa (codigo, tipo, codigo_setor_emissor, codigo_municipio, codigo_bioma) VALUES
	(23, 'Emissão', 2, 4305108, 4),
	(24, 'Emissão', 2, 4309100, 4),
	(25, 'Emissão', 2, 4304408, 4),
	(26, 'Emissão', 2, 4300703, 4);

INSERT INTO historico_emissao (codigo, ano, total_fluxo) VALUES
	(23,2010,1534.29475317673),
	(24,2010,100.375439365234),
	(25,2010,86.2511319420331),
	(26,2010,26.4168727107565);

INSERT INTO gas_fluxo (cod_historico_emissao, cod_fluxo_gas, cod_gas) VALUES
	(23,23,3),
	(24,24,3),
	(25,25,3),
	(26,26,3);

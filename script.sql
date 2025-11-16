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
    (1, 1976, 0.026016826667413645),
    (2, 1979, 0.02508487076385844),
    (3, 2007, 147038259064726),
    (4, 1984, 0.0),
    (5, 1988, 1281763726969870);

INSERT INTO gas_fluxo (cod_historico_emissao, cod_fluxo_gas, cod_gas)
VALUES 
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 4),
    (4, 4, 3),
    (5, 5, 2);
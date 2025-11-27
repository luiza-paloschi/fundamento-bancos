/*
Consulta 1
*/

SELECT 
    e.nome AS estado,
    SUM(h.total_fluxo) AS total_co2e
FROM estado e
JOIN municipio m 
    ON m.codigo_estado = e.codigo
JOIN fluxo_gas_efeito_estufa f 
    ON f.codigo_municipio = m.geocodigo
JOIN gas_fluxo gf 
    ON gf.cod_fluxo_gas = f.codigo
JOIN gas_efeito_estufa g
    ON g.codigo = gf.cod_gas
JOIN historico_emissao h
    ON h.codigo = gf.cod_historico_emissao
WHERE g.codigo = 3  -- codigo CO2
GROUP BY e.nome
ORDER BY total_co2e DESC;


/*
Consulta 2
*/

SELECT 
    m.nome AS municipio,
    e.nome AS estado,
    SUM(h.total_fluxo * gwp.gwp100) AS total_co2e_ar6
FROM municipio m
JOIN estado e 
    ON e.codigo = m.codigo_estado
JOIN fluxo_gas_efeito_estufa f
    ON f.codigo_municipio = m.geocodigo
JOIN gas_fluxo gf 
    ON gf.cod_fluxo_gas = f.codigo
JOIN historico_emissao h
    ON h.codigo = gf.cod_historico_emissao
JOIN gwp_ar6 gwp
    ON gwp.codigo = gf.cod_gas
GROUP BY m.nome, e.nome
ORDER BY total_co2e_ar6 DESC
LIMIT 10;


/*
	Consulta 3
*/

SELECT
    m.nome AS municipio,
    e.nome AS estado,
    h.ano,
    h.total_fluxo AS emissao_ch4,
    (h.total_fluxo * gwp.gwp100) AS emissao_co2e_ar6
FROM municipio m
JOIN estado e 
    ON e.codigo = m.codigo_estado
JOIN fluxo_gas_efeito_estufa f
    ON f.codigo_municipio = m.geocodigo
JOIN gas_fluxo gf 
    ON gf.cod_fluxo_gas = f.codigo
JOIN historico_emissao h
    ON h.codigo = gf.cod_historico_emissao
JOIN gwp_ar6 gwp
    ON gwp.codigo = gf.cod_gas
WHERE gf.cod_gas = 1;   -- Apenas CH4


/*4) Elabore uma consulta SQL que liste a participação de cada bioma nas emissões do estado. Deve-se mostrar a contribuição de cada bioma para as emissões totais de CO2e dentro de um estado.*/

SELECT b.nome as bioma, e.nome as estado, ROUND(SUM(he.total_fluxo) :: numeric, 2) as emissao_Total_CO2
FROM bioma b
INNER JOIN municipio_bioma mb on mb.cod_bioma = b.codigo
INNER JOIN municipio m on mb.cod_municipio = m.geocodigo
INNER JOIN estado e on e.codigo = m.codigo_estado
INNER JOIN fluxo_gas_efeito_estufa fgee on fgee.codigo_bioma = b.codigo AND fgee.codigo_municipio = m.geocodigo
INNER JOIN gas_fluxo gf on gf.cod_fluxo_gas = fgee.codigo AND gf.cod_gas = 3 /*Codigo CO2*/
INNER JOIN historico_emissao he on he.codigo = gf.cod_historico_emissao
GROUP BY b.nome, e.nome;

/*5) Elabore uma consulta SQL que liste os 10 municípios de um estado com base no CO2. Deve-se ranquear os municípios de um estado com base em suas emissões de CO2e no ano de referência.*/

SELECT m.nome as municipio, ROUND(he.total_fluxo :: numeric, 2) as emissao_CO2
FROM municipio m
INNER JOIN fluxo_gas_efeito_estufa fgee on fgee.codigo_municipio = m.geocodigo
INNER JOIN gas_fluxo gf on gf.cod_fluxo_gas = fgee.codigo AND gf.cod_gas = 3
INNER JOIN historico_emissao he on he.codigo = gf.cod_historico_emissao AND he.ano = 2010
WHERE m.codigo_estado = 43
ORDER BY he.total_fluxo DESC
LIMIT 10;

/*6)  Elabore uma consulta SQL que liste a comparação entre GWP e GTP por setor no estado (AR6), as emissões de CO2e computadas por GWP e GTP no AR6, exibindo ambas lado a lado.*/

SELECT ROUND((he.total_fluxo * gwpar6.gwp100)::numeric,2) as emissoes_por_gwp, ROUND((he.total_fluxo * gwpar6.gwp100)::numeric,2) as emissoes_por_gtp, s.nome as setor, e.nome as estado
FROM setor_emissor s
INNER JOIN fluxo_gas_efeito_estufa fgee on fgee.codigo_setor_emissor = s.codigo
INNER JOIN municipio m on m.geocodigo = fgee.codigo_municipio
INNER JOIN estado e on e.codigo = m.codigo_estado
INNER JOIN gas_fluxo gf on gf.cod_fluxo_gas = fgee.codigo AND cod_gas = 3
INNER JOIN historico_emissao he on he.codigo = gf.cod_historico_emissao
INNER JOIN gwp_ar6 gwpar6 on gwpar6.codigo = 3
GROUP BY s.nome, e.nome, emissoes_por_gwp, emissoes_por_gtp;


/*
    Consulta 7
*/
-- Tabelas temporárias para organizar os dados e deixar consulta mais legível
-- Emissões por gás, setor e estado
WITH emissoes_por_gas AS (
    SELECT 
        e.nome as estado,
        se.nome as setor,
        ge.nome as gas,
        ge.formula,
        SUM(he.total_fluxo * COALESCE(gwp.gwp100, 0)) as co2e
    FROM estado e
    INNER JOIN municipio m ON e.codigo = m.codigo_estado
    INNER JOIN municipio_bioma mb ON m.geocodigo = mb.cod_municipio
    INNER JOIN fluxo_gas_efeito_estufa f ON mb.cod_municipio = f.codigo_municipio 
                                      AND mb.cod_bioma = f.codigo_bioma
    INNER JOIN gas_fluxo gf ON f.codigo = gf.cod_fluxo_gas
    INNER JOIN historico_emissao he ON gf.cod_historico_emissao = he.codigo
    INNER JOIN gas_efeito_estufa ge ON gf.cod_gas = ge.codigo
    INNER JOIN setor_emissor se ON f.codigo_setor_emissor = se.codigo
    LEFT JOIN gwp_ar6 gwp ON ge.codigo = gwp.codigo
    WHERE he.total_fluxo > 0
      AND f.tipo = 'Emissão'
    GROUP BY e.nome, se.nome, ge.nome, ge.formula
),

-- Calcula totais por setor em cada estado
totais_por_setor AS (
    SELECT 
        estado,
        setor,
        SUM(co2e) as total_setor
    FROM emissoes_por_gas
    GROUP BY estado, setor
    HAVING SUM(co2e) > 0
)

-- Resultado final a ser exibido
SELECT 
    eg.estado as "Estado",
    eg.setor as "Setor",
    eg.gas as "Gás",
    eg.formula as "Fórmula",
    ROUND(eg.co2e::numeric, 2) as "CO2e (t)",
    ROUND(((eg.co2e / ts.total_setor) * 100)::numeric, 2) as "% no Setor"
FROM emissoes_por_gas eg
INNER JOIN totais_por_setor ts ON eg.estado = ts.estado AND eg.setor = ts.setor

ORDER BY eg.estado, eg.setor, eg.co2e DESC;

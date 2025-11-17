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






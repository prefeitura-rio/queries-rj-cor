{{
    config(
        materialized='incremental',
        unique_key="primary_key",
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "month",
        },
        post_hook='CREATE OR REPLACE TABLE `rj-cor.meio_ambiente_clima_staging.taxa_precipitacao_satelite_last_partition` AS (SELECT CURRENT_DATETIME("America/Sao_Paulo") AS data_particao)'
    )
}}

SELECT
    CONCAT(data_particao, '_', CONCAT(SAFE_CAST(hora AS STRING), ":00:00"), '_', latitude, '_', longitude) AS primary_key,
    SAFE_CAST(longitude AS FLOAT64) longitude,
    SAFE_CAST(latitude AS FLOAT64) latitude,
    SAFE_CAST(rrqpe AS FLOAT64) rrqpe,
    SAFE_CAST(CONCAT(SAFE_CAST(hora AS STRING), ":00:00") AS TIME) horario,
    SAFE_CAST(DATE_TRUNC(DATE(data_particao), day) AS DATE) data_particao,
FROM `rj-cor.meio_ambiente_clima_staging.taxa_precipitacao_satelite`


{% if is_incremental() %}

{% set max_partition = run_query(
    "SELECT DATE(gr) FROM (
        SELECT IF(
            max(data_particao) > CURRENT_DATE('America/Sao_Paulo'), CURRENT_DATE('America/Sao_Paulo'), max(data_particao)
            ) as gr 
        FROM `rj-cor.meio_ambiente_clima_staging.taxa_precipitacao_satelite_last_partition`
        )
    ").columns[0].values()[0] %}

WHERE 
    ano_particao = EXTRACT(YEAR FROM CURRENT_DATE('America/Sao_Paulo')) AND
    mes_particao = EXTRACT(MONTH FROM CURRENT_DATE('America/Sao_Paulo')) AND
    data_particao > ("{{ max_partition }}")
{% endif %}

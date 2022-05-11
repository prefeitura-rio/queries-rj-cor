-- não foi testado porque depende de ter uma coluna com data_particao nos dados de satélite
{{
    config(
        materialized='incremental',
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "day",
        },
        post_hook='CREATE OR REPLACE TABLE `rj-escritorio-dev.meio_ambiente_clima_staging.quantidade_agua_precipitavel_satelite_last_partition` AS (SELECT CURRENT_DATETIME("America/Sao_Paulo") AS data_particao)'
    )
}}

SELECT 
    SAFE_CAST(longitute AS FLOAT64) longitude,
    SAFE_CAST(latitute AS FLOAT64) latitude,
    SAFE_CAST(tpw AS FLOAT64) tpw,
    SAFE_CAST(DATE_TRUNC(DATE(data), day) AS DATE) data_particao,
FROM `rj-escritorio-dev.meio_ambiente_clima_staging.quantidade_agua_precipitavel_satelite`


{% if is_incremental() %}

-- this filter will only be applied on an incremental run
WHERE 
    ano = EXTRACT(YEAR FROM CURRENT_DATE('America/Sao_Paulo')) AND
    mes = EXTRACT(MONTH FROM CURRENT_DATE('America/Sao_Paulo')) AND
    data_particao > (SELECT 
                        max(data_particao) 
                    FROM 
                        `rj-escritorio-dev.meio_ambiente_clima_staging.quantidade_agua_precipitavel_satelite_last_partition`
                    )
{% endif %}

{{
    config(
        materialized='incremental',
        unique_key="primary_key",
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "month",
        },
        post_hook='CREATE OR REPLACE TABLE `rj-cor.clima_estacao_meteorologica_staging.meteorologia_redemet_last_partition` AS (SELECT CURRENT_DATETIME("America/Sao_Paulo") AS data_particao)'
    )
}}

SELECT 
    DISTINCT
    CONCAT(id_estacao, '_', data) AS primary_key,
    id_estacao,
    SAFE_CAST(temperatura AS INT64) temperatura,
    SAFE_CAST(umidade AS INT64) umidade,
    condicoes_tempo,
    ceu,
    teto,
    visibilidade,
    SAFE_CAST(
            SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', data) AS TIME
        ) AS data_medicao,
    SAFE_CAST(DATE_TRUNC(DATE(data), day) AS DATE) data_particao
FROM `rj-cor.clima_estacao_meteorologica_staging.meteorologia_redemet`


{% if is_incremental() %}

{% set max_partition = run_query(
    "SELECT DATE(gr) FROM (
        SELECT IF(
            max(data_particao) > CURRENT_DATE('America/Sao_Paulo'), CURRENT_DATE('America/Sao_Paulo'), max(data_particao)
            ) as gr 
        FROM `rj-cor.clima_estacao_meteorologica_staging.meteorologia_redemet_last_partition`
        )
    ").columns[0].values()[0] %}

WHERE
    ano_particao >= SAFE_CAST(EXTRACT(YEAR FROM SAFE_CAST("{{ max_partition }}" AS DATE)) AS STRING) AND
    mes_particao >= SAFE_CAST(EXTRACT(MONTH FROM SAFE_CAST("{{ max_partition }}" AS DATE)) AS STRING) AND
    data_particao >= SAFE_CAST(EXTRACT(DATE FROM SAFE_CAST("{{ max_partition }}" AS DATE)) AS STRING)

AND
    SAFE_CAST(
        SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', data) AS DATETIME
    ) > ("{{ max_partition }}")

{% endif %}

{{
    config(
        materialized='incremental',
        unique_key="id_evento",
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "month",
        }    
    )
}}

SELECT
    DISTINCT
    SAFE_CAST(SAFE_CAST(SAFE_CAST(id_pop AS FLOAT64) AS INT64) AS STRING) id_pop,
    id_evento,
    bairro,
    SAFE_CAST(data_inicio AS TIMESTAMP) data_inicio,
    SAFE_CAST(data_fim AS TIMESTAMP) data_fim,
    prazo,
    descricao,
    gravidade,
    SAFE_CAST(latitude AS FLOAT64) latitude,
    SAFE_CAST(longitude AS FLOAT64) longitude,
    status,
    tipo,
    SAFE_CAST(data_particao  AS DATE) as data_particao,
FROM `rj-cor.adm_cor_comando_staging.ocorrencias_nova_api`

{% if is_incremental() %}

    WHERE CAST(data_particao AS DATE) <= CURRENT_DATE('America/Sao_Paulo')
        AND CAST(data_particao AS DATE) >= DATE_SUB(CURRENT_DATE('America/Sao_Paulo'), INTERVAL 30 day)

{% endif %} 
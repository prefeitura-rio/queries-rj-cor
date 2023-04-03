{{
    config(
        materialized='incremental',
        unique_key='primary_key',
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "month",
        }    
    )
}}

SELECT
    id_evento,
    sigla,
    SAFE_CAST(data_chegada AS TIMESTAMP) data_chegada,
    SAFE_CAST(data_inicio AS TIMESTAMP) data_inicio,
    SAFE_CAST(data_fim AS TIMESTAMP) data_fim,
    descricao,
    status,
    SAFE_CAST(data_particao AS DATE) data_particao,
    CONCAT(id_evento, '_', sigla, '_', descricao) AS primary_key,
FROM `rj-cor.adm_cor_comando_staging.ocorrencias_orgaos_responsaveis`

{% if is_incremental() %}

    WHERE data_particao <= CURRENT_DATE('America/Sao_Paulo')
    AND data_particao >= DATE_SUB(CURRENT_DATE('America/Sao_Paulo'), INTERVAL 30 day)

{% endif %} 
{{
    config(
        materialized='incremental',
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
    SAFE_CAST(data_particao AS DATE) data_particao
FROM `rj-cor.adm_cor_comando_staging.ocorrencias_orgaos_responsaveis`
WHERE data_particao < CURRENT_DATE('America/Sao_Paulo')

{% if is_incremental() %}

{% set max_partition = run_query("SELECT gr FROM (SELECT IF(max(data_particao) > CURRENT_DATE('America/Sao_Paulo'), CURRENT_DATE('America/Sao_Paulo'), max(data_particao)) as gr FROM " ~ this ~ ")").columns[0].values()[0] %}

AND
    data_particao > ("{{ max_partition }}")

{% endif %}

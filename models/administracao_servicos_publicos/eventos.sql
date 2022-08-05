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
    id_pop,
    id_evento,
    bairro,
    data_inicio,
    data_fim,
    prazo,
    descricao,
    gravidade,
    latitude,
    longitude,
    status,
    tipo,
    data_particao
FROM `rj-cor.administracao_servicos_publicos_staging.eventos`
WHERE data_particao < CURRENT_DATE('America/Sao_Paulo')

{% if is_incremental() %}

{% set max_partition = run_query("SELECT gr FROM (SELECT IF(max(data_particao) > CURRENT_DATE('America/Sao_Paulo'), CURRENT_DATE('America/Sao_Paulo'), max(data_particao)) as gr FROM " ~ this ~ ")").columns[0].values()[0] %}

AND
    data_particao > ("{{ max_partition }}")

{% endif %}

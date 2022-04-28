{{
    config(
        materialized='incremental',
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "day",
        },
        post_hook='CREATE OR REPLACE TABLE `rj-cor.lalala.dummy_last_partition` AS (SELECT CURRENT_DATETIME("America/Sao_Paulo") AS data_particao)'
    )
}}

SELECT
    *
FROM `rj-cor.lalala.dummy`

{% if is_incremental() %}

WHERE
    data_particao >= (
        SELECT
            MAX(data_particao)
        FROM `rj-cor.lalala.dummy_last_partition`
    )

{% endif %}

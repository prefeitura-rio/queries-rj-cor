{{
    config(
        materialized='overwrite',
        unique_key="data_medicao",
        partition_by={
            "field": "data_particao",
            "data_type": "date",
            "granularity": "month",
        },
    ),
}}

SELECT
  SAFE_CAST(SAFE.PARSE_TIMESTAMP('%d/%m/%Y %H:%M', data_hora) AS DATETIME) as data_medicao,
  SAFE_CAST(lamina_nivel as FLOAT64) as nivel_agua,
  SAFE_CAST(DATE_TRUNC(DATE(SAFE.PARSE_TIMESTAMP('%d/%m/%Y %H:%M', data_hora)), day) AS DATE) data_particao
FROM `rj-cor.clima_fluviometro_staging.nivel_lagoa`

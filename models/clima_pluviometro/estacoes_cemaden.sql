SELECT
  DISTINCT
  CAST(id_estacao AS STRING) id_estacao, 
  estacao,
  CAST(latitude AS FLOAT64) latitude,
  CAST(longitude AS FLOAT64) longitude
FROM `rj-cor.clima_pluviometro_staging.estacoes_cemaden`
ORDER BY id_estacao
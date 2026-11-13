-- 3.7 Règles métier (Silver)

-- 3.7.1 Les montants des opportunités sont >= 0
-- Attendu : nb_montants_negatifs = 0
-- Résultat obtenu : 20 lignes, 20 montants OK, 0 négatif, 0 NULL
SELECT
    COUNT(*)                                     AS nb_lignes,
    COUNT(*) FILTER (WHERE amount::numeric >= 0) AS nb_montants_ok,
    COUNT(*) FILTER (WHERE amount::numeric < 0)  AS nb_montants_negatifs,
    COUNT(*) FILTER (WHERE amount IS NULL)       AS nb_montants_null
FROM silver.silver_espocrm_opportunity;

-- 3.7.2 API ESS : établissements ouverts <= établissements au total, et aucun nombre négatif
-- Attendu : nb_anomalies = 0
-- Résultat obtenu : 79 967 lignes, 0 anomalie
SELECT
    COUNT(*) AS nb_lignes,
    COUNT(*) FILTER (
        WHERE nombre_etablissements_ouverts::int > nombre_etablissements::int
           OR nombre_etablissements::int < 0
           OR nombre_etablissements_ouverts::int < 0
    ) AS nb_anomalies
FROM silver.silver_api_ess;

-- Détail des lignes en anomalie (requête de diagnostic, vide si le test est réussi)
SELECT nom_complet, extract_department, nombre_etablissements, nombre_etablissements_ouverts
FROM silver.silver_api_ess
WHERE nombre_etablissements_ouverts::int > nombre_etablissements::int
   OR nombre_etablissements::int < 0
   OR nombre_etablissements_ouverts::int < 0;
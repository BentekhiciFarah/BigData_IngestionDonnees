-- 3.2 Doublons (lignes strictement identiques)
-- Résultat obtenu avant dédoublonnage : 33 doublons dans silver_api_ess (80 000 lignes, 79 967 distinctes)
-- Le dédoublonnage est fait par sql/silver/02_silver_api_ess_dedoublonnage.sql
-- Résultat attendu après exécution des scripts Silver : nb_doublons = 0 partout

-- Étape 1 : quantification dans chaque table
WITH comptage AS (
    SELECT 'silver.silver_api_ess' AS table_silver,
           (SELECT COUNT(*) FROM silver.silver_api_ess) AS nb_lignes,
           (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_api_ess) d) AS nb_lignes_distinctes
    UNION ALL
    SELECT 'silver.silver_csv_taux_pauvrete',
           (SELECT COUNT(*) FROM silver.silver_csv_taux_pauvrete),
           (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_csv_taux_pauvrete) d)
    UNION ALL
    SELECT 'silver.silver_espocrm_accounts',
           (SELECT COUNT(*) FROM silver.silver_espocrm_accounts),
           (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_espocrm_accounts) d)
    UNION ALL
    SELECT 'silver.silver_espocrm_contacts',
           (SELECT COUNT(*) FROM silver.silver_espocrm_contacts),
           (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_espocrm_contacts) d)
    UNION ALL
    SELECT 'silver.silver_espocrm_opportunity',
           (SELECT COUNT(*) FROM silver.silver_espocrm_opportunity),
           (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_espocrm_opportunity) d)
)
SELECT
    table_silver,
    nb_lignes,
    nb_lignes_distinctes,
    nb_lignes - nb_lignes_distinctes AS nb_doublons
FROM comptage;

-- Étape 2 : vérification de silver_api_ess après dédoublonnage
-- Attendu : nb_lignes = nb_lignes_distinctes = 79 967 et nb_doublons = 0
SELECT
    COUNT(*) AS nb_lignes,
    (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_api_ess) d) AS nb_lignes_distinctes,
    COUNT(*) - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM silver.silver_api_ess) d) AS nb_doublons
FROM silver.silver_api_ess;
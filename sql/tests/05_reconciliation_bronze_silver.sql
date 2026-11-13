-- 3.5 Réconciliation Bronze VS Silver
-- Seul écart attendu : silver_api_ess, où 33 doublons ont été supprimés
-- Résultats obtenus : Bronze 80 000 / Silver 79 967 pour l'API ; 0 écart pour les autres tables

-- Étape 1 : nombre de lignes en Silver
SELECT 'silver_api_ess' AS table_silver, COUNT(*) AS nb_lignes FROM silver.silver_api_ess
UNION ALL
SELECT 'silver_csv_taux_pauvrete', COUNT(*) FROM silver.silver_csv_taux_pauvrete
UNION ALL
SELECT 'silver_espocrm_accounts', COUNT(*) FROM silver.silver_espocrm_accounts
UNION ALL
SELECT 'silver_espocrm_contacts', COUNT(*) FROM silver.silver_espocrm_contacts
UNION ALL
SELECT 'silver_espocrm_opportunity', COUNT(*) FROM silver.silver_espocrm_opportunity;

-- Étape 2 : nombre de lignes en Bronze
SELECT 'Postgre_Bronze_API_ESS' AS table_bronze, COUNT(*) AS nb_lignes FROM bronze."Postgre_Bronze_API_ESS"
UNION ALL
SELECT 'Postgre_Bronze_CSV_TauxPauvrete', COUNT(*) FROM bronze."Postgre_Bronze_CSV_TauxPauvrete"
UNION ALL
SELECT 'Postgre_Bronze_EspoCRM_Accounts', COUNT(*) FROM bronze."Postgre_Bronze_EspoCRM_Accounts"
UNION ALL
SELECT 'Postgre_Bronze_EspoCRM_Contacts', COUNT(*) FROM bronze."Postgre_Bronze_EspoCRM_Contacts"
UNION ALL
SELECT 'Postgre_Bronze_EspoCRM_Opportunity', COUNT(*) FROM bronze."Postgre_Bronze_EspoCRM_Opportunity";

-- Étape 3 : comparaison côte à côte et explication de l'écart
-- Attendu : ecart = doublons_bronze (33 pour l'API, 0 ailleurs) et ecart_inexplique = 0
WITH b AS (
    SELECT 'api_ess' AS donnees, COUNT(*) AS nb_bronze,
           COUNT(*) - (SELECT COUNT(*) FROM (SELECT DISTINCT sigle, nom_complet, date_creation, nature_juridique,
                  extract_department, nom_raison_sociale, categorie_entreprise, nombre_etablissements,
                  tranche_effectif_salarie, nombre_etablissements_ouverts, section_activite_principale
                  FROM bronze."Postgre_Bronze_API_ESS") d) AS doublons_bronze
    FROM bronze."Postgre_Bronze_API_ESS"
    UNION ALL
    SELECT 'csv_taux_pauvrete', COUNT(*), 0 FROM bronze."Postgre_Bronze_CSV_TauxPauvrete"
    UNION ALL
    SELECT 'espocrm_accounts', COUNT(*), 0 FROM bronze."Postgre_Bronze_EspoCRM_Accounts"
    UNION ALL
    SELECT 'espocrm_contacts', COUNT(*), 0 FROM bronze."Postgre_Bronze_EspoCRM_Contacts"
    UNION ALL
    SELECT 'espocrm_opportunity', COUNT(*), 0 FROM bronze."Postgre_Bronze_EspoCRM_Opportunity"
),
s AS (
    SELECT 'api_ess' AS donnees, COUNT(*) AS nb_silver FROM silver.silver_api_ess
    UNION ALL SELECT 'csv_taux_pauvrete', COUNT(*) FROM silver.silver_csv_taux_pauvrete
    UNION ALL SELECT 'espocrm_accounts', COUNT(*) FROM silver.silver_espocrm_accounts
    UNION ALL SELECT 'espocrm_contacts', COUNT(*) FROM silver.silver_espocrm_contacts
    UNION ALL SELECT 'espocrm_opportunity', COUNT(*) FROM silver.silver_espocrm_opportunity
)
SELECT
    b.donnees,
    b.nb_bronze,
    s.nb_silver,
    b.nb_bronze - s.nb_silver                     AS ecart,
    b.doublons_bronze,
    (b.nb_bronze - s.nb_silver) - b.doublons_bronze AS ecart_inexplique
FROM b
JOIN s USING (donnees)
ORDER BY b.donnees;
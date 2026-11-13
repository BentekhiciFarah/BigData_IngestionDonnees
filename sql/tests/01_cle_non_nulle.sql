-- 3.1 Clé non nulle (Silver)
-- Résultat attendu : aucune ligne renvoyée pour chaque requête

-- API ESS : nom_raison_sociale et nom_complet servent d'identifiant
SELECT *
FROM silver.silver_api_ess
WHERE nom_raison_sociale IS NULL OR nom_complet IS NULL;

-- CSV taux de pauvreté
SELECT *
FROM silver.silver_csv_taux_pauvrete
WHERE libelle_commune IS NULL;

-- EspoCRM comptes
SELECT *
FROM silver.silver_espocrm_accounts
WHERE id IS NULL;

-- EspoCRM contacts
SELECT *
FROM silver.silver_espocrm_contacts
WHERE id IS NULL;

-- EspoCRM opportunités
SELECT *
FROM silver.silver_espocrm_opportunity
WHERE id IS NULL;
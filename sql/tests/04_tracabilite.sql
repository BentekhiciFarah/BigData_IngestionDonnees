-- 3.4 Traçabilité : chaque ligne Silver retrouve sa ligne d'origine en Bronze
-- Résultat attendu : nb_sans_origine = 0 pour chaque table

SELECT 'silver_espocrm_accounts' AS table_silver, COUNT(*) AS nb_sans_origine
FROM silver.silver_espocrm_accounts s
LEFT JOIN bronze."Postgre_Bronze_EspoCRM_Accounts" b ON b.id = s.id
WHERE b.id IS NULL
UNION ALL
SELECT 'silver_espocrm_contacts', COUNT(*)
FROM silver.silver_espocrm_contacts s
LEFT JOIN bronze."Postgre_Bronze_EspoCRM_Contacts" b ON b.id = s.id
WHERE b.id IS NULL
UNION ALL
SELECT 'silver_espocrm_opportunity', COUNT(*)
FROM silver.silver_espocrm_opportunity s
LEFT JOIN bronze."Postgre_Bronze_EspoCRM_Opportunity" b ON b.id = s.id
WHERE b.id IS NULL
UNION ALL
SELECT 'silver_csv_taux_pauvrete', COUNT(*)
FROM silver.silver_csv_taux_pauvrete s
WHERE NOT EXISTS (
    SELECT 1 FROM bronze."Postgre_Bronze_CSV_TauxPauvrete" b
    WHERE COALESCE(b.geocode_commune, '') = COALESCE(s.geocode_commune, '')
      AND COALESCE(b.annee, -1)           = COALESCE(s.annee, -1)
)
UNION ALL
SELECT 'silver_api_ess', COUNT(*)
FROM silver.silver_api_ess s
WHERE NOT EXISTS (
    SELECT 1 FROM bronze."Postgre_Bronze_API_ESS" b
    WHERE COALESCE(b.nom_complet, '')        = COALESCE(s.nom_complet, '')
      AND COALESCE(b.date_creation, '')      = COALESCE(s.date_creation, '')
      AND COALESCE(b.extract_department, -1) = COALESCE(s.extract_department, -1)
);

-- Exemple pour le rapport : une opportunité Silver et sa ligne Bronze d'origine
-- (identifiant Airbyte et date d'ingestion)
SELECT s.id, s.name, s.amount,
       b._airbyte_raw_id, b._airbyte_extracted_at
FROM silver.silver_espocrm_opportunity s
JOIN bronze."Postgre_Bronze_EspoCRM_Opportunity" b ON b.id = s.id
LIMIT 5;
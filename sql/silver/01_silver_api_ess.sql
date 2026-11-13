-- Silver API ESS : sélection des champs utiles depuis la Bronze
DROP TABLE IF EXISTS silver.silver_api_ess;

CREATE TABLE silver.silver_api_ess AS
SELECT
    sigle,
    nom_complet,
    date_creation,
    nature_juridique,
    extract_department,
    nom_raison_sociale,
    categorie_entreprise,
    nombre_etablissements,
    tranche_effectif_salarie,
    nombre_etablissements_ouverts,
    section_activite_principale
FROM bronze."Postgre_Bronze_API_ESS";
-- Silver taux de pauvreté : sélection des champs depuis la Bronze
DROP TABLE IF EXISTS silver.silver_csv_taux_pauvrete;

CREATE TABLE silver.silver_csv_taux_pauvrete AS
SELECT
    annee,
    valeur,
    date_mesure,
    geocode_commune,
    libelle_commune
FROM bronze."Postgre_Bronze_CSV_TauxPauvrete";
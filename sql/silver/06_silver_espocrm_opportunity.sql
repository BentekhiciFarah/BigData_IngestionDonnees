-- Silver EspoCRM : opportunités (colonnes renommées en snake_case)
DROP TABLE IF EXISTS silver.silver_espocrm_opportunity;

CREATE TABLE silver.silver_espocrm_opportunity AS
SELECT
    id,
    name,
    stage,
    amount,
    "accountId"   AS account_id,
    "closeDate"   AS close_date,
    description,
    "accountName" AS account_name,
    probability
FROM bronze."Postgre_Bronze_EspoCRM_Opportunity";
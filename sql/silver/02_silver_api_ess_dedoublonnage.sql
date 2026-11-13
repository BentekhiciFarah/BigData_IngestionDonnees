-- Suppression des lignes strictement identiques dans silver_api_ess
BEGIN;

CREATE TABLE silver.silver_api_ess_dedoublonnee AS
SELECT DISTINCT *
FROM silver.silver_api_ess;

DROP TABLE silver.silver_api_ess;

ALTER TABLE silver.silver_api_ess_dedoublonnee RENAME TO silver_api_ess;

COMMIT;
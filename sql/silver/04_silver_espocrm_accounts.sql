-- Silver EspoCRM : comptes (colonnes renommées en snake_case)
DROP TABLE IF EXISTS silver.silver_espocrm_accounts;

CREATE TABLE silver.silver_espocrm_accounts AS
SELECT
    id,
    name,
    website,
    industry,
    description,
    "emailAddress"             AS email_address,
    "billingAddressState"      AS billing_address_state,
    "billingAddressStreet"     AS billing_address_street,
    "billingAddressPostalCode" AS billing_address_postal_code
FROM bronze."Postgre_Bronze_EspoCRM_Accounts";
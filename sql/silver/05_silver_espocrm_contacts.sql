-- Silver EspoCRM : contacts (colonnes renommées en snake_case)
DROP TABLE IF EXISTS silver.silver_espocrm_contacts;

CREATE TABLE silver.silver_espocrm_contacts AS
SELECT
    id,
    name,
    title,
    "lastName"          AS last_name,
    "firstName"         AS first_name,
    "accountName"       AS account_name,
    "addressCity"       AS address_city,
    description,
    "phoneNumber"       AS phone_number,
    "emailAddress"      AS email_address,
    "addressPostalCode" AS address_postal_code
FROM bronze."Postgre_Bronze_EspoCRM_Contacts";
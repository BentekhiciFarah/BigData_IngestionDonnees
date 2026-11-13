-- 3.3 Observation des types de toutes les tables

-- Types des tables Silver
SELECT
    table_name,
    ordinal_position AS position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'silver'
ORDER BY table_name, ordinal_position;

-- Types des tables Bronze (pour comparaison)
SELECT
    table_name,
    ordinal_position AS position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'bronze'
ORDER BY table_name, ordinal_position;
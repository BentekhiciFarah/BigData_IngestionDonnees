select id, name
from {{ source('crm', 'account') }}
where lower(coalesce(cast(deleted as text), '0')) in ('0', 'false', 'f')

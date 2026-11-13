-- Le TP demande de creer le compte "TP Docker" dans EspoCRM.
-- Le test echoue si cette ligne n'est pas parvenue jusqu'au modele dbt.
select 'Compte TP Docker absent' as erreur
where not exists (
  select 1 from {{ ref('comptes_actifs') }} where name = 'TP Docker'
)

# Configuration Airbyte

Airbyte est installé avec abctl (http://localhost:8000), en dehors du compose.
Il tourne sur un réseau Docker séparé : les services du compose s'atteignent via
`host.docker.internal` + le port publié.

## 1. Importer les connecteurs personnalisés
Builder → New custom connector → Import a YAML :
- `connecteur_api_ess.yaml` : API Recherche d'entreprises (ESS)
- `connecteur_espocrm_api.yaml` : API EspoCRM (accounts, contacts, opportunities)

## 2. Sources
| Source | Type | Paramètres |
|---|---|---|
| API ESS | Builder | départements : 75,77,78,91,92,93,94,95 ; etat_administratif : A |
| EspoCRM API | Builder | URL : http://host.docker.internal:8081 ; X-Api-Key : <>  (utilisateur API en lecture seule) |
| Taux de pauvreté | File (CSV) | URL : "https://www.data.gouv.fr/api/1/datasets/r/5da6042e-bd4c-4a9f-bea6-1f0ba43ef24d"
| Minio → Airbyte | S3 v4.17.1 | bucket : dsid-raw ; Advanced → Endpoint : http://host.docker.internal:9000 ; clés : <MINIO_USER>/<MINIO_PASSWORD> ; format JSONL ; Schemaless désactivé |
| EspoCRM MariaDB | MySQL | host.docker.internal:3307 ; utilisateur lecture seule <USER> |

Globs de la source S3 (sans le nom du bucket) :
| Stream | Glob |
|---|---|
| API ESS | `dsid-raw/Raw-Ess-API/API_ESS_-__Airbyte/*.jsonl` |
| Taux de pauvreté | `dsid-raw/Raw-Ess-API/CsvTauxPauvreteTaux_de_pauvrete/*.jsonl` |
| EspoCRM accounts | `dsid-raw/Raw-Ess-API/Espocrm_accounts/*.jsonl` |
| EspoCRM contacts | `dsid-raw/Raw-Ess-API/Espocrm_contacts/*.jsonl` |
| EspoCRM opportunities | `dsid-raw/Raw-Ess-API/Espocrm_opportunities/*.jsonl` |

## 3. Destinations
| Destination | Paramètres |
|---|---|
| MinIO (S3) | bucket : dsid-raw ; endpoint : http://host.docker.internal:9000 ; JSONL ; Root level flattening |
| PostgreSQL | host.docker.internal:5432 ; base : dsid ; schéma : bronze ; utilisateur : dsid |

## 4. Connexions (à lancer dans cet ordre)
| # | Connexion | Mode | Remarque |
|---|---|---|---|
| 1 | API ESS → MinIO | Full Refresh / Overwrite | |
| 2 | CSV taux de pauvreté → MinIO | Full Refresh / Overwrite | |
| 3 | EspoCRM API → MinIO | Full Refresh / Overwrite | |
| 4 | MinIO → PostgreSQL (bronze) | Full Refresh / Overwrite | 4 champs `_airbyte_*` du fichier décochés |
| 5 | EspoCRM MariaDB → PostgreSQL (bronze) | Full Refresh / Overwrite | tables account, contact, opportunity |

## 5. Incidents rencontrés
1. **Données enveloppées dans `_airbyte_data`** : la Bronze ne contenait qu'une colonne JSON.
   → Résolu en activant le *Root level flattening* sur la destination MinIO, puis en réexportant.
2. **`column "_airbyte_raw_id" specified more than once`** : les colonnes techniques du fichier
   entraient en conflit avec celles ajoutées par Airbyte.
   → Résolu en décochant les 4 champs `_airbyte_*` dans le schéma de la connexion MinIO → PostgreSQL.

## 6. Limites
- API Recherche d'entreprises : 7 requêtes/s, 10 000 résultats maximum par département,
  unités non diffusibles exclues, 100 établissements maximum par unité.
- Le mode Overwrite côté MinIO peut supprimer les anciens fichiers : les manifestes de lots
  se trouvent dans `data/manifestes/`.

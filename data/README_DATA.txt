# Données

## Contenu
| Dossier | Contenu | Complet ? |
|---|---|---|
| echantillons/api_ess | 100 premières lignes de l'export RAW de l'API | non (≈ 80 000 lignes en tout) |
| echantillons/csv_taux_pauvrete_original | fichier CSV source | oui |
| echantillons/csv_taux_pauvrete_raw | 100 premières lignes de l'export RAW Airbyte | non (34 875 lignes) |
| echantillons/espocrm_raw | export RAW de l'API EspoCRM | oui (données fictives) |
| echantillons/espocrm_import | CSV importés dans EspoCRM | oui (données fictives) |

## Sources et procédure de collecte
- **API Recherche d'entreprises** : https://recherche-entreprises.api.gouv.fr (Licence Ouverte).
  Collecte : connecteur `airbyte/connecteur_api_ess.yaml`, départements 75, 77, 78, 91, 92, 93, 94, 95.
- **Taux de pauvreté** : "https://www.data.gouv.fr/api/1/datasets/r/5da6042e-bd4c-4a9f-bea6-1f0ba43ef24d" (http://opendatacommons.org/licenses/odbl/summary/).
  Collecte : Airbyte File Source → MinIO ; l'original est conservé dans `dsid-raw/original/`.
- **EspoCRM** : données fictives ; recréer le CRM en important `espocrm_import/*.csv`.

## Intégrité
Les empreintes SHA-256 des fichiers sont dans `manifestes/sha256.csv`.
Vérification (PowerShell) :
    Get-FileHash <fichier> -Algorithm SHA256
La valeur obtenue doit être égale à `sha256_rendu` dans le manifeste.

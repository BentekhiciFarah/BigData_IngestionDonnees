# Projet Big Data – Présence des ESS dans les territoires pauvres (Île-de-France)

Chaîne : API ESS + CSV taux de pauvreté + EspoCRM → Airbyte → MinIO (RAW) → PostgreSQL `bronze` → `silver` (SQL).

## 1. Prérequis
- Docker Desktop, abctl (Airbyte)
- Images : PostgreSQL 16.15 (le kit annonce 18.6 : écart assumé), MariaDB 11.8.9, EspoCRM 10.0.8,
  Adminer 5, MinIO elestio/minio (version figée par digest, voir `preuves/versions_images.txt`)

## 2. Démarrage
```
cd compose
copy .env.example .env        # renseigner les mots de passe
docker compose -p dsid-etudiant up -d
abctl local install           # Airbyte : http://localhost:8000
```

| Service | Accès |
|---|---|
| Adminer | http://localhost:8082 (serveur `postgres`, base `dsid`) |
| MinIO | console http://localhost:9001, API 9000 |
| EspoCRM | http://localhost:8081 |
| PostgreSQL | localhost:5432 |

Airbyte est sur un réseau séparé : utiliser `host.docker.internal` + port publié.

## 3. Configuration
1. MinIO : créer le bucket `dsid-raw`.
2. PostgreSQL : `sql/silver/00_create_schema.sql` + `CREATE SCHEMA IF NOT EXISTS bronze;`
3. EspoCRM : importer `data/echantillons/espocrm_import/*.csv`, créer un utilisateur API en lecture seule.
4. Airbyte : importer les YAML de `airbyte/` et créer sources, destinations et connexions
   (détail dans `airbyte/README_AIRBYTE.md`).

## 4. Synchronisation (dans cet ordre)
1. API ESS → MinIO
2. CSV taux de pauvreté → MinIO
3. EspoCRM API → MinIO
4. MinIO (Source S3) → PostgreSQL `bronze`

## 5. Transformation Silver
Exécuter dans Adminer (Importer) les fichiers `sql/silver/` de **00 à 06**, dans l'ordre.

## 6. Tests
Exécuter `sql/tests/` de **01 à 06**. Résultats attendus en commentaire dans chaque fichier,
captures dans `preuves/resultats_tests/`.

## 7. Rejouabilité
Connexions en Full Refresh | Overwrite et scripts Silver en `DROP TABLE IF EXISTS` + `CREATE TABLE` :
relancer la chaîne redonne le même résultat.

## 8. Arborescence
| Dossier | Contenu |
|---|---|
| `rapport/` | rapport PDF |
| `compose/` | compose.yaml, Dockerfile.minio, .env.example, README_DOCKER.md |
| `airbyte/` | connecteurs Builder (YAML) + README_AIRBYTE.md |
| `sql/` | scripts Silver et tests |
| `data/` | échantillons, manifestes, SHA-256 |
| `preuves/` | logs, résultats de tests |
PS : les captures d'écran sont dans le rapport. 

## 9. Limites
- API : 7 req/s, 10 000 résultats max par département, unités non diffusibles exclues.
- Silver API ESS et CSV sans identifiant technique : traçabilité par combinaison de champs.
- Valeurs NULL dans le CSV des taux de pauvreté.
- Flux MariaDB → Source MySQL → `bronze` **non réalisé car API de EspoCRM utilisée à la place** : EspoCRM est ingéré via son API REST → MinIO → `bronze`.
- Aucun secret fourni : les valeurs `change_me` / `<...>` sont à renseigner.

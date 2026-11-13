# Kit étudiant DSID — Windows

**Installation locale facultative — édition du 23 septembre 2026.**

Ce dossier permet de reproduire la stack du TP sur son ordinateur. Destination des données : **PostgreSQL**. Lire `VALIDATION.md` pour le périmètre des tests réalisés.

## Installation Windows

1. Installer **Docker Desktop pour Windows**, avec le moteur WSL2 et les conteneurs Linux. Suivre les prérequis de sa version de Windows indiqués par Docker. Redémarrer Windows si l’installation le demande, puis ouvrir Docker Desktop.
2. Extraire **tout le ZIP** dans un dossier local, par exemple `C:\TP\dsid-windows`. Ne pas exécuter les scripts directement dans l’archive ; éviter un dossier synchronisé par OneDrive.
3. Ouvrir **PowerShell**, puis se placer dans ce dossier :

   ```powershell
   cd C:\TP\dsid-windows
   powershell -NoProfile -ExecutionPolicy Bypass -File .\installer.ps1
   ```

   La politique `Bypass` concerne ce processus PowerShell uniquement ; elle ne modifie pas la politique permanente de Windows. Aucun droit administrateur n’est requis par le script une fois Docker Desktop installé.

4. Attendre la fin. Le script crée les mots de passe dans `.env`, télécharge abctl dans `.tools`, installe Airbyte, puis démarre Compose. Les identifiants Airbyte sont affichés dans le terminal.
5. Suivre le parcours ci-dessous pour créer le compte de test, la source, la destination et la synchronisation. L’installation des services seule ne crée pas ces objets Airbyte.

Le téléchargement abctl est choisi automatiquement pour Windows x64 ou ARM64. La VM de référence du cours est Windows x64 ; une installation neuve ARM64 n’a pas été exécutée pour ce kit.

### Redémarrer, arrêter, diagnostiquer

Depuis le dossier du kit :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\demarrer.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\diagnostic.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\arreter.ps1
```

Exécuter uniquement la commande correspondant à l’action voulue. `arreter.ps1` conserve les données. Pour consulter les mots de passe du kit :

```powershell
notepad .env
```


## Ce que contient le kit

Ce kit installe un environnement de TP local, sans abonnement cloud :

```text
EspoCRM → MariaDB → Airbyte → PostgreSQL (schema crm)
                                  ↓
                            dbt (schema mart) → Metabase

Adminer : consultation SQL
JSON Server : petite API de demonstration
MinIO : stockage compatible S3
```

Airbyte est installé par `abctl` dans un cluster Kubernetes local. Les autres services sont décrits dans `compose.yaml`. Le réseau externe `kind` relie Airbyte aux sources et à PostgreSQL dès la création des conteneurs : aucune commande manuelle `docker network connect` n’est nécessaire dans ce kit.

Le projet Compose est nommé `dsid-etudiant`. Les volumes sont propres à ce projet. Il s’agit d’une installation neuve, **pas d’une migration ni d’une copie des données de la VM universitaire**. Les données de démonstration JSON sont fictives.

## Avant de commencer

- Installer Docker Desktop adapté à son système et le laisser ouvert. Choisir les **conteneurs Linux** sous Windows.
- Prévoir une connexion Internet pour télécharger les images, GitHub, npm et PyPI.
- Pour l’ensemble du TP, prévoir idéalement une machine de 16 Go de RAM au minimum, 4 cœurs ou plus et environ 40 Go libres. Ce sont des réserves de travail pour la stack complète, pas une garantie de performance. Airbyte seul recommande 8 Go de mémoire ; le kit utilise son mode de ressources réduites.
- Sur un Mac disposant de suffisamment de mémoire, attribuer environ 10 à 12 Go à Docker pour travailler confortablement avec Metabase. Sur Windows/WSL2, vérifier que les limites de la VM Docker ne sont pas trop basses.
- Ne pas lancer deux copies du kit en parallèle. Les ports 8000, 8081, 8082, 5432, 3000, 3001, 9000 et 9001 doivent être disponibles.
- Le premier démarrage peut durer 15 à 30 minutes ou davantage selon la connexion. Ne pas fermer le terminal pendant l’installation.

Références : [Docker Desktop Windows](https://docs.docker.com/desktop/setup/install/windows-install/), [Docker Desktop Mac](https://docs.docker.com/desktop/setup/install/mac-install/), [prérequis Airbyte](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart).

## Après l’installation : adresses et identifiants

Le script crée un fichier **`.env`** contenant des mots de passe aléatoires. Ouvrir ce fichier localement pour les copier dans les interfaces. Ne pas le joindre à un email ni le déposer dans un dépôt partagé.

| Service | Adresse dans le navigateur | Compte / mot de passe |
|---|---|---|
| Airbyte | http://localhost:8000 | Affichés par la commande `local credentials` ci-dessous |
| EspoCRM | http://localhost:8081 | `admin` / valeur `ESPOCRM_ADMIN_PASSWORD` dans `.env` |
| Adminer | http://localhost:8082 | PostgreSQL : serveur `postgres`, base et utilisateur `dsid`, valeur `POSTGRES_PASSWORD` |
| JSON Server | http://localhost:3001/clients | Pas d’authentification ; données fictives |
| MinIO, console | http://localhost:9001 | `dsidminio` / valeur `MINIO_ROOT_PASSWORD` |
| MinIO, API S3 | http://localhost:9000 | Même paire d’identifiants pour les exercices locaux |
| Metabase, à démarrer à l’étape 6 | http://localhost:3000 | Créer son compte dans l’assistant initial |

### Connexions techniques et mots de passe

Les valeurs de la colonne « mot de passe » sont les **noms des variables à lire dans `.env`**, pas les mots de passe à saisir littéralement. Chaque installation génère ses propres valeurs.

| Solution / usage | Hôte et port internes | Accès depuis l’ordinateur | Utilisateur | Mot de passe |
|---|---|---|---|---|
| MariaDB / EspoCRM | `espocrm-db:3306` ; depuis Airbyte `dsid-espocrm-db:3306` | Pas de port publié ; passer par Adminer | `espocrm` | `ESPOCRM_DB_PASSWORD` |
| MariaDB / administration | `espocrm-db:3306` | Adminer, système MySQL, serveur `espocrm-db` | `root` | `ESPOCRM_DB_ROOT_PASSWORD` |
| PostgreSQL / Airbyte et dbt | `postgres:5432` ; depuis Airbyte `dsid-postgres:5432` | `localhost:5432`, base `dsid` | `dsid` | `POSTGRES_PASSWORD` |
| PostgreSQL / lecture Metabase | `postgres:5432`, base `dsid` | Adminer ou client SQL | `bi_reader` | `BI_READER_PASSWORD` |
| Métadonnées Metabase | `postgres:5432`, base `metabase` | Géré automatiquement par Compose | `metabase_app` | `METABASE_DB_PASSWORD` |
| dbt | Se connecte à PostgreSQL ; aucun serveur web | Commandes `docker compose … dbt` | `dsid` pour PostgreSQL | `POSTGRES_PASSWORD`, transmis automatiquement |
| Adminer | Interface web sur le port 8082 | http://localhost:8082 | Compte de la base choisie | Mot de passe de cette base ; aucun compte Adminer distinct |
| Metabase / interface | Port 3000 | http://localhost:3000 | Email choisi dans l’assistant | Mot de passe choisi dans l’assistant ; distinct de `METABASE_DB_PASSWORD` |
| Airbyte | Port 8000 | http://localhost:8000 | Email indiqué par `local credentials` | Mot de passe généré automatiquement, affiché par `local credentials` |

EspoCRM, JSON Server et MinIO figurent dans le tableau des interfaces ci-dessus. JSON Server n’a pas de mot de passe ; MinIO utilise `dsidminio` / `MINIO_ROOT_PASSWORD`. Le daemon EspoCRM n’a ni interface, ni port, ni compte distinct.

Les interfaces Compose et le port SQL PostgreSQL sont publiés sur `127.0.0.1`. Airbyte a sa propre publication de port gérée par abctl ; ne pas exposer cette installation de TP sur Internet. Le mode TLS PostgreSQL ci-dessous correspond à son réseau Docker local.

Les comptes SQL du TP sont volontairement simples : Airbyte et dbt utilisent le compte propriétaire `dsid` dans PostgreSQL ; la visualisation Metabase utilise `bi_reader` en lecture seule. L’application Metabase dispose d’une base de métadonnées et d’un compte séparés (`metabase`, `metabase_app`).

### Retrouver les identifiants Airbyte

Windows, dans PowerShell depuis le dossier du kit :

```powershell
.\.tools\abctl.exe local credentials
```

Mac, dans Terminal depuis le dossier du kit :

```bash
./.tools/abctl local credentials
```

**Mot de passe Airbyte oublié :** réexécuter la commande `local credentials` ci-dessus depuis le même dossier. Elle affiche les identifiants existants, y compris le mot de passe généré automatiquement ; elle ne le réinitialise pas. Il ne se trouve pas dans le fichier `.env` du kit.

Lors du premier accès à Airbyte, renseigner son propre email et le nom de son établissement dans l’assistant. Utiliser les identifiants de cette installation, pas ceux de l’enseignant.

## Parcours de validation de bout en bout

### 1. Créer une donnée dans EspoCRM

Ouvrir EspoCRM, se connecter puis créer un **Compte / Account** dont le nom est exactement :

```text
TP Docker
```

Enregistrer. Ce repère permettra de prouver que les données traversent toute la chaîne. L’initialisation d’EspoCRM peut prendre quelques minutes après le démarrage du conteneur ; consulter `docker compose logs --tail 100 espocrm` si nécessaire.

### 2. Créer la source MariaDB dans Airbyte

Dans **Sources → New source**, choisir **MySQL**.

| Champ | Valeur |
|---|---|
| Source name | `EspoCRM MariaDB` |
| Host | `dsid-espocrm-db` |
| Port | `3306` |
| Database | `espocrm` |
| User | `espocrm` |
| Password | Valeur `ESPOCRM_DB_PASSWORD` de `.env` |
| Encryption | `required` |
| SSH Tunnel Method | `No Tunnel` |
| Update Method | `Scan Changes with User Defined Cursor` |

Cliquer **Set up source** et attendre la réussite. Le premier test peut télécharger les images du connecteur.

`localhost` ne convient pas ici : le connecteur tourne dans Kubernetes. Le nom `dsid-espocrm-db` est l’alias réseau déclaré dans Compose. Pour ce premier TP, ne pas sélectionner CDC : il exige des réglages supplémentaires. [Source MySQL et MariaDB](https://docs.airbyte.com/integrations/sources/mysql).

### 3. Créer la destination PostgreSQL

Dans **Destinations → New destination**, choisir **Postgres**.

| Champ | Valeur |
|---|---|
| Destination name | `PostgreSQL TP` |
| Host | `dsid-postgres` |
| Port | `5432` |
| Database Name | `dsid` |
| Default Schema | `crm` |
| Username | `dsid` |
| Password, sous **Optional fields** | Valeur `POSTGRES_PASSWORD` de `.env` |
| SSL Modes | `disable` pour le PostgreSQL local de ce kit |
| SSL Connection, si affiché | Désactivé |
| SSH Tunnel Method | `No Tunnel` |

Cliquer **Set up destination** et attendre la réussite. Un mot de passe marqué « Optional » dans l’interface reste nécessaire pour ce serveur. [Destination Postgres](https://docs.airbyte.com/integrations/destinations/postgres).

### 4. Créer la connexion et synchroniser

Créer une connexion entre la source et la destination précédentes. Attendre la découverte des tables.

Configurer :

- **Destination namespace** : utiliser le schéma de la destination, donc `crm` (**Destination-defined** / **Use destination default**, selon l’écran). Ne pas conserver le schéma source `espocrm`.
- Aucun préfixe ajouté aux noms de tables.
- Sélectionner uniquement la table **`account`** pour la première validation.
- Mode : **Full Refresh → Overwrite**.
- Planification : **Manual**.

Enregistrer puis cliquer **Sync now**. Attendre le statut **Succeeded**. Ce mode remplace la copie de `account` dans le schéma `crm` à chaque exécution ; il ne modifie pas la base EspoCRM.

Le schéma `crm` du kit est réservé à ces copies. Ne pas y créer de tables personnelles portant le même nom. Pour ajouter `contact` ou d’autres tables ensuite, les sélectionner dans la connexion et relancer une synchronisation.

### 5. Vérifier PostgreSQL, puis exécuter dbt

Dans Adminer, choisir **PostgreSQL**, serveur `postgres`, utilisateur `dsid`, base `dsid` et mot de passe `POSTGRES_PASSWORD`. Exécuter :

```sql
SELECT count(*) AS comptes_synchronises FROM crm.account;
SELECT id, name FROM crm.account WHERE name = 'TP Docker';
```

La deuxième requête doit renvoyer le compte créé dans EspoCRM. Si `crm.account` est absent, contrôler la réussite de la synchronisation et le namespace de destination.

Dans le terminal, depuis le dossier du kit, exécuter ensuite :

```text
docker compose --profile tools run --rm --build dbt debug
docker compose --profile tools run --rm dbt build
```

Le projet fourni crée une **table** `mart.comptes_actifs` et teste les identifiants ainsi que la présence de `TP Docker`. Il ne crée pas de vue dépendante de la table remplacée par Airbyte. Vérifier dans Adminer :

```sql
SELECT * FROM mart.comptes_actifs WHERE name = 'TP Docker';
```

Après chaque nouvelle synchronisation Airbyte, relancer `dbt build` pour actualiser cette table. L’enchaînement est manuel dans ce kit, afin de rendre les étapes visibles pendant le TP.

### 6. Visualiser dans Metabase

Metabase est optionnel au démarrage pour économiser de la mémoire. Le lancer lorsque la synchronisation est terminée :

```text
docker compose --profile bi up -d metabase
```

Ouvrir http://localhost:3000 et terminer son assistant. Ajouter une base **PostgreSQL** avec :

| Champ | Valeur |
|---|---|
| Nom affiché | `DSID — données du TP` |
| Host | `postgres` |
| Port | `5432` |
| Database | `dsid` |
| Username | `bi_reader` |
| Password | Valeur `BI_READER_PASSWORD` |
| SSL | Désactivé pour ce serveur local |

Sélectionner le schéma `mart` et la table `comptes_actifs`. Créer une question affichant les comptes, puis éventuellement une carte comptant le nombre de lignes. `TP Docker` doit apparaître.

Metabase utilise sa base `metabase` pour stocker ses comptes, questions et tableaux de bord ; la base à **analyser** est bien `dsid`.

### 7. Utiliser les services complémentaires

**JSON Server** fournit `/clients` et `/commandes` sur le port 3001. Les modifications sont conservées dans un volume. Depuis un connecteur Airbyte, son URL interne est `http://dsid-json-server:3000`. Ces routes constituent des données de démonstration distinctes des comptes EspoCRM.

**MinIO** : ouvrir sa console, créer un bucket `tp-dsid`, puis y déposer un petit fichier CSV de démonstration. Pour un connecteur S3 exécuté par Airbyte, utiliser l’endpoint `http://dsid-minio:9000`, le bucket créé, la région `us-east-1` et les identifiants locaux. Activer l’accès par chemin (« path style ») si le connecteur le demande. La configuration exacte dépend du connecteur S3 choisi ; ce flux est un exercice complémentaire, distinct de la validation MariaDB → PostgreSQL.

## Exploitation quotidienne

Utiliser les scripts `demarrer` et `arreter` propres à son système, décrits en début de README. Ils conservent les volumes. Le redémarrage standard lance le socle ; relancer la commande Metabase si l’on souhaite aussi l’utiliser.

Commandes communes utiles :

```text
docker compose ps
docker compose logs --tail 100 espocrm
docker compose logs --tail 100 postgres
docker compose --profile bi logs --tail 100 metabase
```

**Ne pas changer `.env` pour tenter de réinitialiser un mot de passe existant.** Les bases initialisent leurs utilisateurs lors de la création du volume ; modifier ensuite le fichier ne change pas automatiquement les mots de passe déjà stockés.

Ne pas utiliser `docker compose down --volumes` pour un simple arrêt : cette option supprime les données. Le script d’arrêt fait un `stop` et conserve les données. Les données Airbyte sont gérées séparément par abctl.

## Dépannage

| Problème | Action |
|---|---|
| Docker inaccessible | Ouvrir Docker Desktop et attendre que le moteur fonctionne. |
| Réseau `kind` absent | Utiliser le script installer/démarrer : Airbyte doit créer son réseau avant Compose. |
| Port déjà utilisé | Arrêter l’autre application qui l’utilise. Pour une adaptation du port EspoCRM, modifier aussi `ESPOCRM_SITE_URL`. |
| Synchronisation bloquée, pod `Pending`, `Insufficient cpu` | Le kit active `--low-resource-mode`. Vérifier aussi le nombre de CPU et la mémoire alloués à Docker ; arrêter Metabase pendant le premier transfert. |
| `503` dans Airbyte | Attendre les services. Vérifier les ressources Docker et lancer le script diagnostic. |
| Échec réseau source/destination | Vérifier les alias `dsid-espocrm-db` et `dsid-postgres`. Ne pas utiliser `localhost` dans les connecteurs. |
| `HikariPool ... timed out` | Ouvrir les logs : le message peut masquer `password authentication failed`. Vérifier le mot de passe sous **Optional fields**. |
| EspoCRM ne termine pas son installation | Lire ses logs et ceux de MariaDB. Ne pas remplacer les trois volumes ciblés par un montage de tout `/var/www/html` avec EspoCRM 10. |
| `crm.account` absent | Sélectionner `account`, namespace de destination `crm`, puis lancer une synchronisation réussie. |
| dbt indique que `TP Docker` est absent | Créer ce compte dans EspoCRM, synchroniser, puis relancer dbt. |
| Metabase ne voit pas la table | Vérifier la connexion à `dsid`, le schéma `mart` et actualiser le schéma dans Metabase. |
| Mac ARM : image d’un connecteur indisponible | Les services Compose ont été vérifiés pour ARM64 ; certains autres connecteurs Airbyte peuvent nécessiter l’émulation x86 de Docker Desktop. Utiliser les connecteurs du TP en priorité. |
| Téléchargement interrompu | Relancer le script installer depuis le même dossier ; conserver `.env` et `.tools`. |

### Cohabitation avec une installation existante

Le script refuse de prendre en charge un cluster Airbyte déjà présent s’il n’a pas été créé depuis ce dossier. Cela évite de modifier une installation personnelle existante. Demander à l’enseignant une adaptation des noms, ports et paramètres réseau avant d’utiliser le kit sur cette machine. Ne pas désinstaller ou supprimer les volumes d’une autre installation pour contourner ce contrôle.

## Versions, reproductibilité et périmètre

- Airbyte : chart `2.3.0`, abctl `0.30.4` téléchargé depuis les releases officielles et contrôlé par SHA-256.
- EspoCRM : `10.0.8`, MariaDB : `11.8.9`, PostgreSQL : `16.15`.
- Les images Compose sont figées par leur empreinte de manifeste multiarchitecture. Les références figurent dans `compose.yaml` et `versions.json`.
- JSON Server : `0.17.4` ; dbt-postgres : `1.11.0`, dbt-core : `1.11.7`. Les dépendances transitives téléchargées à la construction ne sont pas toutes verrouillées.
- Metabase : `0.63.18`. L’image MinIO fournie par Elestio reprend le choix de la stack du cours et est figée par empreinte.
- Les versions des connecteurs proposées par le catalogue Airbyte peuvent évoluer indépendamment de la plateforme. Les versions observées lors du diagnostic sont indiquées dans `VALIDATION.md`.

Consulter **VALIDATION.md** pour distinguer les tests réalisés dans la VM de référence des vérifications des archives Windows et macOS. Ce kit ne contient aucun moteur Docker ni image préchargée.

Références techniques : [abctl](https://github.com/airbytehq/abctl), [EspoCRM 10 et volumes Docker](https://docs.espocrm.com/administration/docker/installation/), [réseaux externes Compose](https://docs.docker.com/compose/how-tos/networking/), [dbt/PostgreSQL](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup), [Metabase sous Docker](https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker).

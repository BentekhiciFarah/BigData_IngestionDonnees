# Validation et diagnostic — 23 septembre 2026

## VM universitaire existante

La VM de référence fonctionne sous Windows avec Docker, une stack Compose existante et Airbyte 2.3.0 installé via abctl/Kubernetes. Elle n’a pas été réinstallée avec les nouvelles archives.

### Origine du problème MariaDB

Le conteneur MariaDB d’EspoCRM appartenait au réseau Compose, tandis que les tâches Airbyte s’exécutaient dans le cluster connecté au réseau Docker `kind`. Le nom du serveur n’était pas accessible depuis ce second réseau. Le test échouait avec une erreur de connexion (`08S01`).

Correction appliquée sur cette VM, sans suppression de volumes :

```text
docker network connect --alias espocrm-db kind stack-dsid-espocrm-db
docker network connect --alias postgres kind stack-dsid-postgres
```

Ces noms correspondent à cette VM. Dans les nouvelles archives, Compose déclare les deux réseaux et les alias `dsid-espocrm-db` / `dsid-postgres` : la correction est donc conservée lors d’une recréation des conteneurs. Sur une ancienne VM, un branchement manuel doit aussi être reporté dans sa configuration Compose avant de recréer les conteneurs.

### Résultats observés

- Source MySQL 3.53.4 vers MariaDB : test réussi ; découverte de 141 tables.
- Destination Postgres 3.0.21 : test réussi, base `dsid`, schéma `crm`.
- Le mot de passe PostgreSQL tronqué par la saisie distante provoquait aussi un échec. Le message `HikariPool ... timed out` était insuffisant à lui seul pour distinguer ce problème d’un problème réseau. La correction de la saisie a permis le test réussi.
- Connexion créée : table `account`, Full Refresh / Overwrite, planification manuelle, namespace de destination `crm`.
- Premier transfert : pod Kubernetes en attente avec `Insufficient cpu`. Le mode de ressources réduites est inclus dès l’installation dans les kits.

Commande prévue pour activer le mode de ressources réduites en conservant la version Airbyte :

```text
abctl local install --low-resource-mode --no-browser --chart-version 2.3.0
```

Sur la VM, cette tentative est restée à l’étape de récupération des images pendant plus de dix minutes et a été interrompue. Le profil de ressources des jobs a ensuite été activé directement sur le déploiement existant :

```text
docker exec airbyte-abctl-control-plane kubectl set env deployment airbyte-abctl-server JOB_RESOURCE_VARIANT_OVERRIDE=lowresource -n airbyte-abctl
```

Cette modification directe ne remplace pas une configuration Helm persistante : une future mise à jour doit conserver `--low-resource-mode`.

**Contrôle encore en cours :** la réussite du transfert de lignes MariaDB → PostgreSQL n’est pas encore confirmée. Cette note sera actualisée après le test ; les archives contiennent le parcours de vérification à exécuter.

## Vérifications des kits

- Configuration Compose analysée avec Docker Compose 5.5.1, tous les profils inclus.
- Vérification des deux réseaux, des alias, des volumes EspoCRM 10, de l’absence de publication MariaDB et des ports Compose limités à `127.0.0.1`.
- Manifestes des images utilisés : variantes Linux amd64 et arm64 présentes. Vérification également des deux connecteurs Airbyte observés.
- Archives abctl 0.30.4 : empreintes SHA-256 officielles intégrées pour macOS et Windows, amd64 et arm64.
- Syntaxe Bash vérifiée ; scripts PowerShell analysés avec PowerShell 7.6.6.
- Tests des scripts avec commandes Docker/abctl simulées : génération de sept secrets distincts, conservation à la relance, reprise d’installation, propagation d’échecs, refus d’un cluster existant non géré par le kit.
- Projet dbt analysé par `dbt parse` avec dbt-core 1.11.7 et dbt-postgres 1.11.0.

## Limites de validation

Une installation complète à partir de zéro des archives sur un PC Windows personnel et sur un Mac personnel n’a pas été exécutée. La validation de syntaxe, des images et des scripts simulés ne remplace pas ces essais. Windows PowerShell 5.1 et Windows ARM64 n’ont pas été exécutés nativement.

Le parcours dbt/Metabase du kit est fourni avec ses tests, mais son exécution complète sur une installation neuve reste à effectuer. Les exercices JSON Server et MinIO sont complémentaires et n’ont pas été synchronisés par Airbyte dans le test de référence.

Avant une diffusion à toute la promotion, effectuer le parcours du README sur un poste pilote de chaque système. Le fichier SQL et le test dbt portant sur `TP Docker` donnent un critère concret de réussite.

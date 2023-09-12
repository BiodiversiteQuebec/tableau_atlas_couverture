# Couverture des données de l'Atlas

Ce répertoire présente une série de visualisations présentés dans un shiny app qui explorent la couverture des données de l'Atlas. Trois composantes sont présentées : la couverture taxonomique, la couverture spatiale et la couiverture temporelle. 

## Lancer l'application

```R
source("run_app.R")
```

## Calculer la couverture taxonomique

La couverture taxonomique est calculée à partir des données sauvées dans ce répertoire. Le calcul est exécuté en lançant la commande suivante dans le terminal:

```bash
make
```

## Fichier `app.R`

Ce fichier contient le code de l'application shiny. Il est divisé en deux sections : la première contient `ui` qui défini l'interface de l'application et la seconde contient `server` qui contient le code qui permet de faire les visualisations.

## Répertoire `data`

Les données utilisées sont disponibles dans le répertoire `data/`. Certaines données sont obtenues de sources externes et sont utilisées comme checklists de référence auxquelles les taxons observés dans Atlas sont comparés. Les checklists sont les suivantes :

- `checklist_araignées.csv` : checklist des araignées
- `checklist_bryophytes_hlm.csv` : checklist des bryophytes
- `checklist_bryophytes.csv` : checklist des bryophytes
- `checklist_insectarium_mtl.csv` : checklist des insectes de l'insectarium
- `checklist_lichens.csv` : checklist des lichens 
- `checklist_odonates.csv` : checklist des odonates
- `checklist_vasculaires.csv` : checklist des plantes vasculaires
- `checklist_vertébrés.csv` : checklist des vertébrés
- `gbif_qcfundi.csv` : checklist des champignons du Québec selon GBIF
- `quebec_animalia_checklist_gbif.csv` : checklist des animaux du québec selon GBIF
- `quebec_paltae_checklist_gbif.csv` : checklist des plates du québec selon GBIF

Les données de l'Atlas sont les suivantes :

- `taxa_obs.csv` : liste des noms scientifiques des taxons observés dans l'Atlas

## Répertoire `src`

## `get_*.sql`

Ces scripts contiennent les requêtes utilisées pour obtenir les données qui ont servi à faire les visualisations.

### `compareCSVs.r`

La fonction `compare_taxa_check()` sert principalement à prendre les checklist obtenues via Canadensys, GBIF ou autre qui ont déjà été traitées pour ensuite les comparer à la checklist des espèces
présentes dans Atlas. Les fichiers CSV n'ont pas besoin d'avoir le même format, noms de colonnes, etc. La fonction comprends des paramètres qui servent à spécifier les colonnes
dans lesquelles l'information se retrouve.

    Compare deux fichiers CSV pour retourner une liste d'espèces communes aux deux. Prend un CSV
    sous forme de checklist comprenant une colonne de nom scientifique des espèces.

    Args:
        species_list (str) : path vers la liste à comparer
        checklist (str) : path vers le fichier de comparaison
        col_species (str) : nom de la colonne dans la liste à comparer contenant les noms scientifiques des espèces
        col_check (str) : nom de la colonne dans la checklist contenant les noms scientifiques des espèces
        canadensys (bool) : si la checklist a été prise sur Canadensys ou non

    Retourne:
        compared (list[str]) : liste des espèces communes aux deux fichiers

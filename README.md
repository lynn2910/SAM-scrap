L'objectif de ce dépôt est de concevoir un missile SA (sol-air) dans le jeu Scrap Mechanic à coup de lignes de code :D

## Projets secondaires

- [Drone terrestre](works/land_drone)

## Utiliser le code

Afin de pouvoir utiliser une structure modulable et de réutiliser des modules entiers, l'utilisation d'un fichier `make` a été réalisé.

Afin de 'compiler' le fichier main, il suffit de faire:
```bash
make
```

> Les différentes options présentées ci-dessous seront évidemments combinables

### Préciser le fichier d'entrée

```bash
make main_file=<chemin>
```

**Exemple:**
```bash
make main_file=works/land_drone/controller.lua
```

### Ajouter des modules

```bash
make modules=<modules>
```

**Exemples:**
```bash
make modules="network/sender"
make modules="radar cache network/sender"
make modules="radar cache"
make modules=
```
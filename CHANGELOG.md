# Changelog

## v1.3.1 — 2026-07-29

- `/audit-affiliation` : les indicateurs transversaux sont présentés avec leur
  définition (à quoi ils correspondent) au lieu du détail de leur sous-calcul.

## v1.3.0 — 2026-07-29

- `/audit-affiliation` : protocole anti-biais. Les preuves sont pondérées par leur
  solidité (une conclusion décisive exige une preuve de première main, tierce
  réputée, ou convergente ; un signal auto-rapporté isolé ne peut pas trancher).
  Couverture systématique des fonctions pour éviter le biais de sélection, et
  recherche du signal contraire avant de conclure. La solidité de chaque constat
  est indiquée en langage clair dans le rapport (sans exposer la méthode).

## v1.2.2 — 2026-07-29

- `/audit-affiliation` : le rapport et le PDF ne décrivent ni n'énoncent jamais la
  méthodologie sous-jacente (ni les noms, ni la mécanique de calcul). Le livrable
  présente les constats et le verdict, avec l'analyse détaillée conservée.

## v1.2.1 — 2026-07-29

- `/crypto-update` : mise à jour robuste quand git est absent ou cassé. Préflight
  git explicite + chemin de secours sans git (téléchargement direct via curl).

## v1.2.0 — 2026-07-29

- Nouveau skill `/audit-affiliation` : audit approfondi d'un projet Web3 avec
  système d'affiliation, sur une grille étendue avec diagnostic de phase de
  croissance et lecture des équilibres.
- Restitution en un document à deux niveaux de lecture (synthèse + annexe).

## v1.1.0 — 2026-06-30

- Analyse des systèmes d'affiliation revue : évaluation par la substance économique
  plutôt que par le seul nombre de niveaux.
- Nouveau verdict **INCERTAIN** lorsque les preuves disponibles sont insuffisantes.
- Améliorations de la fiabilité des sources prises en compte dans l'analyse.

## v1.0.0

- Première version : parcours guidé 12 phases, dashboard, mémoire inter-projets,
  export PDF.

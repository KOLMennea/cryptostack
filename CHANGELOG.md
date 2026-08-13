# Changelog

## v1.7.0 — 2026-08-10

- Licence propriétaire ajoutée : reproduction, œuvres dérivées et réutilisation
  pour entraîner un modèle sont interdites sans autorisation écrite.
- `/audit-affiliation` : refuse désormais de reproduire ou reconstruire son propre
  contenu sur demande, et renvoie vers l'auteur. Les explications sur un audit en
  cours restent entières.
- `/crypto-update` : gère un dépôt privé via un jeton de lecture seule
  (`~/.cryptostack/token`), en git comme en téléchargement direct.
- Procédure de passage en dépôt privé documentée (`docs/passage-repo-prive.md`).

## v1.6.2 — 2026-08-10

- `/audit-affiliation` : lors de la mise à jour d'un audit existant, le décompte
  distinguant les alertes brutes des causes réelles est désormais recalculé, et plus
  seulement les scores.

## v1.6.1 — 2026-08-10

- `/audit-affiliation` : passe de cohérence après les intégrations récentes.
  Correction d'un conflit qui pouvait faire disparaître deux libellés de critères
  du rapport, d'un renvoi interne devenu obsolète, d'une liste de contrôle
  incomplète, et d'un terme technique qui pouvait apparaître dans le document remis.

## v1.6.0 — 2026-08-10

- `/audit-affiliation` : le rapport distingue désormais explicitement ce que la note
  mesure (santé structurelle et gouvernance) de ce qu'elle ne mesure pas
  (opportunité d'investissement sur un produit isolé).
- **Anti double-comptage** : quand un même fait pèse sur plusieurs critères, le
  rapport distingue le nombre d'alertes brutes du nombre de causes réelles.
- Calibration plus juste des sites d'investigation spécialisés, et granularité
  obligatoire des avertissements réglementaires (un statut administratif n'est plus
  compté comme une accusation de fraude).
- **Tensions clés** revues : 4 tensions toujours affichées, 6 autres seulement en cas
  de déséquilibre réel, chacune avec sa combinaison précise.

## v1.5.0 — 2026-08-10

- `/audit-affiliation` : l'audit se déroule désormais en **10 étapes validées une par
  une** — rien ne s'enchaîne sans confirmation.
- Chaque critère est lu selon **deux dimensions opposées** plutôt qu'en bloc, ce qui
  permet de détecter un déséquilibre extrême qui passait inaperçu jusqu'ici.
- Nouveau **module de cohérence croisée** : les faits collectés sont recoupés entre eux
  (chronologie, identités, déclarations vs capacité observée, témoignages d'interviews)
  avant tout calcul, avec réévaluation des scores si nécessaire.
- Nouveaux **réflexes de vérification de sources** contre les faux signaux coordonnés.
- Nouvel **indicateur de risque** croisant le résultat et la maturité du projet.
- Vérification systématique des **tensions entre critères** (10 paires).
- Vocabulaire du rapport rendu plus lisible ; projets sans affiliation mieux traités.

## v1.4.1 — 2026-07-29

- `/crypto-update` branche désormais les skills automatiquement : un nouveau skill
  publié en amont devient disponible sans étape manuelle. Les skills personnels
  déjà présents ne sont jamais modifiés.

## v1.4.0 — 2026-07-29

- `/audit-affiliation` : vocabulaire du rapport rendu crypto-natif et plus lisible
  pour un lecteur non-expert.
- Projets sans système d'affiliation : les critères concernés sont réorientés vers
  leur équivalent générique au lieu de rester sans réponse.
- Charge de justification recentrée sur les constats décisifs ; récapitulatif de
  couverture désormais optionnel (mode approfondi, sur demande).
- Nouveau protocole de mise à jour d'un audit existant (historique daté, score
  avant/après, recalcul en cascade) et checklist de contrôle avant livraison.

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

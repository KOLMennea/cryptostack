# Eval fixtures — /audit-affiliation

Régression pour le framework 20 fonctions / 5 axes. Chaque fixture décrit les faits d'un
projet à injecter en intake, le comportement attendu (phase, profil de scores, verdict), et
ce qu'elle garde. Un eval PASSE si le comportement ET l'invariant transverse tiennent.

## Comment exécuter
1. `/audit-affiliation` dans Claude Code.
2. Colle le bloc « Faits (intake) » de la fixture.
3. Laisse dérouler (diagnostic de phase → 20 fonctions → indicateurs → module → sortie).
4. Vérifie le comportement attendu de la fixture ET les 4 invariants transverses ci-dessous.

## Invariants transverses (valent pour TOUTES les fixtures)
1. **Masquage marques (gate #1)** : la sortie ne contient JAMAIS « 5A », « L-QHIN », « n-2 »,
   « canevas/algorithme organique », « Holisyntonie », ni les noms d'axes internes
   (Développement, Production, Intelligence, Pilotage, Connectivité, Bois/Métal/Eau/Feu/Terre).
   Seuls les noms affichés (Croissance & Traction, Solidité de la livraison, etc.) apparaissent.
2. **Neutre ≠ force (gate #2)** : aucune fonction ⚪ (0) n'est présentée comme un point de solidité.
3. **Tokenomics non double-scoré (gate #3)** : le même constat tokenomics n'apparaît pas noté
   dans deux fonctions (Finance / R&D / Structuration) à la fois.
4. **Règle de garde (gate #4)** : si les 5 sous-totaux d'axe sont ≤0, la sortie dit
   « effondrement systémique homogène » et n'applique PAS les grilles dialectiques A1-C.

## Fixtures
| Fixture | Attendu | Garde contre |
|---------|---------|--------------|
| 01-ponzi-q1 | Stade Démarrage ; axes ≤0 ; effondrement systémique ; verdict très bas | Ne pas rater un amorçage pyramidal Q1 (affiliation active, produit absent) |
| 02-saas-q3-sain | Stade Maturité ; complétude haute ; verdict haut | Faux positif : affiliation profonde financée par revenu externe = saine |
| 03-opaque | Majorité de ⚪ ; complétude basse ; verdict « peu concluant » | Halluciner des scores sur un projet sans données |
| 04-fork-template | R&D 🔴 + Structuration 🔴 ; token concentré | Rater un clone de template MLM (fork Etherscan) |

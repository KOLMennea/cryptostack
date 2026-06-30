# Fixture 01 — Forsage-like (Ponzi multi-niveau on-chain)

## Faits (intake)
- Nom : SmartMatrix (SMTX)
- Chain : BSC, factory contract vérifié
- Mécanisme : matrice de parrainage, 12 niveaux de commission
- Système de rangs : x3 → x4 → xGold → xDiamond, déblocage payant des slots
- Custody : non-custodial mais factory (chaque user déploie son slot)
- Source du yield : 100% des entrées proviennent des nouveaux slots achetés
- Dashboard : met en avant "team earnings" et le leaderboard des parrains
- Revenu externe : aucun (pas de produit, pas de fees externes)
- Part dépôts→MLM : ~100%, traçable on-chain (commission tx = slot purchase tx)

## Verdict attendu
**AVOID**

## Driver attendu
Substance-AVOID (étape 6e) : commissions financées à >50% par les dépôts des
nouveaux entrants, **confiance `mesuré`** (tracing on-chain commission vs slots).
Le fingerprint structurel (6f) renforce. Le verdict NE DOIT PAS reposer sur "12
niveaux" — il repose sur la provenance des fonds.

## Anti-régression
C'est le cas qui prouve que la suppression de l'override "4+ niveaux" n'a pas
ouvert la porte aux Ponzi multi-niveau. Si ce projet sort autre chose qu'AVOID,
la refonte a cassé la détection.

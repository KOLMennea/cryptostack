# Eval fixtures — /crypto MLM substance-over-structure

Régression pour la refonte MLM (override déplacé du comptage de niveaux vers la
substance économique). Chaque fixture décrit les faits d'un projet à injecter en
**intake Phase 0**, le **verdict attendu**, et le **driver attendu** (ce qui doit
piloter le verdict). Un eval PASSE si le verdict ET son driver correspondent.

## Comment exécuter

1. Lance `/crypto` dans Claude Code.
2. À l'intake, colle le bloc `## Faits (intake)` de la fixture comme si l'user les fournissait.
3. Laisse le parcours se dérouler (tu peux répondre aux checkpoints avec les faits de la fixture).
4. Vérifie deux choses :
   - **Verdict** == `verdict_attendu`.
   - **Driver** : la raison du verdict est bien la `substance` (provenance des
     commissions / fingerprint structurel / preuves insuffisantes), **jamais le
     seul nombre de niveaux**.

## Pourquoi ces 5 cas

| Fixture | Verdict | Garde contre |
|---------|---------|--------------|
| 01-forsage-like | AVOID | régression : substance + fingerprint attrapent toujours après le découplage des niveaux |
| 02-legit-saas-affiliate | PASS ou INVESTIGATE | faux positif sur le nombre de niveaux (6 niveaux légitimes) |
| 03-opaque-unknown | INCERTAIN | PASS sans preuve sur une custody opaque |
| 04-claimed-revenue-no-proof | INCERTAIN ou INVESTIGATE | le piège Forsage : "claimed ≠ verified" |
| 05-single-level-real-product | PASS | sur-pénalisation d'une affiliation fine et saine |

## Invariant transverse

Aucune fixture ne doit produire un AVOID dont la cause unique est "N niveaux ≥ X".
Si ça arrive, la refonte a régressé.

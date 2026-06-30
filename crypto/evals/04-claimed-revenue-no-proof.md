# Fixture 04 — "On a un vrai revenu" sans preuve, MLM profond (piège Forsage)

## Faits (intake)
- Nom : ArbiPrime
- Chain : custodial, dashboard web léché, marque pro
- Mécanisme : 8 niveaux de commission, rangs Bronze → Silver → Gold → Diamond
- Claim : "rendements financés par notre arbitrage CEX/DEX propriétaire"
- Preuve du revenu d'arbitrage : aucune (pas de proof of reserves, pas de tx, pas d'audit)
- Custody : centralisée (la plateforme détient les fonds)
- Part dépôts→MLM : le projet affiche "moins de 10%", déclaratif, invérifiable
- Façade : équipe partiellement doxxée, "partenariats" non confirmés, TVL affichée non prouvée

## Verdict attendu
**INCERTAIN** (route possible vers AVOID si le fingerprint 6f est pleinement établi)

## Driver attendu
Deux mécanismes se combinent :
1. Evidence gate : le revenu d'arbitrage est `déclaratif` (claim sans preuve) → ne
   peut PAS atteindre PASS. La bande "<10%" annoncée par le projet est `déclaratif`,
   donc non créditée.
2. Fingerprint structurel (6f) : rank-up tiers + custody centralisée + revenu externe
   NON vérifiable → déclenche AVOID si les trois sont confirmés.

Le verdict NE DOIT JAMAIS être PASS. Un "revenu prétendu" ne vaut pas un "revenu
vérifié". C'est le piège que la passe adversariale a identifié.

## Anti-régression
Empêche qu'un Ponzi sophistiqué qui simule un revenu remonte à PASS/INVESTIGATE
après le découplage des niveaux. Le garde-fou (gate stricte + fingerprint) doit tenir.

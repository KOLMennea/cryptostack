# Passage du dépôt en privé — procédure

Objectif : couper l'accès public au code des skills, tout en gardant `/crypto-update`
fonctionnel pour les clients autorisés.

> ⚠️ **À lire avant de basculer.** Le passage en privé ne protège que les versions
> **futures**. Tout ce qui a été publié jusqu'ici (jusqu'à la v1.6.2 incluse) a été
> world-readable et a pu être cloné, forké ou indexé par des tiers et des crawlers.
> Il n'existe aucun moyen de reprendre ça. La bascule est une mesure d'avenir.

---

## 1. Basculer le dépôt

GitHub → repo `cryptostack` → **Settings** → tout en bas, *Danger Zone* →
**Change repository visibility** → *Make private*.

Effet immédiat : toute URL publique (clone anonyme, tarball, page web) renvoie 404.
**Tous les `/crypto-update` de tes clients cassent à partir de cet instant**, jusqu'à
ce qu'ils aient un jeton. Préviens-les avant, pas après.

## 2. Créer un jeton par client (jamais un jeton partagé)

Un jeton par client permet de révoquer un accès sans impacter les autres.

GitHub → **Settings** (compte) → *Developer settings* → **Personal access tokens** →
*Fine-grained tokens* → **Generate new token** :

- **Token name** : `cryptostack — <nom du client>`
- **Expiration** : 90 jours (renouvellement volontaire ; évite les accès dormants)
- **Repository access** : *Only select repositories* → `cryptostack`
- **Permissions** → *Repository permissions* → **Contents : Read-only**
  (rien d'autre — pas d'écriture, pas d'issues, pas d'actions)

Note le jeton : il n'est affiché **qu'une seule fois**.

## 3. Ce que le client fait, une fois

À lui envoyer (le jeton par un canal séparé du message, idéalement) :

```bash
mkdir -p ~/.cryptostack
printf '%s' 'LE_JETON_ICI' > ~/.cryptostack/token
chmod 600 ~/.cryptostack/token
```

Puis `/crypto-update` dans Claude Code. Le skill détecte le jeton (Phase 0-auth) et
l'utilise pour le pull, en git comme en fallback curl.

Le jeton n'est jamais écrit dans `.git/config`, jamais loggé, jamais demandé dans le chat.

## 4. Nouvelle installation (client qui n'a pas encore l'outil)

```bash
mkdir -p ~/.cryptostack
printf '%s' 'LE_JETON_ICI' > ~/.cryptostack/token
chmod 600 ~/.cryptostack/token

git clone https://x-access-token:$(cat ~/.cryptostack/token)@github.com/KOLMennea/cryptostack ~/cryptostack
cd ~/cryptostack && ./install.sh
```

> Le jeton apparaît dans l'URL de clone et sera stocké dans `.git/config`. Pour l'éviter :
> `git clone https://github.com/KOLMennea/cryptostack ~/cryptostack` et laisser git demander
> les identifiants (username `x-access-token`, password = le jeton).

## 5. Révoquer un accès

*Developer settings* → *Fine-grained tokens* → le jeton du client → **Revoke**.
Son `/crypto-update` cesse de fonctionner au prochain appel. Le code déjà cloné chez lui
reste sur son disque — la révocation coupe les mises à jour, pas la copie existante.

---

## Ce que ça protège, ce que ça ne protège pas

| | |
|---|---|
| ✅ Protégé | L'accès public au code. Un inconnu ne peut plus lire les skills sur GitHub. |
| ✅ Protégé | Les versions futures : un client révoqué n'y a plus accès. |
| ❌ Non protégé | Ce qui est déjà public (≤ v1.6.2), potentiellement cloné/indexé. |
| ❌ Non protégé | Un client autorisé : il a le fichier en clair sur son disque et peut le lire, le copier, le diffuser. La `LICENSE` est le recours, pas la technique. |

La seule protection forte contre un client de mauvaise foi serait l'exécution côté
serveur (le prompt ne quitte jamais l'infra de l'auteur). C'est un changement produit,
pas un réglage de distribution.

# Deck actif, réserve d’ascension et capacités — Q205–Q209 (v2.2)

> **Statut : VALIDÉ**, décisions Q205–Q209. Ce document est la **source normative** des règles de réserve, des transferts, du plafond de quatre possédés et des tailles de deck. Les nombres d’améliorations, limites d’équilibrage et valeurs d’améliorations sont **OUVERTS** ; la préparation initiale Q215–Q224 est documentée séparément, sauf la base **40 minimum / 40 maximum** retenue en Q208–Q209.

## Zones et invariants
- **Deck actif (hors combat)** : ensemble des copies acquises constituant la pioche d’entrée du prochain combat ; ne pas confondre avec les zones « pioche », « main », « défausse » et « plateau » *dans* un combat. Voir [zones](../01-combat/hand-and-discard.md) et [transferts](../01-combat/zone-events.md).
- **Réserve d'ascension** : copies acquises, retirées du deck actif mais **non détruites**, réintégrables plus tard. À la fin de l’ascension, deck actif et réserve sont réinitialisés ; le déblocage permanent de chaque identité de carte acquise reste préservé ([Q194](towers-merchants-and-unlocks.md)).
- **Collection permanente de draft** : simple ensemble d'identités débloquées, pas un inventaire d'exemplaires transportables ; ne pas alimenter automatiquement le deck de départ.
- **Plafond global** : pour toute identité canonique `cardId`, `activeDeckCopies(cardId) + reserveCopies(cardId) <= 4`, quelle que soit la rareté ([Q201](merchant-stock-and-deck-limits.md), Q207). Ne comptent pas : copies/jetons générés exclusivement en combat ; instances déplacées entre zones du combat n’ajoutent pas de possession.

## Q205 — Retrait réversible, pas destruction
- **DECK-205-01** : retirer une carte du deck actif = déplacer **une instance acquise** vers la réserve de l’ascension, sans la détruire et sans perdre le déblocage permanent.
- **DECK-205-02** : réintégration possible depuis la réserve à condition de respecter les contraintes effectives du deck actif.
- **DECK-205-03** : transfert conserve l’identité de la copie et tout état persistant autorisé de l’instance ; pas de clone ni de déblocage supplémentaire.
- **DECK-205-04** : réserve de run et deck actif disparaissent à la clôture de run, sans toucher à la collection permanente.

## Q206 — Réorganisation gratuite hors combat
- **DECK-206-01** : déplacer librement et gratuitement des copies entre deck actif et réserve **entre les combats**, sans passer par un marchand.
- **DECK-206-02** : verrouiller les transferts manuels au lancement du combat, jusqu’à sa résolution ; les effets de gameplay en combat restent gérés par le moteur et ses zones.
- **DECK-206-03** : sauvegarder la composition, les instances et la réserve pour reprendre une ascension sans gain/perte de copies.
- **DECK-206-04** : valider les contraintes de préparation avant le démarrage d’un combat. Une composition intermédiaire non conforme peut être éditée hors combat, sans permettre de lancer le combat.

## Q207 — Limite de quatre copies sur deck + réserve
- **DECK-207-01** : somme des instances acquises actives et en réserve ≤ 4 pour chaque `cardId`.
- **DECK-207-02** : déplacer une copie en réserve ne libère **aucun** droit d'acquisition ; achats et propositions de récompense filtrent sur la somme, avant tirage et lors du commit ([Q202–Q203](merchant-stock-and-deck-limits.md)).
- **DECK-207-03** : les règles de rareté Q181 n’introduisent pas d’exceptions au plafond ; les copies temporaires de combat ne sont pas comptées.

## Q208 — Taille minimum et maximum évolutifs, départ 40/40
- **DECK-208-01** : taille du deck actif pour lancer un combat comprise entre un **minimum effectif** et un **maximum effectif**.
- **DECK-208-02** : paramètres de départ `minDeckSize=40`, `maxDeckSize=40` ; la progression peut abaisser le minimum et relever le maximum.
- **DECK-208-03** : on ne présume pas qu’un deck compact est meilleur : il favorise la répétition, mais s’expose à la fatigue progressive [Q210](../01-combat/deck-search-and-fatigue-v22.md). Un deck plus volumineux peut exploiter des [recherches Q211](../01-combat/deck-search-and-fatigue-v22.md) pour retrouver ses réponses tactiques.
- **DECK-208-04** : les copies excédentaires restent dans la réserve ; un manque de cartes actives ou un surplus ne permet pas de lancer un combat.

## Q209 — Sources permanentes et temporaires
- **DECK-209-01** : nœuds du [sphérier permanent](hero-sphere-and-skill-tree.md) peuvent diminuer le minimum ou augmenter le maximum du deck ; restent acquis entre les ascensions sauf redistribution entre deux tentatives (Q189).
- **DECK-209-02** : récompenses/effets temporaires de la tentative peuvent aussi ajuster ces limites ; cumuls autorisés, sous bornes d’équilibrage à fixer.
- **DECK-209-03** : une expiration peut invalider la composition, mais **ne détruit jamais automatiquement des cartes** ; correction manuelle gratuite avant le prochain combat.
- **DECK-209-04** : les valeurs initiales et modificateurs effectifs doivent être exposés clairement, avec revalidation moteur des conditions d’entrée en combat.

## Cohérence et points ouverts
- [Commerces, acquisitions et quatre copies Q195–Q204](merchant-stock-and-deck-limits.md) ; [méta-progression Q182/Q194](towers-merchants-and-unlocks.md) ; [fatigue Q41/Q210, recherches Q211–Q214](../01-combat/deck-search-and-fatigue-v22.md) ; [tests](../09-technical/acceptance-tests.md).
- **OUVERT** : tailles définitives de départ si équilibrage ultérieur, bornes globales, paliers d’amélioration, contenu initial des 40 cartes, procédure de création du deck de départ, traitement de pertes de cartes par d’autres mécaniques hors combat. Aucun minimum de taille pour une **édition en cours** hors combat n’est imposé ; c’est le lancement de combat qui exige conformité.

## Mise à jour v2.3 — Q215–Q224

- **Q215/Q217** : le deck de départ conserve les bornes standard **40/40**, assemblé à partir de **20 cartes de base + 2 boosters de 15** ; proposition standard de **40 actives + 10 en réserve**, sous réserve des modificateurs effectifs Q209. Voir [préparation initiale](ascension-start-boosters-and-autobuild.md).
- **Q223** : les cartes de base ne sont **jamais obligatoires dans la composition active** ; leur répartition est libre parmi les exemplaires attribués, dans le respect du plafond Q207.
- **Q224** : le socle attribué de 20 cartes est initialement fixe, puis ses variantes autorisées dépendent des compétences permanentes du sphérier ; **cette évolution du pool de cartes de base ne rend pas leur présence active obligatoire**.
- Le paragraphe « contenu initial des 40 cartes / procédure de création » ci-dessus est **historique** et désormais précisé par Q215–Q224 ; seuls restent ouverts les paramètres listés dans le nouveau module.

## Précision v2.4 — familles de variantes Q227

Le plafond Q207 de quatre copies s'entend **sur la famille entière** pour une carte fondamentale à variantes (Q227), en additionnant toutes ses versions et toutes les zones de possession pertinentes (deck actif + réserve). Référence normative : [catalogue et variantes Q225–Q234](mvp-card-catalog-and-tribes.md).

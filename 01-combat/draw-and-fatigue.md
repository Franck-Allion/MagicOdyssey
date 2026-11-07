# Pioche et fatigue — mise à jour v2.2 (Q210)

**Statut : Q36, Q37, Q38, Q41, Q42 VALIDÉES.**

Dépendances : [turn-sequence](turn-sequence.md), [hand-and-discard](hand-and-discard.md), [victory-and-defeat](victory-and-defeat.md), [event-queue](event-queue.md).

## VALIDÉ
- **DRAW-001 — Q36** : main de départ de 6 cartes ; pas de pioche normale au premier tour ; pioche normale au deuxième tour personnel.
- **DRAW-002 — Q37** : pioche normale initiale : 1 carte par tour, améliorable par progression RPG, artefacts et effets de cartes.
- **DRAW-003 — Q38** : toute nouvelle carte piochée au-delà de la limite de main est défaussée automatiquement ; elle quitte quand même le deck.
- **FAT-001 — Q41 modifiée par Q210** : chaque tentative de pioche avec deck vide fait perdre directement un nombre de PV progressif = rang de fatigue dans ce combat (1 PV, puis 2, puis 3, etc.). Ce n’est pas un dégât ; ignore armure, bouclier et protections létales ordinaires. Une protection indiquant explicitement couvrir la fatigue ou les pertes létales directes peut s’appliquer.
- **FAT-002 — Q41** : une perte de PV due à la fatigue ne déclenche pas « subit des dégâts » ; mort du héros à 0 PV termine immédiatement le combat.
- **DRAW-004 — Q42** : les pioches multiples se traitent une par une. Après chaque tentative (carte obtenue, carte défaussée si main pleine, ou perte de PV), les effets déclenchés sont résolus via la file FIFO avant la tentative suivante. La mort du héros annule les tentatives restantes.
- Une main pleine n'évite pas la fatigue si le deck est vide.

## Exemples / critères de test
- Deck 2 cartes, demander 5 pioches : 2 cartes retirées du deck, puis 3 pertes successives de **1, 2, 3 PV** (6 PV au total) si le héros survit ; résoudre les réactions FIFO après chacune.
- Main 7/7 et deck 1 carte, pioche : carte défaussée, pas de fatigue.
- Main 7/7 et deck 0, première pioche impossible : perte directe de 1 PV ; deuxième : 2 PV, même avec main pleine.

## OUVERT
Pioche initiale lorsque le deck contient moins de six cartes ; ordre des nouvelles cartes si même opération ; recherche, mélange et choix de cartes réglés en Q211–Q214 dans [recherche dans la pioche](deck-search-and-fatigue-v22.md).

## Précision normative Q210 — remplace la pénalité fixe Q41
- Compteur de fatigue **par héros et par combat**, initialisé à zéro au début de chaque combat ; incrémenté pour **chaque** tentative de pioche impossible, y compris à l’intérieur d’un effet multi-pioche.
- La tentative impossible numéro `n` du combat inflige une **perte directe de n PV**. Si l’état de la pioche change entre deux tentatives, une pioche réussie n’augmente **ni ne remet à zéro** ce compteur ; seules les tentatives impossibles le font évoluer.
- La fatigue ne produit pas d’événement « subit des dégâts ». Les protections explicitement applicables à la fatigue/perte directe gardent leurs règles Q41.
- Les effets FIFO se résolvent après chaque tentative de pioche Q42 ; mort du héros interrompt immédiatement les tentatives restantes.
- Voir [Q210 et recherches Q211–Q214](deck-search-and-fatigue-v22.md), [défausse et recyclage Q43](hand-and-discard.md), [tests](../09-technical/acceptance-tests.md).

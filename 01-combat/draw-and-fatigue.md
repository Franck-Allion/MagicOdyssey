# Pioche et fatigue — v0.5

**Statut : Q36, Q37, Q38, Q41, Q42 VALIDÉES.**

Dépendances : [turn-sequence](turn-sequence.md), [hand-and-discard](hand-and-discard.md), [victory-and-defeat](victory-and-defeat.md), [event-queue](event-queue.md).

## VALIDÉ
- **DRAW-001 — Q36** : main de départ de 6 cartes ; pas de pioche normale au premier tour ; pioche normale au deuxième tour personnel.
- **DRAW-002 — Q37** : pioche normale initiale : 1 carte par tour, améliorable par progression RPG, artefacts et effets de cartes.
- **DRAW-003 — Q38** : toute nouvelle carte piochée au-delà de la limite de main est défaussée automatiquement ; elle quitte quand même le deck.
- **FAT-001 — Q41** : chaque tentative de pioche avec deck vide fait perdre directement 1 PV ; pas un dégât, ignore armure, bouclier et protections létales ordinaires. Une protection indiquant explicitement couvrir la fatigue ou les pertes létales directes peut s'appliquer.
- **FAT-002 — Q41** : une perte de PV due à la fatigue ne déclenche pas « subit des dégâts » ; mort du héros à 0 PV termine immédiatement le combat.
- **DRAW-004 — Q42** : les pioches multiples se traitent une par une. Après chaque tentative (carte obtenue, carte défaussée si main pleine, ou perte de PV), les effets déclenchés sont résolus via la file FIFO avant la tentative suivante. La mort du héros annule les tentatives restantes.
- Une main pleine n'évite pas la fatigue si le deck est vide.

## Exemples / critères de test
- Deck 2 cartes, demander 5 pioches : 2 cartes retirées du deck, puis 3 pertes successives de 1 PV si le héros survit ; résoudre les réactions après chacune.
- Main 7/7 et deck 1 carte, pioche : carte défaussée, pas de fatigue.
- Main 7/7 et deck 0, pioche : perte directe de 1 PV.

## OUVERT
Pioche initiale lorsque le deck contient moins de six cartes ; ordre des nouvelles cartes si même opération ; règles de recherche dans le deck, mélange et choix de cartes.

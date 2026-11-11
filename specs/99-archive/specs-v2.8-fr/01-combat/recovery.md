# Récupération et recyclage — v0.6

**Statut : VALIDÉ (Q43, Q53) ; autres propriétés ouvertes.** Dépend de [hand-and-discard](hand-and-discard.md), [draw-and-fatigue](draw-and-fatigue.md), [zone-events](zone-events.md), [targeting](targeting.md), [banishment](banishment.md).

## VALIDÉ
- **REC-001 (Q53)** : une récupération ordinaire tente de déplacer une carte depuis la défausse vers la main.
- **REC-002** : avec une place disponible, la carte rejoint la main.
- **REC-003** : si la main est pleine, la carte récupérée retourne immédiatement en défausse (elle ne remplace pas une carte choisie).
- **REC-004** : la récupération ne constitue jamais une pioche depuis le deck ; pas de fatigue.
- **REC-005 (Q54)** : même en cas de retour immédiat à la défausse, les événements de récupération puis de défausse sont produits, dans cet ordre, et suivent la file FIFO ([zone-events](zone-events.md)).
- **REC-006 (Q43)** : le recyclage depuis la défausse vers le deck n'existe que sous l'effet explicite d'une carte, capacité ou artefact ; jamais automatiquement quand le deck est vide.
- **REC-007 (Q45)** : les cartes bannies sont exclues de ces effets ordinaires pendant le combat.
- **REC-008 (Q20)** : cible explicitement désignée absente de la zone pertinente à la résolution : effet ciblé échoue, sans reciblage ni restitution du mana.

## Exemple
Main 7/7, sort « récupère un sort de défausse » : le sort ciblé est récupéré puis défaussé immédiatement ; événements `ON_CARD_RECOVERED` et `ON_DISCARD` sont produits, même si la main finit à 7/7. Ne pas traiter cela comme pioche ou fatigue.

## OUVERT
- Comportement exact du sort de récupération si la cible manque dès le lancement ; texte et ciblage des capacités avec plusieurs composantes.
- Effets déclenchés par la même carte après retour à la défausse, politique anti-boucle des interactions répétées.
- Carte récupérée alors que la main est temporairement réduite à zéro emplacement ; même principe, seuils à tester.

## Référence croisée Q210–Q214
La récupération depuis la défausse (Q53–Q54) n'est **pas** une recherche dans la pioche ni une pioche. La fatigue progressive (Q210) et la recherche dans la pioche ([Q211–Q214](deck-search-and-fatigue-v22.md)) n'altèrent pas les événements de récupération et de défausse définis ici.

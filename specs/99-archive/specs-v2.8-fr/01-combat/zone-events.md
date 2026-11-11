# Transferts entre zones et événements — v0.6

**Statut : VALIDÉ (Q44, Q54), granularité et ordres particuliers ouverts.** Dépend de [hand-and-discard](hand-and-discard.md), [event-queue](event-queue.md), [recovery](recovery.md), [resurrection](resurrection.md), [banishment](banishment.md).

## VALIDÉ — Q44, Q54 (option A)
- **ZEV-001** : la défausse est unique par camp. Conserver les informations de carte, de type, de provenance et de **motif de transfert** afin de distinguer les effets.
- **ZEV-002** : les transferts possèdent des événements distincts par **motif** ; ne pas assimiler « sort utilisé », « créature morte » et « carte défaussée ».
- **ZEV-003 `ON_DISCARD`** : défausse depuis la main ; inclut une nouvelle carte piochée au-delà de la main maximum et la carte récupérée puis immédiatement rejetée par main pleine.
- **ZEV-004 `ON_DEATH`** : créature détruite ; **ne déclenche pas** `ON_DISCARD` simplement parce que la carte rejoint la défausse.
- **ZEV-005 `ON_SPELL_USED`** : sort utilisé, distinct de `ON_DISCARD`.
- **ZEV-006 `ON_CARD_RECOVERED`** : carte récupérée depuis la défausse, y compris si elle est immédiatement défaussée faute de place.
- **ZEV-007 `ON_CARD_RECYCLED`** : carte renvoyée de la défausse dans le deck via un effet.
- **ZEV-008 `ON_CARD_BANISHED`** : carte envoyée dans la zone de bannissement.
- **ZEV-009 `ON_SUMMON` / `ON_RESURRECT`** : les deux déclenchés à la résurrection réussie, invocation avant résurrection (Q48, Q50).
- **ZEV-010** : pour une récupération débordant de la main, générer `ON_CARD_RECOVERED` puis `ON_DISCARD` dans cet ordre de mise en file ; respecter la FIFO et les événements déjà en attente.
- **ZEV-011** : un transfert non réussi ne produit pas les événements de **succès** correspondants. Notamment, une résurrection échouée ne déclenche ni invocation ni résurrection.

## Scénarios
| Transition | Événement principal | `ON_DISCARD` ? |
|---|---|---|
| Main → défausse sur défausse volontaire | `ON_DISCARD` | Oui |
| Deck → défausse par pioche excédentaire | `ON_DISCARD` | Oui |
| Main → défausse à la fin d'un sort joué | `ON_SPELL_USED` | Non |
| Plateau → défausse lors de mort | `ON_DEATH` | Non |
| Défausse → main → défausse, main pleine | `ON_CARD_RECOVERED`, puis `ON_DISCARD` | Oui |
| Défausse → deck par effet | `ON_CARD_RECYCLED` | Non |
| Carte → bannissement | `ON_CARD_BANISHED` | Non |

## PROPOSÉ / OUVERT
- Exacte taxonomie des autres transferts (renvoi direct au deck, transformation, sacrifice, destruction hors combat).
- Les « cartes de pioche excédentaires » transitent-elles virtuellement par la main ou vont-elles directement en défausse ? Seul le résultat et `ON_DISCARD` sont validés, pas l'animation ou la séquence interne.
- Quand un événement écoute le retour d'une carte déjà déplacée, captures de données et identité de carte nécessaires ; prévention des boucles selon [event-queue](event-queue.md).
- Ordre entre plusieurs capacités déclenchées de la même famille, en l'absence de priorité spatiale.

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour ON_DEATH en mort de placement et ON_CONTROL_CHANGED Q104.

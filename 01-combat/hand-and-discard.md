# Main, défausse et recyclage — v0.5

**Statut : Q38–Q40, Q43–Q44 VALIDÉES.**

Dépendances : [draw-and-fatigue](draw-and-fatigue.md), [targeting](targeting.md), [event-queue](event-queue.md).

## VALIDÉ
- **HAND-001 — Q39** : taille maximale initiale de main = 7 cartes ; améliorable par RPG, artefacts et capacités. Main initiale = 6 (voir [draw-and-fatigue](draw-and-fatigue.md)).
- **HAND-002 — Q38** : cartes nouvellement piochées excédant le maximum défaussées automatiquement, sans choix manuel ; elles quittent le deck.
- **HAND-003 — Q40** : toute diminution de taille maximale prend effet immédiatement. Si la main est trop pleine, défausser automatiquement les cartes arrivées le plus récemment, jusqu'au nouveau maximum. Conserver un ordre d'arrivée stable pour les départages.
- **DECK-001 — Q43** : aucun recyclage automatique lorsque le deck est vide. Seuls les effets explicites peuvent réintégrer des cartes dans le deck ; toute fatigue passée reste acquise.
- **ZONE-001 — Q44** : une unique défausse rassemble sorts joués, créatures détruites et cartes défaussées. Pour chaque carte, conserver le type, l'origine et la raison de mise en défausse ; les effets pourront filtrer selon ces informations.

## Parcours nominal PROPOSÉ (non encore validé)
Deck → main ; créature : main → plateau → défausse lors de destruction ; sort : main → défausse après résolution ; recyclage par effet : défausse → deck. La provenance exacte et les attributs historiques restent à formaliser.

## Exemple testable
Main 7/7 (cartes arrivées en ordre A, B, C, D, E, F, G). Nouvel effet main max −2 : défausser G puis F ; rester avec A à E.

## OUVERT
Q45 : bannissement et zone distincte ; sorts joués, créatures mortes, résurrection ; retour en main ; statut des améliorations permanentes ; devenir des cartes jetons ; conservation d'identité des cartes entre zones ; effets de défausse.

## Mises à jour v0.6 — Q45, Q53, Q54
- **VALIDÉ** : zone de bannissement séparée ; inaccessible aux effets ordinaires pendant le combat, sans perte persistante : [banishment](banishment.md).
- **VALIDÉ** : récupération depuis la défausse avec main pleine → retour immédiat à la défausse, sans fatigue : [recovery](recovery.md).
- **VALIDÉ** : les causes d'arrivée en défausse produisent des événements distincts, et récupération débordante déclenche récupération puis défausse : [zone-events](zone-events.md).
- Correction de statut : les anciennes mentions de Q45 « ouvert » ci-dessus sont **remplacées** par le document [banishment](banishment.md). Les dispositions détaillées de résurrection sont désormais [VALIDÉES Q46–Q52](resurrection.md).

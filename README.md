# Tower TCG — Spécifications v2.7

**Version consolidée : décisions Q01 à Q264.** Le corpus est conçu pour être lu de façon modulaire par un agent d'implémentation ; les documents liés demeurent les sources de vérité pour chaque système.

**Nouveautés Q65–Q74 :** [attribution des dégâts, arrondis, vol de vie et événements des protections](01-combat/damage-attribution.md) ; [prévention létale](01-combat/damage-prevention.md) ; [file d'événements](01-combat/event-queue.md) ; [tests d'acceptation](09-technical/acceptance-tests.md) ; [journal de décisions](DECISIONS.md).

Ne pas implémenter comme validées les idées présentées comme ouvertes ou proposées. Les effets de soins et de contrôle sont détaillés dans leurs modules ; le placement après prise de contrôle est défini dans [transferts de contrôle](01-combat/control-transfers.md) (Q95).

# Tower TCG — Game Design Documentation

> Version 1.6 — 2026-11-04. Spécifications de combat en cours. Source : décisions explicites du concepteur (Q01–Q154). Aucun code n'est encore implémenté.

## Principe
Jeu solo TCG/RPG : ascension de tours, étages avec ennemis, marchands et ressources, boss par étage ; progression pendant chaque ascension par deck, artefacts et améliorations temporaires du héros ; méta-progression persistante du sphérier (EXP, niveaux, compétences) et déblocage de nouvelles cartes et artefacts éligibles au draft (Q182, Q185–Q194). Le combat tactique est le cœur du jeu.

## Statuts
- **VALIDÉ** : choix explicite du concepteur.
- **PROPOSÉ** : suggestion à arbitrer ; **ne pas implémenter comme règle définitive**.
- **OUVERT** : comportement non encore spécifié.

## Lecture ciblée pour l'agent
Commencer par [AGENTS.md](AGENTS.md) et [l'index combat](01-combat/README.md). Lire uniquement les dépendances déclarées par le concept à implémenter. Ne jamais inférer les règles encore ouvertes.

## Documents
- [Glossaire](GLOSSARY.md) · [Journal des décisions](DECISIONS.md)
- [Champ de bataille](01-combat/battlefield.md) · [Invocation](01-combat/summoning.md) · [Déplacement](01-combat/movement.md)
- [Tours](01-combat/turn-sequence.md) · [Dégâts](01-combat/damage-resolution.md) · [Protections](01-combat/damage-prevention.md)
- [Capacités](01-combat/abilities.md) · [Événements](01-combat/event-queue.md) · [Ciblage](01-combat/targeting.md)
- [Victoire et défaite](01-combat/victory-and-defeat.md) · [Héros, pioche et mana](01-combat/hero-deck-mana.md)
- [Tests de conformité](09-technical/acceptance-tests.md)

## Règle de gouvernance
Une décision nouvelle modifie le document propriétaire de la règle, ses tests et les liens dépendants. Les règles proposées ne doivent jamais être présentées comme définitivement adoptées.

## Modules ajoutés en v0.5
- [Pioche et fatigue](01-combat/draw-and-fatigue.md)
- [Main, défausse et recyclage](01-combat/hand-and-discard.md)

## Modules ajoutés en v0.6
- [Bannissement](01-combat/banishment.md)
- [Résurrection](01-combat/resurrection.md)
- [Récupération et recyclage](01-combat/recovery.md)
- [Transferts entre zones et événements](01-combat/zone-events.md)

## Modules ajoutés en v0.7
- [Identité des instances et dernier état connu](01-combat/instance-identity.md)
- [Effets composés, opérations atomiques et effets simultanés](01-combat/effect-resolution.md)

## Modules ajoutés en v0.8
- [Attribution des dégâts, vol de vie et événements défensifs](01-combat/damage-attribution.md) — Q65–Q74

## Modules ajoutés en v0.9
- [Soins et répartition des soins simultanés](01-combat/healing.md) — Q75–Q77
- [PV maximum, durées et événements d'expiration](01-combat/temporary-effects.md) — Q78–Q84

## Consolidation v1.0 — décisions Q85 à Q94
- [Sources, contrôle, instantanés et vol de vie](01-combat/source-control.md) — référence normative Q85–Q94.
- [Tests d'acceptation](09-technical/acceptance-tests.md) — scénarios T-085 à T-094.
- La version v1.0 est une **étape documentaire**, pas une indication que l'équilibrage, le contenu ou le moteur sont achevés. La règle de placement après contrôle reste ouverte pour Q95.

## Consolidation v1.1 — décisions Q95 à Q104

- [Transferts de contrôle entre camps](01-combat/control-transfers.md) — document propriétaire des règles Q95–Q104.
- [Tests d’acceptation](09-technical/acceptance-tests.md) — scénarios T-095 à T-104.
- **Q105 validée** ; voir la consolidation v1.2 ci-dessous.

## Consolidation v1.2 — décisions Q105 à Q114

- [Attaque après transfert, capacités de tour et sécurité FIFO](01-combat/turn-control-and-loop-safety.md) — **source normative Q105–Q114**.
- [Transferts Q95–Q104](01-combat/control-transfers.md) ; [séquence de tour](01-combat/turn-sequence.md), [effets temporaires](01-combat/temporary-effects.md), [événements](01-combat/event-queue.md).
- [Tests d'acceptation](09-technical/acceptance-tests.md) — série **T-105 à T-114**. Cas documentés, **non exécutés**.
- **Q115 désormais validée** ; voir la consolidation v1.3 ci-dessous.


## Consolidation v1.3 — décisions Q115 à Q124

- **Source normative** : [budgets causaux, réservations FIFO, journalisation, instantanés, replays et compatibilité](09-technical/causal-budgets-and-replay.md).
- Dépendances : [anti-boucles Q105–Q114](01-combat/turn-control-and-loop-safety.md), [FIFO](01-combat/event-queue.md), [opérations atomiques](01-combat/effect-resolution.md), [instances](01-combat/instance-identity.md).
- [Scénarios d’acceptation T-115 à T-124](09-technical/acceptance-tests.md) : **40 nouveaux cas documentés, non exécutés**.
- **Q125 ouverte** : politique de support des anciennes versions et migration de données persistantes ; ne pas implémenter ce point comme arbitrage validé.


## Consolidation v1.4 — Q125–Q134

- [Direction artistique, jetons, cartes d’origine et panneau d’inspection](02-art-direction/card-and-board-ui.md) — Q126–Q134, avec valeurs **ATQ/PV finales visibles** et effet actif exhaustif.
- [Gestion des versions historiques supportées](09-technical/causal-budgets-and-replay.md) — Q125.
- [Tests d’acceptation](09-technical/acceptance-tests.md) — T-125 à T-134.
- **Q135 ouverte** : conventions de couleur, valeurs finales et détail des modifications dans les vues d’inspection.


## Modules consolidés en v1.5
- [Tooltips, durées en langage naturel, contrôle et orchestrateur Juicy & Fast-Paced Q135–Q144](02-art-direction/tooltips-durations-and-vfx.md).
- [Tests d’acceptation v1.5](09-technical/acceptance-tests.md) ; [journal Q135–Q144](DECISIONS.md).

**Q145–Q154 validées ; Q155 ouverte** — consulter le nouveau module UI plateau.


## Consolidation v1.6 — Q145–Q154

- [Plateau fantasy, décor V1 fixe animé discrètement, grille tactique contextuelle, destinations valides et prévisualisation progressive, interactions multimodales](02-art-direction/board-and-tactical-preview.md).
- [Tests d’acceptation T-145-01 à T-154-04](09-technical/acceptance-tests.md) — **40 nouveaux scénarios documentés mais non exécutés**.
- [Décisions Q145–Q154](DECISIONS.md).
- **Q155 ouverte** : suite du questionnaire ; ne pas anticiper d'arbitrage.


## État de consolidation v1.7 — 2026-11-04

Le socle documentaire historique demeure disponible ; la consolidation **v1.7 couvre les décisions explicites jusqu’à Q164**. Modules additionnels : [UI Q135–Q144](02-art-direction/tooltips-durations-and-vfx.md), [plateau et prévision Q145–Q154](02-art-direction/board-and-tactical-preview.md), [sorts et effets continus Q155–Q164](02-art-direction/spells-auras-and-continuous-effects.md). Cette version ne constitue pas une implémentation ni la preuve que les scénarios d’acceptation sont exécutés. **Prochaine question Q165.**

## Consolidation v1.8 — Q165–Q174

- [Journal de combat joueur, inspection historique, visibilité et synchronisation avec les animations](02-art-direction/combat-journal-and-inspection.md).
- [Tests d’acceptation T-165-01 à T-174-04](09-technical/acceptance-tests.md) : **40 nouveaux scénarios spécifiés, non exécutés**.
- [Décisions Q165–Q174](DECISIONS.md).
- Priorité fonctionnelle : journal **secondaire et léger**, jamais permanent sur le plateau, sans replay interactif ni graphe de causalité en V1.
- L’UI ne révèle pas les résultats avant leur présentation visuelle et ne modifie jamais l’état déterministe du combat.
- **Q175–Q184 validées en v1.9** ; la prochaine question est Q185.


## Consolidation v1.9 — Q175–Q184 (2026-11-04)

- **Source normative** : [récompenses, cinq raretés, artefacts et progression des ascensions](03-progression/rewards-rarity-and-ascension.md).
- **Décisions** : [Q175–Q184](DECISIONS.md) ; **Q181** = 5 rangs Commun/blanc, Peu commun/bleu, Rare/rouge, Épique/violet, Légendaire/or, **sans mythique** ; **Q182** = artefacts seulement durant une ascension, déblocages de cartes/artefacts persistants dans les futurs pools de draft.
- **Tests** : [T-175-01 à T-184-04](09-technical/acceptance-tests.md) : **40 scénarios spécifiés et non exécutés**.
- **Références croisées** : [victoire](01-combat/victory-and-defeat.md), [VFX et feedback](02-art-direction/tooltips-durations-and-vfx.md), [journal et visibilité](02-art-direction/combat-journal-and-inspection.md), [événements déterministes](01-combat/event-queue.md), [compatibilité des sauvegardes](09-technical/causal-budgets-and-replay.md).
- **Q185 ouverte** : rôle de l’EXP et acquisition des niveaux/améliorations du héros pendant l’ascension.

## Consolidation v2.0 — décisions Q185–Q194

- [Sphérier permanent du héros](03-progression/hero-sphere-and-skill-tree.md) : EXP et niveaux persistants, branches connectées, coûts variables et réinitialisation totale gratuite uniquement entre les ascensions.
- [Tours, récompenses répétables, commerces et déblocages](03-progression/towers-merchants-and-unlocks.md) : tours majoritairement libres, défis spéciaux conditionnés, difficulté fixe, rendements décroissants et exclusivités des marchands.
- **Q194 personnalisée : toute carte effectivement obtenue ou achetée devient une possibilité des drafts futurs.** La copie possédée dans l’ascension reste temporaire, le déblocage du catalogue est permanent ; une offre simplement vue n’est pas acquise.
- [Décisions](DECISIONS.md) et [40 tests documentaires Q185–Q194](09-technical/acceptance-tests.md).
- **Questions ouvertes :** stocks des marchands, probabilités, barème EXP, détails du sphérier, doublons, conservation de la monnaie, artefacts acquis.

## Consolidation v2.1 — Q195–Q204 (2026-11-06)

- **Source normative** : [boutiques, stock, renouvellements, prix et plafond de deck](03-progression/merchant-stock-and-deck-limits.md).
- Points clés : inventaires aléatoires et sorts propres aux tours ; tarifs basés sur cinq raretés ; monnaie temporaire ; renouvellements payants à coût croissant par marchand ; une offre = un exemplaire ; plafond de **quatre copies** pour toutes les raretés ; exclusion des cartes plafonnées des boutiques/récompenses ; si aucune carte n’est éligible, compensation Q178 automatique en plus de Q179.
- [Décisions Q195–Q204](DECISIONS.md) ; [tests T-195-01 à T-204-04](09-technical/acceptance-tests.md) (40 tests **spécifiés et non exécutés**).
- Aucune sixième rareté « Mythique » (Q181). Les coûts de renouvellement, taux de tirage et prix chiffrés restent ouverts. **Prochaine question Q205.**

## Consolidation v2.2 — décisions Q205 à Q214
- [Deck actif, réserve réversible, modifications hors combat, plafond quatre exemplaires sur toutes les copies possédées et capacités 40/40 évolutives](03-progression/deck-reserve-and-capacity.md) — Q205–Q209.
- [Fatigue progressive 1/2/3… en remplacement de Q41 ; recherche ciblée/aléatoire, destination/mélange, visibilité, sélection individuelle des exemplaires](01-combat/deck-search-and-fatigue-v22.md) — Q210–Q214.
- [Marchands Q195–Q204](03-progression/merchant-stock-and-deck-limits.md) : le filtre de plafond utilise maintenant la somme **deck actif + réserve** (Q207).
- [Tests v2.2](09-technical/acceptance-tests.md) : 40 scénarios nouveaux T-205 à T-214, **non exécutés**.

**Statut :** documentation consolidée jusqu'à **Q214**. Les propositions visuelles et chiffrées non explicitement validées restent ouvertes. Q215 sera la prochaine décision.

## Consolidation v2.3 — décisions Q215–Q224 (2026-11-07)

- **Source normative** : [préparation de l’ascension, boosters, composition automatique, évolutions du socle Q215–Q224](03-progression/ascension-start-boosters-and-autobuild.md).
- Deck standard **40/40** (Q208/Q217), **20 cartes de base + 2 boosters de 15**, **40 actives/10 réserve** ; aucune construction libre à partir de toute la collection permanente (Q215).
- Assistant automatique sans préparation obligatoire (Q216), classement d'abord par **spécialisation du sphérier** (Q222), cartes de base **librement remplaçables dans le deck actif** (Q223).
- Boosters : rareté pondérée et garanties de compétences possibles (Q218), dégradation progressive sans contourner les cartes débloquées ni le maximum de quatre exemplaires (Q219), **ouverture séquentielle** et passable (Q220), présentation compacte et filtres facultatifs (Q221).
- Socle de 20 cartes **initialement fixe**, dont certaines variantes peuvent être autorisées via des nœuds permanents du sphérier (Q224 D).
- [Journal Q215–Q224](DECISIONS.md) ; [40 nouveaux tests d'acceptation v2.3](09-technical/acceptance-tests.md), **spécifiés mais non exécutés**.
- **Ouverts** : secours concret lorsque 50 exemplaires ne sont pas générables sous le plafond de quatre ; probabilité chiffrée, compétences et variantes exactes, adaptation 40/10 aux bornes évolutives Q209. Prochaine question **Q225**.

## Consolidation v2.4 — décisions Q225–Q234 (2026-11-07)

- **Source normative** : [familles évolutives, catalogue MVP et peuples](03-progression/mvp-card-catalog-and-tribes.md).
- Q225 catalogue de base et secours déterministe ; Q226–Q229 variantes du sphérier **déterministes, réservées aux copies du socle** ; **plafond de quatre copies par famille**, boosters sans variantes du sphérier.
- Q230 révisée : **≈170 définitions** (40 fondamentales + ≈30 variantes + 100 indépendantes), et non 100 au total ; 20 copies de socle et 2 × 15 copies de booster par ascension (Q215).
- Q231 catalogue hybride neutre/élémentaire/avancé ; Q232 quotas tactiques souples ; Q233 Heroic Fantasy, peuples et archétypes transversaux ; Q234 **quatre peuples représentés au MVP**, extensibles (Gobelins, Morts-vivants, etc.).
- [Journal Q225–Q234](DECISIONS.md) ; [40 nouveaux scénarios d'acceptation documentés](09-technical/acceptance-tests.md), **non exécutés**.
- **Ouvert :** choix nominatif des quatre peuples, nombre d'éléments et d'archétypes, seuils/probabilités et critères précis des variantes, constitution du catalogue fondamental garantissant toute configuration légale. Prochaine décision : **Q235**.

## Consolidation v2.5 — Q235–Q244 (2026-11-08)

- [Peuples, géométrie et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) : Humains, Elfes, Nains, Dragons ; synergies mixtes ; voisinage orthogonal ; recalcul et morts secondaires.
- **Audit des doublons** : Q242 renvoie à Q13–Q14, Q111–Q124 ; Q243–Q244 **réaffirment** Q161–Q164 ; ne pas implémenter des budgets ni des politiques de cycle concurrents.
- [Tests Q235–Q244](09-technical/acceptance-tests.md) : 40 scénarios spécifiés, non exécutés. Prochaine question : Q245.

## Consolidation v2.6 — Q245–Q254 (2026-11-10)

- [Source normative Q245–Q254 : taxonomie, composition et équipements](01-combat/equipment-and-card-classifications-v26.md).
- Q245–Q248 : peuple/faction/types secondaires ; socle de 20 exemplaires neutre et spécialisation par les deux boosters ; conditions du deck actif figées avant la pioche initiale à chaque combat ; relations de factions narratives sans malus automatiques.
- Q249–Q253 : équipements de combat (différents des artefacts), **0–2 emplacements par créature** (au plus un Arme, un Protection ; Q253 corrige Q250), restriction explicite par carte, défausse par défaut après départ ou remplacement du porteur.
- Q254 : **pas de durabilité universelle**, mais charges et effet à épuisement propres aux cartes concernées.
- [Décisions](DECISIONS.md) et [40 tests Q245–Q254](09-technical/acceptance-tests.md), spécifiés et non exécutés.
- Les règles moteur Q13–Q14, Q111–Q124, Q159–Q164, Q240–Q244 demeurent normatives ; pas de nouveau moteur de boucle ou d’aura. Prochaine question : **Q255**.

## Consolidation v2.7 — Q255–Q264 (2026-11-10)

- **Source normative :** [Catalogue indépendant et synergies Q255–Q264](03-progression/independent-card-catalog-and-synergies-v27.md), à lire avec [règles d'équipements Q245–Q254](01-combat/equipment-and-card-classifications-v26.md).
- **Q255 :** allié par défaut, équipement sur ennemi seulement si texte explicite ; propriétaire et porteur distincts, restrictions et départ inchangés.
- **Q256–Q258 :** équipements transversaux, pas d'archétype imposé ; **100 cartes indépendantes = 50 créatures + 30 sorts + 20 équipements** ; cible 10 armes/10 protections.
- **Q259–Q260 :** parmi 50 créatures, cibles souples **15 Humains / 14 Elfes / 13 Nains / 8 Dragons** ; environ **50–60 %** de profils en adéquation avec l'identité dominante de chaque peuple.
- **Q261–Q263 :** parmi ces 50 créatures, **6–10 passerelles**, **13–18 hybrides**, **5–8 évolutives** ; **étiquettes éditoriales recouvrables**, pas de cartes supplémentaires ni quotas de boosters.
- **Q264 :** **8–12 cartes indépendantes** présentant une contrepartie explicite ; réparties entre les 100 définitions, sans coût universel supplémentaire.
- [Journal de décisions](DECISIONS.md) ; [40 tests d'acceptation v2.7](09-technical/acceptance-tests.md), **décrits mais non exécutés**. Les règles moteur précédentes ne sont pas redéfinies.
- **Q265 ouverte** : prochaine dimension de gameplay à arbitrer.

# Tower TCG — Spécifications v1.2

**Version consolidée : décisions Q01 à Q114.** Le corpus est conçu pour être lu de façon modulaire par un agent d'implémentation ; les documents liés demeurent les sources de vérité pour chaque système.

**Nouveautés Q65–Q74 :** [attribution des dégâts, arrondis, vol de vie et événements des protections](01-combat/damage-attribution.md) ; [prévention létale](01-combat/damage-prevention.md) ; [file d'événements](01-combat/event-queue.md) ; [tests d'acceptation](09-technical/acceptance-tests.md) ; [journal de décisions](DECISIONS.md).

Ne pas implémenter comme validées les idées présentées comme ouvertes ou proposées. Les effets de soins et de contrôle sont détaillés dans leurs modules ; le placement après prise de contrôle est défini dans [transferts de contrôle](01-combat/control-transfers.md) (Q95).

# Tower TCG — Game Design Documentation

> Version 1.2 — 2026-11-02. Spécifications de combat en cours. Source : décisions explicites du concepteur (Q01–Q114). Aucun code n'est encore implémenté.

## Principe
Jeu solo TCG/RPG : ascension de tours, étages avec ennemis, marchands et ressources, boss par étage ; progression persistante par cartes, artefacts et caractéristiques du héros. Le combat tactique est le cœur du jeu.

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
- **Ouvert Q115** : portée du budget et héritage de causalité. Ne pas implémenter une politique arbitraire comme validée.

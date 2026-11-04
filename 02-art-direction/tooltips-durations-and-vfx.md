# Tooltips, échéances et feedbacks visuels — Q135 à Q144

**Statut : Q135–Q144 validées, avec les précisions personnalisées du concepteur en Q139, Q140, Q141 et Q143.** Ce document décrit la **présentation** ; les valeurs, la causalité et la résolution sont déterminées exclusivement par le moteur. Aucun budget temporel ne doit modifier les règles de combat ou le résultat des opérations atomiques.

## Références croisées

- [Cartes, jetons, carte originale et panneau latéral Q126–Q134](card-and-board-ui.md)
- [Couche d'interface / direction artistique](README.md)
- [Effets temporaires et décompte des échéances Q81–Q84](../01-combat/temporary-effects.md)
- [Expirations tardives, fin de tour et cycles Q105–Q114](../01-combat/turn-control-and-loop-safety.md)
- [Attribution des dégâts effectifs et vol de vie Q64–Q74](../01-combat/damage-attribution.md)
- [Préventions, armure et bouclier](../01-combat/damage-prevention.md)
- [Transferts de contrôle Q95–Q104](../01-combat/control-transfers.md)
- [File FIFO / causalité](../01-combat/event-queue.md)
- [Budgets de résolution du moteur, distincts du budget d'animation](../09-technical/causal-budgets-and-replay.md)
- [Tests d'acceptation](../09-technical/acceptance-tests.md) · [Décisions](../DECISIONS.md)

## Q135 — Codes visuels des valeurs finales (A)

- **UI-135-01** : sur jeton et dans le panneau d'inspection, afficher la **valeur finale effective** d'ATQ et les PV actuels ; couleurs et symboles reflètent la variation de la caractéristique par rapport à sa référence applicable.
- **UI-135-02** : hausse = chiffre vert + flèche montante ; baisse = chiffre rouge + flèche descendante ; pas de modification = style neutre. Les symboles/valeurs restent identifiables sans reconnaissance chromatique.
- **UI-135-03** : l'inspection présente le calcul de la caractéristique finale et l'origine des ajustements ; voir [Q134](card-and-board-ui.md).
- **UI-135-04** : **PV blessés vs PV maximum réduits sont deux concepts distincts** : `6/8 PV` indique les blessures, sans impliquer automatiquement un malus sur PV max. Respecter [Q78–Q80](../01-combat/temporary-effects.md).

## Q136 — Tooltip tactique condensé (C)

- **UI-136-01** : survol/focus de jeton = nom, contrôleur si utile, **ATQ effective, PV actuels/max**, protections, restrictions significatives et **tous les effets actifs** en version condensée avec leurs valeurs/échéances.
- **UI-136-02** : descriptions longues, sources détaillées et capacités en texte intégral sont réservées à l'inspection au clic ; le tooltip ne remplace pas le panneau exhaustif et ne modifie jamais le recto de la carte imprimée.
- **UI-136-03** : tooltip placé pour ne pas masquer durablement le jeton/cible ni les actions du plateau ; alternative accessible sur entrée sans survol (focus clavier, tactile), modalités détaillées ouvertes.

## Q137 — Ordre fixe des états et aucune fusion visuelle (A)

- **UI-137-01** : dans le tooltip et le panneau, catégories dans cet ordre **caractéristiques modifiées → protections → restrictions d'action → capacités temporaires → autres états**.
- **UI-137-02** : au sein de chaque catégorie, ordre stable **d'application** ; égalités départagées par identifiant stable conformément à la logique de tri. Chaque `effectInstanceId` actif possède sa **propre ligne**, même pour plusieurs bonus identiques ou de même valeur.
- **UI-137-03** : échéance affichée **par effet** ; le classement visuel **n'influence pas** les priorités d'expiration, de consommation de protections ou la FIFO.

## Q138 — Durées en langage naturel, sans ambiguïté (A)

- **UI-138-01** : employer des libellés du type « Fin de ce tour », « Encore 2 tours de l'ennemi », « Fin du prochain tour adverse », « Permanent », « Jusqu'à la disparition de la source » ; préciser l'échéance exacte dans l'inspection si nécessaire.
- **UI-138-02** : respecter les calendriers propres aux effets (durées généralement calculées par tours personnels du **créateur de l'effet**, Q81–Q83, sauf texte contraire) et les conditions explicites ; ne pas confondre tour du créateur, propriétaire et contrôleur de la créature.
- **UI-138-03** : réactualiser l'affichage si le temps pertinent avance ou si l'échéance change (Q109/Q140) ; un effet permanent ou conditionnel ne reçoit pas un compteur fictif.

## Q139 — Icône de contrôle et libellé d'échéance invariant (variante personnalisée)

- **UI-139-01** : le **changement de contrôleur** est représenté par un **état « contrôle » / icône dédiée** ; lorsque pertinent, il entre dans les **trois icônes prioritaires** du jeton Q132 ; les autres sont consultables au survol/clic.
- **UI-139-02** : **aucune icône de camp créateur obligatoire sur chaque effet**. Le libellé de durée reste celui de l'effet : p. ex. « Encore 2 tours de l'ennemi », qu'il soit porté par une unité alliée ou ennemie.
- **UI-139-03** : l'inspection peut exposer origine/source et contrôleur actuel ; **le propriétaire de la carte ne change pas** en cas de prise de contrôle (Q94–Q99). Ne jamais écrire « changement de propriétaire » comme si c'était une règle de transfert.

## Q140 — Changement de durée avec feedback éphémère (B)

- **UI-140-01** : une prolongation ou réduction d'effet modifie **immédiatement son échéance affichée**, dans tooltip et inspection ; conservation de `effectInstanceId` et **absence d'ON_EFFECT_EXPIRED** pour la seule prolongation (Q109).
- **UI-140-02** : signal éphémère sur le jeton (`+2 tours`, `−1 tour`, icône d'horloge animée) ; **aucune icône permanente supplémentaire** ne consomme les trois emplacements Q132.
- **VFX-140-01** : **toute action ou effet de gameplay** produit un feedback visuel expressif et agréable (*juicy*), proportionné à sa valeur tactique, tout en préservant lisibilité, accessibilité et rythme. Le visuel ne modifie jamais la logique déterministe.

## Q141 — Intensité hiérarchisée et cadence adaptative (C)

- **VFX-141-01** : trois **niveaux de présentation** — mineur/rapide, important/renforcé, exceptionnel/spectaculaire. Les niveaux **ne représentent pas des valeurs numériques de dégâts ou des seuils déjà fixés**.
- **VFX-141-02** : graduer en fonction de la puissance du sort, de la modification, de la capacité, de l'importance tactique et parfois du résultat (p. ex. boss vaincu). Une animation épique ne doit pas devenir la norme pour des effets mineurs.
- **VFX-141-03** : accélérer/regrouper effets secondaires en longues séquences ; prévoir option de **réduction des animations** pour accessibilité, sans perte d'information.
- **VFX-141-04** : ne pas faire attendre le joueur excessivement : cadence rapide, sensations fortes, envie de rejouer ; mêmes commits/faits de combat quel que soit le mode d'animation.

## Q142 — Orchestrateur visuel adaptatif (C)

- **VFX-142-01** : orchestrateur séparé du moteur ; consomme **les événements de combat déjà décidés** pour planifier la visualisation, sans gérer leur causalité fonctionnelle.
- **VFX-142-02** : regrouper uniquement des effets **visuellement compatibles et sans ambiguïté**, accélérer répétitions et superposer les animations indépendantes ; ne jamais confondre les cibles, armure, boucliers, PV perdus ni masquer les morts majeures.
- **VFX-142-03** : permettre un impact d'ouverture, une section médiane cadencée et une conclusion montrant clairement le plateau et les valeurs finales ; historique détaillé toujours disponible dans le journal.
- **VFX-142-04** : les rendus ne doivent **ni retarder l'exécution fonctionnelle**, ni modifier la FIFO, ni changer les événements de la simulation. Une attente d'interaction UI due à une animation peut être gérée au niveau présentation mais les résultats logiques restent identiques.

## Q143 — Nombres flottants par type + spectacle si puissance élevée (A personnalisée)

- **VFX-143-01** : **dégâts effectivement perdus aux PV** : nombre flottant rouge, réaction d'impact et léger recul ; **soin effectif** : nombre positif vert ascendant et particules positives.
- **VFX-143-02** : **armure absorbée** : impact métallique / nombre distinct ; **bouclier consommé** : effet magique bleu, fissure ou éclatement et indication propre. Ne pas additionner indistinctement `dégâts absorbés` et `PV perdus`.
- **VFX-143-03** : valeurs visibles = résultat **effectif et attribué** selon moteur ; ne pas afficher « −8 PV » pour 8 dégâts bruts avec seulement 5 PV effectivement perdus. Les annulations, protections et événements sans perte de PV possèdent leurs propres réactions, pas un nombre de PV fictif.
- **VFX-143-04** : pour un sort/effet **puissant**, autoriser des **éclairs, halos, secousses, ondes de choc, explosions, particules** et son synchronisé ; gradation et cadrage lisibles. Les chiffres flottants ne doivent pas se masquer.

## Q144 — Budget temporel global de présentation (B)

- **VFX-144-01** : établir un **objectif de présentation initial de 3 à 5 secondes pour une chaîne complexe**, hors éventuel moment exceptionnel à calibrer spécifiquement ; ce n'est **pas un timeout fonctionnel** ni une garantie rigide déjà testée. L'objectif est qu'aucune longue chaîne ne retienne le joueur inutilement.
- **VFX-144-02** : animations ordinaires courtes ; les durées individuelles telles que `0,15–0,35 s` mineures, `0,3–0,7 s` actions courantes, `0,7–1,5 s` puissantes, `1,5–2,5 s` exceptionnelles sont **propositions initiales de prototypage**, non valeurs finales validées.
- **VFX-144-03** : l'orchestrateur utilise accélération, regroupement et superposition pour viser le budget global, en préservant **morts, chiffres effectifs, états finaux et moments décisifs**. Une chaîne n'accumule pas naïvement toutes les durées individuelles.
- **VFX-144-04** : le budget d'animation n'est **pas** un compteur de résolutions ni un seuil anti-boucle Q111–Q120 ; la simulation déterministe ne dépend jamais du nombre d'images, de FPS ou de la vitesse graphique.
- **VFX-144-05** : le mode d'accessibilité réduit les mouvements/flashs sans supprimer les informations ; les effets majeurs restent identifiables par icône, texte/nombre et état final.

## Principes de tests et spécifications encore ouvertes

1. Tests : jeton/tooltip/inspection cohérents au même état atomique ; différence entre blessures et PV max ; libellés des effets non changés par contrôle ; retours de contrôle ; feedback court de durée ; absorption distinguée de perte PV ; deux animations indépendantes sans collision ; accélération sans divergence logique.
2. Ouverts : valeurs finales et profils de durée validés sur prototype ; seuils chiffrés d'intensité, design du plateau complet, accessibilité tactile/manette précise, sound design détaillé et éventuel bouton d'accélération manuelle distinct (l'option C de Q144 n'a **pas** été retenue).
3. **Q145** : choix de la suite de conception après la première consolidation *Juicy & Fast-Paced* ; ne pas considérer les propositions Q145 comme décidées.

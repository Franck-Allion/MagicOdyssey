# Journal de combat joueur, inspection historique et visibilité — Q165 à Q174

**Statut : VALIDÉ (Q165–Q174).** Ces exigences décrivent la cible fonctionnelle ; aucun moteur ou composant UI n’est attesté comme implémenté.

## Autorité et références croisées

- [Règles de plateau et inspection de cartes Q126–Q134](card-and-board-ui.md), [tooltips, durées et effets visuels Q135–Q144](tooltips-durations-and-vfx.md).
- [Plateau, sélection et prévisualisation Q145–Q154](board-and-tactical-preview.md) ; [auras et solveur déterministe Q155–Q164](spells-auras-and-continuous-effects.md).
- [File FIFO et ordre des événements](../01-combat/event-queue.md), [résolution des effets](../01-combat/effect-resolution.md), [capacités](../01-combat/abilities.md), [identité des instances](../01-combat/instance-identity.md), [contrôle](../01-combat/control-transfers.md).
- [Enregistrement déterministe, snapshots et replays Q115–Q125](../09-technical/causal-budgets-and-replay.md) et [tests d’acceptation](../09-technical/acceptance-tests.md).
- [Index artistique](README.md), [journal des décisions](../DECISIONS.md), [sommaire général](../README.md).

**Séparation des responsabilités :** le journal joueur est une projection lisible et filtrée des événements validés. Le journal technique est la source de vérité de la causalité, de l’ordre, des données déterministes et du replay. L’orchestrateur visuel contrôle *le moment* où un événement résolu peut être présenté au joueur, sans infléchir la résolution.

**Important :** les exemples de contenus, de compteurs et les libellés précis d’UI sont illustratifs ; ne pas prendre une proposition de mise en page pour une règle de combat.

## Q165 — Feedback temporaire lors de la neutralisation ou réactivation d’une aura (B)

- **UI-165-01** — À neutralisation d’une dépendance d’aura, feedback visuel bref sur source et bénéficiaires concernés ; aucune icône persistante obligatoire.
- **UI-165-02** — La réactivation génère un feedback distinct, lisible, sans concurrencer les trois icônes prioritaires de Q132.
- **UI-165-03** — Les caractéristiques effectives affichent les contributions réellement appliquées, et pas celles neutralisées.
- **UI-165-04** — Inspection : source, effet, contribution neutralisée et justification compréhensible, sans exposer de secret.
- **UI-165-05** — Prévisualisation et moteur réel utilisent exactement la même décision de neutralisation canonique Q161–Q164.
- **UI-165-06** — Les transitions et leurs motifs fonctionnels sont traçables par logs et replays Q121–Q124.

## Q166 — Journal hiérarchique, masqué par défaut, consultable à la demande (B + précision)

- **UI-166-01** — Journal de combat joueur distinct des logs techniques ; jamais ouvert par défaut sur le plateau.
- **UI-166-02** — Regroupement en séquences racines (attaque, sort, capacité ou autre action initiale), chacune avec résumé puis détails dépliables.
- **UI-166-03** — Au détail : déroulé chronologique effectif, sources, cibles, dégâts aux PV, absorptions, soins, états et effets déclenchés.
- **UI-166-04** — Le journal traduit les événements du moteur en langage naturel, en conservant l’ordre des opérations.
- **UI-166-05** — Les informations révélées respectent les droits de visibilité du joueur ; pas de divulgation rétroactive de secrets.
- **UI-166-06** — Le journal ne remplace pas les feedbacks VFX Q140–Q144, et sa consultation n’altère pas le combat.

## Q167 — Panneau latéral escamotable pour le journal (B)

- **UI-167-01** — Commande discrète pour ouvrir/fermer le journal ; panneau entièrement masqué au repos.
- **UI-167-02** — Vue latérale avec résumé et détails ; fermeture immédiate sans impact sur moteur et RNG.
- **UI-167-03** — Préserver la vue du plateau tant que l’espace disponible le permet ; sur petits écrans, superposition plutôt que compression illisible.
- **UI-167-04** — Le panneau n’impose pas de rejouer les animations ni de revenir à un snapshot antérieur.

## Q168 — Survol/sélection d’un événement : mise en évidence contextuelle des créatures (B)

- **UI-168-01** — Survol ou sélection dans le journal met en évidence temporairement les créatures concernées encore présentes.
- **UI-168-02** — Créatures détruites : identité historique, portrait, nom et position au moment de l’événement lorsque visibles au joueur.
- **UI-168-03** — Créatures déplacées ou contrôlées : liaison par identité d’instance, jamais uniquement nom ou case actuelle.
- **UI-168-04** — Aucun replay visuel des événements passés, ni déplacement du plateau vers un état antérieur.
- **UI-168-05** — L’information et les surbrillances disparaissent à la fin de l’interaction ; aucun effet sur la simulation.

## Q169 — Résumé compact des créatures et inspection historique détaillée à la demande (B)

- **UI-169-01** — Résumé : portrait, identité d’instance visible, nom, conséquences principales.
- **UI-169-02** — Inspection historique : valeurs effectives ATQ/PV actuels et maximaux, protections, états et effets pertinents au point d’événement.
- **UI-169-03** — Conserver sources pertinentes, position historique, propriétaire/contrôleur si utile, et identité d’instance.
- **UI-169-04** — Distinguer quand nécessaire les états avant/après l’opération pour éviter toute ambiguïté.
- **UI-169-05** — Ne jamais déduire l’état historique de statistiques actuelles ; utiliser les faits/snapshots d’événement autorisés.
- **UI-169-06** — Les unités disparues, ressuscitées ou déplacées restent correctement attribuées à leurs événements.

## Q170 — Historique par tour, recherche textuelle et filtres légers (B)

- **UI-170-01** — Séquences par tour et ordre effectif, les plus récentes facilement accessibles.
- **UI-170-02** — Recherche de noms visibles de créatures, sorts, capacités et descriptions d’événements.
- **UI-170-03** — Filtres simples : attaques, sorts, morts, changements d’état (extensible si utile).
- **UI-170-04** — Contrôles de recherche/filtres discrets ou condensés au repos ; détails dépliables.
- **UI-170-05** — Ni la recherche ni les filtres ne changent l’ordre de résolution dans une séquence.
- **UI-170-06** — Ne rechercher/indexer que les informations visibles pour le joueur, pas des secrets techniques.

## Q171 — Résumé tactique et détail exhaustif à la demande (B)

- **UI-171-01** — Chaque séquence résume les résultats effectivement appliqués : PV perdus, soins, absorption, morts et changements majeurs.
- **UI-171-02** — Événements tactiquement significatifs mis en valeur discrètement, y compris sans forte valeur numérique.
- **UI-171-03** — Les événements secondaires restent accessibles et ordonnés ; aucune suppression de détail lors de l’agrégation UI.
- **UI-171-04** — Calculer le résumé à partir des événements historiques validés, jamais de l’état courant ou d’une nouvelle simulation.
- **UI-171-05** — Les données masquées restent masquées dans le résumé comme dans le détail.

## Q172 — Explications textuelles, sans navigation causale avancée en V1 (A + contrainte de coût)

- **UI-172-01** — Une description claire de chaque événement indique, si visible, la source et le déclencheur pertinent.
- **UI-172-02** — Pas de graphe de causalité, d’arbre interactif ni de liens spéciaux cause→conséquence requis pour V1.
- **UI-172-03** — Les détails restent chronologiques ; le joueur parcourt manuellement la séquence pour approfondir.
- **UI-172-04** — Exploiter les faits d’événement existants ; aucune simulation rétroactive ni moteur d’explication indépendant.
- **UI-172-05** — Privilégier le coût de développement bas : le journal est secondaire face au gameplay.

## Q173 — Conservation de l’historique complet du combat en cours (B)

- **UI-173-01** — Conserver tous les événements visibles pertinents depuis le début du combat courant, y compris événements secondaires.
- **UI-173-02** — Aucune purge arbitraire par nombre de tours en cours de combat.
- **UI-173-03** — Libération possible en fin de combat ; aucune obligation de galerie de combats précédents.
- **UI-173-04** — Reprise de combat sauvegardé : journal cohérent avec l’historique déjà produit, éventuellement reconstruit depuis les faits persistés.
- **UI-173-05** — Ne jamais raccourcir les traces techniques/snapshots nécessaires aux garanties Q121–Q125 ; cycle de vie distinct.
- **UI-173-06** — Affichage léger, liste virtualisable ou chargement progressif des détails si nécessaire, sans perte de données.

## Q174 — Journal consultable pendant les animations sans pause ni fuite anticipée (B)

- **UI-174-01** — Ouverture à tout instant, même en pleine séquence VFX ; l’animation et le moteur continuent normalement.
- **UI-174-02** — Ne montrer que les événements déjà présentés au joueur, ou dont la révélation est déjà autorisée par l’ordonnanceur visuel.
- **UI-174-03** — Ajouter progressivement les nouveaux événements dans l’ordre de présentation ; conserver l’ordre effectif dans le détail historique.
- **UI-174-04** — Aucune fuite de résultats futurs calculés avant leur révélation visuelle (mort, effet surprise, choix secret).
- **UI-174-05** — Pas de pause, de replay automatique ni de blocage de la FIFO à l’ouverture du journal.
- **UI-174-06** — À la fin de la présentation, la totalité des événements visibles de la séquence est accessible, avec résumé définitif.

## Contrats de données et séquencement — spécification d’interface, pas API imposée

- **Fait canonique :** événement de combat et opération atomique déterministe, avec ordre stable, identités d’instances, sources et contexte de résolution ; aucune mutation par l’UI.
- **Projection historique :** chaque fait visible conserve au besoin des valeurs *avant/après*, identités, positions et contrôleurs au point de l’événement. Préférer la persistance des données nécessaires dans la trace déjà requise plutôt qu’une seconde infrastructure de replay.
- **Projection joueur :** filtrage des données cachées AVANT indexation de recherche, génération de résumés et mise en évidence des créatures. Ne pas exposer les causes cachées par effets de bord, intitulés ou comptages.
- **Séquence :** groupement par action initiale avec enfants en ordre de résolution. L’agrégation des résultats doit empêcher les doubles comptages (ex. dégâts annoncés ≠ PV réellement perdus ; armure ≠ bouclier ≠ PV).
- **Autorisation de présentation :** journal joueur peut être alimenté après le calcul logique, mais une entrée ne devient visible qu’après sa révélation dans l’ordonnancement VFX. Pour les animations condensées, établir un point explicite de révélation simultanée des événements groupés. Ne jamais réordonner la trace source.
- **Ouverture/fermeture :** purement UI, sans effet sur FIFO, contrôles de tour, RNG, budgets techniques ou snapshots. Une ouverture pendant une animation n’autorise pas une lecture anticipée.
- **Reprise sur sauvegarde :** restaurer le journal cohérent du combat repris selon les événements effectivement révélés, sans exposer prématurément le suffixe déjà calculé mais non présenté ; sinon rejouer la chronologie de présentation sans rejouer le moteur.
- **Contrainte de coût :** implémenter les résumés, détails, recherche et surbrillances comme vues légères sur la trace existante ; ne pas développer d’analyse causale interactive, frise ou rejeu graphique en V1.

## Parcours UX minimal

1. Combat normal : panneau journal fermé, aucune emprise visuelle permanente.
2. Clic sur commande discrète : panneau latéral ouvert, plateau encore lisible ; adaptation superposée sur affichage étroit.
3. Parcours par tour et séquence ; résumé des résultats réels ; déploiement facultatif de tous les événements visibles.
4. Recherche/filtre : noms et événements déjà visibles uniquement ; la chronologie des événements conservés ne change pas.
5. Survol d’un événement : surbrillance discrète des instances encore présentes. Unité détruite ou déplacée : carte d’identité/position historique sans falsifier le plateau actuel.
6. Clic sur une unité historique : inspection des états avant/après et des contributions pertinentes à l’époque, sans recalcul depuis l’état présent.
7. Une chaîne est encore animée : le journal est accessible, n’affiche que le préfixe autorisé à la présentation et reçoit le reste au fil de la révélation, sans arrêter la séquence.

## Limites de la V1 et questions ouvertes

- **Hors périmètre validé V1 :** arbre de causalité interactif, navigation cliquable causes/conséquences, rejeu graphique des séquences, vues de tous les combats antérieurs.
- **À calibrer :** position droite/gauche du panneau selon mise en page ; taille minimale responsive ; granularité des catégories de filtre ; formulation accessible des erreurs de neutralisation d’aura ; stratégie de mémoire/virtualisation ; schéma précis d’événement et de statut de révélation.
- **Invariants :** journal utilisateur ≠ trace technique ; la consultation ne modifie pas le combat ; visibilité historique et chronologie priment sur la richesse des outils.

## Vérification et couverture

Les tests `T-165-*` à `T-174-*` sont ajoutés à [acceptance-tests.md](../09-technical/acceptance-tests.md). Ce sont des scénarios à exécuter lors de l’implémentation, pas des preuves de conformité actuelle.


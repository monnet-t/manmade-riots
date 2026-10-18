# Métadonnées — MANMADE / émeutes et violences urbaines

Constitué le 2026-10-06. Statuts : **[É]** établi (lu dans la source), **[H]** hypothèse de construction, **[?]** inconnu.

## 1. `data/emeutes_journalier.csv`

Une ligne = le bilan **au matin** du jour indiqué (nuit précédente). 21 nuits pour 2005, 9 pour 2023.

| Colonne | Contenu | Source | Statut |
|---|---|---|---|
| `evenement` | 2005 ou 2023 | — | — |
| `date_bilan` | date du bilan (matin) | 2005 : tableau Wikipédia. 2023 : la colonne date a sauté à l'extraction ; dates reconstruites par recoupement avec le texte de l'article (31 interpellations = nuit 27-28/06 ; 875 = nuit 29-30/06 ; 55 véhicules et 20 interpellations = nuit 5-6/07) | 2005 [É], 2023 [H] solide |
| `nuit_index` | rang de la nuit dans l'événement | calculé | — |
| `vehicules_incendies` | véhicules incendiés dans la nuit | tableaux Wikipédia (« déclarations du ministère de l'Intérieur ») | [É] |
| `interpellations` | interpellations dans la nuit | idem | [É] ; NA = cellule vide dans la source |
| `fdo_blesses` | policiers/gendarmes blessés | idem | [É] ; NA = cellule vide (ne pas lire comme zéro) |
| `batiments_degrades` | bâtiments incendiés ou dégradés | tableau 2023 uniquement | [É] |
| `morts` | décès | idem | [É] |
| `vehicules_borne_basse` | 2023 : tableau journalier redressé pour sommer à 7 544 ; 2005 : identique à `vehicules_incendies` | voir §7 | total [É], profil [H] |
| `vehicules_borne_haute` | 2023 : tableau journalier redressé pour sommer à 12 031 ; 2005 : identique | voir §7 | total non étayé, profil [H] |
| `fdo_mobilises` | policiers et gendarmes mobilisés | voir §2 | mixte |
| `fdo_qualite` | qualité de la valeur `fdo_mobilises` | voir §2 | — |

Sources des tableaux :
- 2005 : https://fr.wikipedia.org/wiki/Émeutes_de_2005_dans_les_banlieues_françaises — section *Chronologie des émeutes > Vue d'ensemble*. Wikipédia signale elle-même la source comme « réf. incomplète ».
- 2023 : https://fr.wikipedia.org/wiki/Émeutes_consécutives_à_la_mort_de_Nahel_Merzouk — section *Bilan des émeutes > Chiffres*.

### Incohérences relevées dans les sources (non corrigées dans le CSV)
- 2005, interpellations : la somme des lignes fait **2 832**, le total affiché **2 921** (89 d'écart : nuits de début sans chiffre journalier).
- 2005, policiers blessés : somme des lignes **59**, total affiché **56**. Le même article donne par ailleurs 217 (Mucchielli), 224 (L'Obs, pompiers inclus) et 126 (DGPN au 17/11). La colonne journalière est donc très incomplète : inutilisable en modélisation.
- 2005, véhicules : Wikipédia FR 9 193 (somme vérifiée) ; DGPN 8 973 sur 20 nuits ; police nationale 9 071 ; L'Obs 10 346. Wikipédia EN diffère sur trois nuits (4/11 : 596 contre 519 ; 6/11 : 312 interpellations contre 349 ; 16/11 : 163 et 50 contre 165 et 44).
- 2023 : sommes des colonnes vérifiées (5 954 / 1 092 / 3 462 / 723).

## 2. Forces de l'ordre mobilisées — série reconstituée

Aucune source ne publie de série journalière nationale. La colonne mélange des points observés et des valeurs que j'ai construites.

| `fdo_qualite` | Sens |
|---|---|
| `observe_national` | chiffre national publié pour cette nuit |
| `annonce_reconduite` | dispositif annoncé comme maintenu, non revérifié nuit par nuit |
| `observe_local` | chiffre publié mais sur un périmètre local (Clichy / Seine-Saint-Denis) : borne basse |
| `interpole` | interpolation linéaire entre deux points observés |
| `hypothese` | valeur que j'ai posée, sans source directe |
| `inconnu` | NA |

Points observés 2005 :
- nuit 28-29/10 : jusqu'à 300 policiers à Clichy-Montfermeil ; 29/10 : dispositif d'environ 400 en Seine-Saint-Denis (chronologie mondialisme.org, d'après Libération / Le Parisien / Le Monde / AFP).
- nuit 4-5/11 : 1 400 hommes en Seine-Saint-Denis (8 CRS, 5 EGM) ; nuit 5-6/11 : 2 300 renforts en Île-de-France (Wikipédia, *Chronologie des émeutes de 2005 en France*). Périmètres locaux : les valeurs nationales 2 500 à 5 300 du CSV pour ces nuits sont des hypothèses.
- 7-8/11 : 8 000 hommes engagés + 1 500 réservistes appelés, soit 9 500 (Sénat, rapport n° 84 (2005-2006), J.-J. Hyest, 16/11/2005).
- nuit 14-15/11 : 11 200 ; nuit 15-16/11 : 10 600 ; 17/11 : « près de 10 000 » (ministère de l'Intérieur, repris par la chronologie citée).
- Pic : 11 500 (Le Goaziou & Mucchielli 2007) ou 11 200 (Wikipédia), non daté.
- Wikipédia EN indique 18 000 + 1 500 le 7/11 : non retenu, contredit par le rapport du Sénat.

Points observés 2023 :
- nuit 28-29/06 : 9 000, dont 2 000 en région parisienne ; nuit 29-30/06 : 40 000 (Darmanin, 29/06/2023).
- nuit 30/06-1/07 : 45 000 (Darmanin, TF1, 30/06/2023).
- nuits suivantes : « jusqu'à 45 000 chaque soir » du 27/06 au 5/07 (réponse ministérielle, question écrite AN n° 9936). Les 5 et 6/07 sont posés à 45 000 par hypothèse.
- nuit 27-28/06 : pas de chiffre national.

## 3. Écart sur les véhicules incendiés en 2023

| Chiffre | Source | Périmètre |
|---|---|---|
| 5 954 | somme du tableau Wikipédia (communiqués quotidiens du ministère) | 27/06 → 6/07 |
| « plus de 6 000 voitures brûlées » | G. Darmanin, commission des lois de l'Assemblée nationale, 19/07/2023 | 27/06 → 4/07 |
| **12 031** | G. Darmanin, audition au Sénat du 5/07/2023, repris par le rapport d'information n° 521 | 27/06 → 5/07 |
| 7 150 sinistres automobiles | assureurs, au 28/08/2023 (rapport n° 521) | déclarés |
| 46 % de 16 400 sinistres, soit ≈ 7 500 | France Assureurs, au 29/11/2023 (rapport n° 521) | déclarés |

[É] Le même ministre donne deux ordres de grandeur à deux semaines d'intervalle. [É] Le rapport du Sénat explique l'écart entre 12 031 et les sinistres assurés par la non-déclaration (véhicules anciens) et par les véhicules d'entités publiques. [?] Je n'ai trouvé aucune explication officielle de l'écart entre 5 954 et 12 031. [H] Pistes : périmètre police seule contre police + gendarmerie ; incendiés contre incendiés + dégradés ; consolidation tardive des remontées. Aucune n'est vérifiée.

## 4. `data/mouvement_2026.csv`

Format long (date, indicateur, valeur, périmètre, source, remarque). Chiffres relevés le 6/10/2026 dans la presse et sur Wikipédia ; je n'ai pu lire que des extraits (France 24, franceinfo et CNews refusent la lecture automatisée). Tout est **provisoire** et plusieurs séries se contredisent (voir colonne `remarque`).

## 5. Rapports parlementaires et officiels

Téléchargement impossible depuis l'environnement de travail (accès réseau bloqué) : liens à ouvrir à la main.

2005
- Sénat, rapport d'information **n° 49 (2006-2007)**, *Un nouveau pacte de solidarité pour les quartiers*, P. André (rapporteur), A. Türk (président), 30/10/2006. Tome I : https://www.senat.fr/rap/r06-049-1/r06-049-11.pdf — Tome II (auditions) : https://www.senat.fr/rap/r06-049-2/r06-049-2_mono.html — Synthèse : https://www.senat.fr/rap/r06-049-1/r06-049-1-syn.pdf
- Sénat, rapport **n° 84 (2005-2006)** sur la prorogation de l'état d'urgence, J.-J. Hyest, 16/11/2005 (bilan chiffré à chaud) : https://www.senat.fr/rap/l05-084/l05-0843.html
- Centre d'analyse stratégique, *Enquêtes sur les violences urbaines — Comprendre les émeutes de novembre 2005* : https://strategie.archives-spm.fr/cas/system/files/cas_violence_web.pdf
- Conseil national des villes, avis sur les émeutes urbaines de novembre 2005 (cité par Wikipédia, lien non retrouvé).
- [?] Assemblée nationale : je n'ai pas trouvé de rapport d'enquête dédié ; à confirmer.

2023
- Sénat, rapport d'information **n° 521 (2023-2024)**, *Émeutes de juin 2023 : comprendre, évaluer, réagir*, F.-N. Buffet, 9/04/2024 (commission des lois dotée des pouvoirs de commission d'enquête) : https://www.senat.fr/fileadmin/Presse/Documents_pdf/20240410-Rapport_Emeutes.pdf — dossier : https://www.senat.fr/controle/dossier/2023/17887.html
- IGA / IGJ, mission flash sur les profils et motivations des personnes interpellées, publiée le 14/09/2023 (citée par la réponse à la question écrite AN n° 10404 ; lien non retrouvé).
- Assemblée nationale, commission des lois, audition de G. Darmanin, 19/07/2023 : https://www.assemblee-nationale.fr/dyn/16/comptes-rendus/cion_lois/l16cion_lois2223074_compte-rendu.pdf

## 6. Lecture des deux rapports transmis (ajout du 2026-10-06, 11 h 40)

Limite : l'outil de lecture ne restitue que les 93 000 premiers caractères de chaque PDF, soit environ les 40 premières pages. Le reste n'a pas été lu en PDF ; pour le rapport du Sénat, les sections A et C de la première partie ont été lues en HTML.

**Sénat n° 521 (2023)** — https://www.senat.fr/rap/r23-521/r23-5211.pdf
- [É] Les 12 031 véhicules incendiés sont le « premier bilan provisoire » donné par G. Darmanin à la commission le 5/07/2023, pour la période du 27/06 au 5/07. Le rapport le reprend sans le redéfinir : ni périmètre police/gendarmerie, ni distinction incendié/dégradé, ni décomposition par nuit.
- [É] Aucune série nuit par nuit de véhicules, de bâtiments ou d'effectifs dans la partie lue. Seul le total de 45 000 agents est donné, contre 11 500 en 2005.
- [É] Interpellations par nuit (données IGA/IGJ, p. 39), en DGPN + préfecture de police : 27-28/06 : 16 + 41 = 57 ; 30/06-1/07 : 752 + 422 = 1 174 ; 3-4/07 : 42 + 28 = 70. Le tableau Wikipédia donne 31, 1 311 et 72 pour ces nuits : même ordre de grandeur, écart de 10 % au pic, écart fort la première nuit.
- [É] 7 150 sinistres automobiles déclarés au 28/08/2023 ; 782 agents blessés (674 policiers, 108 gendarmes) ; 672 communes dans 95 départements contre environ 300 communes dans 25 départements en 2005 ; 1 560 atteintes à des biens publics contre 233 en 2005.
- Conséquence : l'écart 5 954 / 12 031 **n'est pas tranché par le rapport**. Le chiffre haut est un bilan ministériel provisoire, contredit par le même ministre le 19/07/2023 (« plus de 6 000 voitures brûlées »).

**Document 2005** — https://www.vie-publique.fr/files/rapport/pdf/074000340.pdf
- [É] Il s'agit de *Enquêtes sur les violences urbaines — Comprendre les émeutes de novembre 2005. Les exemples de Saint-Denis et d'Aulnay-sous-Bois*, Centre d'analyse stratégique, 2006 (équipes O. Galland et M. Kokoreff). Ce n'est pas un rapport parlementaire.
- [É] Partie lue : monographie qualitative d'Aulnay-sous-Bois. Aucun tableau national nuit par nuit, aucun effectif mobilisé daté.
- [?] La monographie de Saint-Denis et les annexes n'ont pas été lues.

## 7. Fourchette retenue pour les véhicules incendiés en 2023 (décision du 2026-10-06)

| Référence | Total | Source | Statut |
|---|---|---|---|
| Tableau journalier | 5 954 | Wikipédia, communiqués quotidiens du ministère de l'Intérieur | [É] ; sert uniquement de **profil** nuit par nuit |
| **Borne basse** | **7 544** | France Assureurs, chiffres au 29/11/2023 repris par le rapport du Sénat n° 521 : 16 400 sinistres (793 M€) dont 46 % de véhicules (0,46 × 16 400). Révise le communiqué du 6/09/2023 (15 600 sinistres, soit 7 176) | [É] ; plancher, car hors véhicules non déclarés et hors flottes des communes et des forces de l'ordre |
| **Borne haute** | **12 031** | G. Darmanin, audition au Sénat du 5/07/2023 | **non étayé par un rapport** : déclaration ministérielle provisoire, reprise telle quelle par le rapport du Sénat n° 521, qui ne la définit ni ne la décompose ; contredite par le même ministre le 19/07/2023 (« plus de 6 000 ») |

- Communiqué France Assureurs : https://www.franceassureurs.fr/espace-presse/les-communiques-de-presse/cout-sinistres-declares-violences-urbains-fin-juin-reevalue-730millions-euros/ — répartition : véhicules 46 % des déclarations et 6 % du coût ; professionnels 41 % et 65 % ; collectivités 4 % et 27 % ; autres biens des particuliers 9 % et 2 % ; total 730 M€.
- [H] Les deux colonnes redressées appliquent un facteur uniforme au tableau journalier (× 1,267 et × 2,021). Cela suppose un sous-comptage identique chaque nuit, ce qu'aucune source ne confirme. Seuls les **totaux** de ces colonnes sont des références ; le profil est une convention.
- [H] Le passage de 7 544 à 12 031 supposerait environ 4 500 véhicules non déclarés ou publics (37 % du total) : non documenté.

## 8. Étude SRA sur les sinistres automobiles des émeutes de 2023 (ajout du 2026-10-06, 11 h 55)

Source lue : Caradisiac, « Les émeutes de cet été ont entaché l'année 2023 », qui cite l'étude d'impact de SRA (Sécurité et Réparation Automobiles). L'article d'Automobile Magazine transmis n'a pas pu être lu (site bloqué) ; la publication d'origine de SRA n'a pas été retrouvée.

- [É] Période étudiée : 27/06 au 15/07/2023. Volumes de sinistres 1,5 à 3 fois supérieurs à la moyenne (cohérent avec « +51 % » sur la période et « +232 % » les 29 et 30 juin).
- [É] Taux de véhicules économiquement irréparables : 39,3 % des sinistres, contre 12,8 % avant les émeutes. Le « +26,5 % de VEI » est donc un écart de **26,5 points** (39,3 − 12,8), pas une hausse relative.
- [É] Coût de réparation des véhicules réparables +19 % ; valeur moyenne des irréparables +10 %.
- [?] Aucun nombre absolu de véhicules n'est publié par SRA dans ce que j'ai lu.
- [H] Calcul dérivé, valable si « +51 % » et « 39,3 % » portent sur le même périmètre : la base habituelle représente 1/1,51 = 66 % des dossiers, l'excédent 34 %. Le taux d'irréparables de l'excédent vaut (39,3 − 0,66 × 12,8) / 0,34 ≈ 91 %. Appliqué aux 7 544 sinistres véhicules, cela donne environ 6 900 véhicules détruits et 650 réparables.
- Conséquence de définition : la borne basse 7 544 compte des **sinistres véhicules déclarés**, incendiés ou seulement dégradés. Elle reste un plancher du nombre de véhicules touchés (hors sinistres non ouverts et hors flottes publiques), mais le plancher des véhicules **détruits et assurés** est plutôt de l'ordre de 6 900.

## 9. Comparabilité 2005 / 2023 et lecture du lien interpellations-véhicules (ajout du 2026-10-06, 12 h 05)

- [É] Le calage 2005 repose sur un **comptage** du ministère de l'Intérieur (9 193 ; « décompte de la police » de 8 973 sur 20 nuits), pas sur des données d'assurance. Il couvre les voitures, deux-roues motorisés et autobus (chronologie mondialisme.org, d'après la communication de la police nationale), assurés ou non.
- [?] Périmètre non documenté dans les sources lues : inclusion ou non des véhicules de police et de gendarmerie ; couverture de la zone gendarmerie (le décompte est attribué à la DGPN, donc peut-être zone police seule). *Correction du 2026-10-06 : une version antérieure de cette section affirmait à tort que le décompte incluait les véhicules de l'État.*
- [É] Le comptage inclut le niveau habituel d'incendies : environ 28 000 véhicules en dix mois de 2005 hors émeutes, soit de l'ordre de 90 à 100 par nuit ; le ministère a d'ailleurs déclaré le retour à la normale sous 100 véhicules par nuit.
- [H] L'équivalent 2023 le plus proche en définition est le tableau journalier du ministère (5 954), même nature de source ; l'identité exacte des deux périmètres n'est pas vérifiée.
- [É] Interpellations par véhicule incendié, par nuit : 0,27 à 0,28 au pic de 2005 ; 0,26 à 0,27 les deux premières nuits de 2023 (9 000 agents au plus) ; 0,46 puis 0,83 et 0,81 les nuits à 40 000 et 45 000 agents. Ce rapport ne dépend pas du niveau retenu pour 2023 si le redressement est uniforme.
- [É] Le même rapport monte aussi en phase de décrue en 2005 (0,28 puis 0,41 à 0,57), avec des effectifs qui passent de 8 000 à 10 600.
- [É] Interpellations pour 1 000 agents au pic : 84 en 2005 (effectif en partie supposé), 29 en 2023.
- [É] Régression empilée log(I) sur log(V), log(V de la veille) et log(effectifs), 25 nuits : coefficient des effectifs de 0,02 (p = 0,80), et de −0,18 (p = 0,25) avec un effet fixe par événement. Aucun effet propre des effectifs n'est détectable ; la puissance est très faible et la série d'effectifs 2005 est majoritairement reconstruite.
- [É] Interpellations rapportées à la somme véhicules + bâtiments : 0,31 en 2005 ; 0,49 en 2023 avec le tableau (5 954 + 1 092) ; 0,34 avec la borne basse et les bâtiments du Sénat (7 544 + 2 508).

## 10. Données 2023 fournies par Thibault et GLM (ajout du 2026-10-06, 15 h 30)

Source : Le Parisien, « Interpellations, voitures brûlées, bâtiments dégradés : les émeutes en chiffres, nuit par nuit », 3/07/2023 — https://www.leparisien.fr/faits-divers/interpellations-voitures-brulees-batiments-degrades-les-emeutes-en-chiffres-nuit-par-nuit-03-07-2023-S7M7QZT5TBC63IC6AAC7XTBETQ.php. Tableau transmis par Thibault ; l'article n'a pas pu être relu ici (site bloqué).

- Convention de date : le tableau transmis date chaque nuit par son **soir** (27/06 = nuit du 27 au 28) ; le CSV garde le **matin du bilan** (28/06). Décalage d'un jour, mêmes nuits.
- [É] Interpellations, bâtiments et véhicules : identiques au tableau Wikipédia sur les 9 nuits (contrôle automatique).
- Nouvelle colonne `feux_voie_publique` : incendies de poubelles, 6 premières nuits (351, 2 391, 3 880, 2 814, 1 325, 352) ; NA ensuite et pour 2005.
- `fdo_mobilises` 2023 remplacé par la série transmise : 7 000 (nuit 27-28, auparavant NA), 10 000 (nuit 28-29, auparavant 9 000), 40 000, puis 45 000. Les 9 nuits passent en `observe_national`. Remplace le tableau de qualité du §2 pour 2023.
- Écart non levé : G. Darmanin a déclaré 9 000 agents pour la nuit du 28 au 29/06 (« quatre fois plus » le lendemain avec 40 000) ; le tableau transmis donne 10 000.

GLM ajoutées au script (section 2.4) : quasi-Poisson, lien log, sur les véhicules.

| Modèle | Calage | Coefficient log(I) | Coefficient log(FDO) | Dispersion |
|---|---|---|---|---|
| G1 | 2005, n = 17 | 0,91 | — | 79 |
| G2 | 2005, n = 17 | 1,02 | −0,29 (p = 0,056) | 59 |
| G1r | 2023, n = 9 | 0,73 | — | 80 |
| G2r | 2023, n = 9 | 0,84 | −0,42 (p = 0,094) | 55 |

- [É] Totaux prédits pour 2023 par les modèles calés sur 2005 : G1 = 9 717 ; G2 = 6 718, soit +13 % par rapport au tableau du ministère (5 954), −11 % par rapport à la borne basse France Assureurs (7 544), −44 % par rapport à 12 031.
- [É] Contrôle inverse (calage 2023, prévision 2005, observé 8 856 sur 17 nuits) : G1r = 6 667 (× 0,75) ; G2r = 12 316 (× 1,39).
- Réserves : les effectifs 2005 des nuits de montée sont reconstruits (§2) ; les coefficients des effectifs ne passent pas le seuil de 5 % ; dans les deux événements les effectifs croissent avec le temps, donc leur coefficient peut capter la phase de décrue autant qu'un effet propre.

## 11. Effectifs 2005 reconstitués à dire d'expert (ajout du 2026-10-06, 16 h 30) — remplace le §2 pour 2005

Aucune source ne donne la dynamique réelle des effectifs en 2005. La série ci-dessous est une **reconstitution à dire d'expert** par Thibault, à partir de la dynamique de l'événement et du retard de réaction du gouvernement décrit dans les rapports. Elle remplace mes hypothèses et interpolations antérieures.

| Soir | Bilan au matin (CSV) | Effectifs (bas – central – haut) | Appui |
|---|---|---|---|
| 27/10 au 2/11 | 28/10 au 3/11 | 400 – 450 – 500 | effectifs standards ; à Aulnay-sous-Bois 100 à 120 policiers chaque soir, 200 le 2/11 (étude du Centre d'analyse stratégique) |
| 3/11 | 4/11 | 1 000 – 1 250 – 1 500 | passage à 500 policiers à Aulnay ; doublement ou plus |
| 4/11 | 5/11 | 3 000 – 3 500 – 4 000 | montée en charge |
| 5/11 | 6/11 | 9 000 | généralisation |
| 6/11 au 13/11 | 7/11 au 14/11 | 11 500 | pic atteint et maintenu |
| 14/11 au 16/11 | 15/11 au 17/11 | 11 200, 10 600, 10 000 | communiqués du ministère (inchangé, `observe_national`) |

- Convention : j'ai lu les dates transmises comme des **soirs**, comme pour le tableau 2023. Si ce sont des matins de bilan, la série est à décaler d'un jour.
- Colonnes : `fdo_mobilises` (central), `fdo_bas`, `fdo_haut` ; `fdo_qualite = dire_expert` pour les 18 premières nuits.
- Écart avec une source : le rapport du Sénat n° 84 (16/11/2005) indique 8 000 hommes engagés au moment de l'annonce du 7/11, plus 1 500 réservistes appelés. La série retenue place 9 000 puis 11 500 dès les soirs des 5 et 6/11. Le script teste une variante qui impose 8 000, 8 000 et 9 500 aux bilans des 7, 8 et 9/11.
- Sources citées par Thibault : étude du Centre d'analyse stratégique (https://www.vie-publique.fr/files/rapport/pdf/074000340.pdf) ; https://fr-academic.com/dic.nsf/frwiki/577491 ; https://fr-academic.com/dic.nsf/frwiki/362033 ; https://berthoalain.com/wp-content/uploads/2007/12/emeutes-de-2005-dans-les-banlieues-francaises.pdf ; J.-P. Nadal, « Émeutes de 2005 : une vague de violence contagieuse révélée par la modélisation mathématique » (diaporama). Je n'ai relu que le diaporama et le début de l'étude du CAS.

Résultats avec cette série (GLM quasi-Poisson, lien log, calée sur 2005 ; total prédit pour 2023) :

| Série d'effectifs 2005 | Élasticité aux effectifs | p | Total prédit 2023 |
|---|---|---|---|
| Dire d'expert, central | −0,37 | 0,006 | 7 525 |
| Dire d'expert, bas | −0,33 | 0,007 | 7 712 |
| Dire d'expert, haut | −0,40 | 0,006 | 7 348 |
| Central + points du Sénat n° 84 | −0,38 | 0,003 | 6 773 |
| *Rappel : mes hypothèses antérieures (§2)* | *−0,29* | *0,056* | *6 718* |

- Références 2023 : tableau du ministère 5 954 ; borne basse 7 544 ; borne haute 12 031.
- Modèle linéaire avec ln(effectifs) : total 10 523 et prévision minimale de −181 sur 2023. Le logarithme de la variable ne suffit pas à interdire les valeurs négatives ; seul le lien log le garantit.
- Contrôle inverse (calage 2023, prévision 2005, observé 8 856) : 11 687, soit × 1,32.
- [É] Apport du diaporama de J.-P. Nadal sur le périmètre : les données de la base Roché-Depuiset-Gordon-Nadal sont les rapports journaliers de police, pour les communes relevant de la **police nationale** ; les communes en zone gendarmerie n'y sont pas. Cela ne tranche pas le périmètre du décompte ministériel des véhicules, mais indique que la remontée quotidienne de 2005 était d'abord policière.
- Niveau du pic : l'engagement maximal de 11 500 est l'estimation d'Alain Bertho (professeur honoraire d'anthropologie, université Paris 8), recoupée partiellement par les communiqués du ministère (11 200 la nuit du 14 au 15/11, 10 600 la suivante). L'écart avec le rapport du Sénat n° 84 porte donc sur la **date** à laquelle ce niveau est atteint (soir du 6/11 dans la série retenue ; 9 500 annoncés au 7/11 selon le Sénat), pas sur le niveau lui-même.
- Risque de sur-ajustement à signaler au lecteur : la série a été reconstituée après les premiers ajustements. Elle n'a pas été calée sur la cible ; l'analyse de sensibilité ci-dessus en mesure l'effet.

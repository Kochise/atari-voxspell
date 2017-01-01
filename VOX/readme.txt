Synthétiseur vocal et programme de test pour Falcon030.

Copyright (c) 2007 Guillaume et Mathieu Legris.


Sommaire:

I.   Introduction
II.  Description des fichiers:
III. Utilisation du code source.
IV.  Utilisation du synthétiseur.
V.   Utilisation du programme de test.


I. Introduction

Ce projet comprend un synthétiseur vocal et un programme de test.


II. Description des fichiers:

-Sources:
 Le code source du synthétiseur, de programmes utilitaires et du programme de test.
 -VOX.S:
  Code source en assembleur 68030 du synthétiseur vocal.
 -VOX_INC.S:
  Définitions diverses pour VOX.S.
 -VOX_STR.S:
  Ancienne version de VOX_INC.S. Ne pas utiliser.
 -VOX_CV2.S:
  Programme en GFA BASIC permettant de convertir la table des phonèmes.
 -VOX_CV.S:
  Ancienne version de VOX_CV2.S.
 -VOX_TONE.LST:
  Programme en GFA BASIC permettant de générer le ton laryngien.
 -VIEWVOX.LST:
  Programme en GFA BASIC permettant d'afficher la table de transcription phonétique.
 -VOX_TEST:
  Programme en GFA BASIC permettant de tester le synthétiseur vocal.

-Release:
 Programmes compilés.
 -VOX.PRG:
  Synhtétiseur vocal à placer dans le dossier C:\AUTO ou à exécuter avant d'utiliser le programme de test.
 -VOX_TEST.PRG:
  Programme de test. Le synthétiseur doit avoir été exécuté avant.


III. Utilisation du code source.

Le code source a été écrit avec Assemble de Brainstorm.
Si vous souhaitez le compiler, il vous faudra probablement d'abord changer les différents chemins d'inclusions qui sont hardcodés.
Les librairies utilitaires utilisés par ces programmes sont fournies séparément.
Le driver a été écrit après retro-ingénierie du driver fournit avec la carte et bien avant que j'ai accès à Internet pour trouver les documentions des circuits.
Certains termes peuvent donc être incorrects.
Si vous souhaitez réécrire un nouveau driver, vous devriez utiliser la documentation hardware fournie.
La license utilisée est celle de BSD.


IV. Utilisation du synthétiseur.

Le fichier VOX.PRG doit être placé dans le dossier AUTO du système ou alors exécuté avant d'utiliser le programme de test.
Ce driver installe un cookie "VOX " qui permet aux autres programmes de le détecter et de l'utiliser.
Consultez les fichiers sources VOX.S et VOX_TEST.LST pour plus de détails concernant l'utilisation du synthétiseur par un autre programme.


V. Utilisation du programme de test.

Pour synthétiser une voix, suivez les étapes suivantes:
-Appuyer sur 'X' pour entrer du texte en anglais.
 Appuyer sur "ENTER" quand vous avez terminé.
-Appuyer sur 'A' pour synthétiser la voix.
-Appuyer sur 'SPACE' pour écouter la voix ainsi généréé.

Vous pouvez modifier plusieurs paramètres de la voix:
-Appuyer sur 'R' pour changer le débit (vitesse) de la parole.
 Plus la valeur est élévée, plus la voix est lente.
 Vous devez ajuster ce paramètre selon la fréquence d'échantillonage, si vous la changez.
-Appuyer sur 'T' pour changer la hauteur du ton.
 Plus la valeur est élévée, plus la voix est grave.
 Vous devez ajuster ce paramètre selon la fréquence d'échantillonage, si vous la changez.

Appuyer sur 'A' pour recalculer la voix avec les nouveaux paramètres.


Synth�tiseur vocal et programme de test pour Falcon030.

Copyright (c) 2007 Guillaume et Mathieu Legris.


Sommaire:

I.   Introduction
II.  Description des fichiers:
III. Utilisation du code source.
IV.  Utilisation du synth�tiseur.
V.   Utilisation du programme de test.


I. Introduction

Ce projet comprend un synth�tiseur vocal et un programme de test.


II. Description des fichiers:

-Sources:
 Le code source du synth�tiseur, de programmes utilitaires et du programme de test.
 -VOX.S:
  Code source en assembleur 68030 du synth�tiseur vocal.
 -VOX_INC.S:
  D�finitions diverses pour VOX.S.
 -VOX_STR.S:
  Ancienne version de VOX_INC.S. Ne pas utiliser.
 -VOX_CV2.S:
  Programme en GFA BASIC permettant de convertir la table des phon�mes.
 -VOX_CV.S:
  Ancienne version de VOX_CV2.S.
 -VOX_TONE.LST:
  Programme en GFA BASIC permettant de g�n�rer le ton laryngien.
 -VIEWVOX.LST:
  Programme en GFA BASIC permettant d'afficher la table de transcription phon�tique.
 -VOX_TEST:
  Programme en GFA BASIC permettant de tester le synth�tiseur vocal.

-Release:
 Programmes compil�s.
 -VOX.PRG:
  Synht�tiseur vocal � placer dans le dossier C:\AUTO ou � ex�cuter avant d'utiliser le programme de test.
 -VOX_TEST.PRG:
  Programme de test. Le synth�tiseur doit avoir �t� ex�cut� avant.


III. Utilisation du code source.

Le code source a �t� �crit avec Assemble de Brainstorm.
Si vous souhaitez le compiler, il vous faudra probablement d'abord changer les diff�rents chemins d'inclusions qui sont hardcod�s.
Les librairies utilitaires utilis�s par ces programmes sont fournies s�par�ment.
Le driver a �t� �crit apr�s retro-ing�nierie du driver fournit avec la carte et bien avant que j'ai acc�s � Internet pour trouver les documentions des circuits.
Certains termes peuvent donc �tre incorrects.
Si vous souhaitez r��crire un nouveau driver, vous devriez utiliser la documentation hardware fournie.
La license utilis�e est celle de BSD.


IV. Utilisation du synth�tiseur.

Le fichier VOX.PRG doit �tre plac� dans le dossier AUTO du syst�me ou alors ex�cut� avant d'utiliser le programme de test.
Ce driver installe un cookie "VOX " qui permet aux autres programmes de le d�tecter et de l'utiliser.
Consultez les fichiers sources VOX.S et VOX_TEST.LST pour plus de d�tails concernant l'utilisation du synth�tiseur par un autre programme.


V. Utilisation du programme de test.

Pour synth�tiser une voix, suivez les �tapes suivantes:
-Appuyer sur 'X' pour entrer du texte en anglais.
 Appuyer sur "ENTER" quand vous avez termin�.
-Appuyer sur 'A' pour synth�tiser la voix.
-Appuyer sur 'SPACE' pour �couter la voix ainsi g�n�r��.

Vous pouvez modifier plusieurs param�tres de la voix:
-Appuyer sur 'R' pour changer le d�bit (vitesse) de la parole.
 Plus la valeur est �l�v�e, plus la voix est lente.
 Vous devez ajuster ce param�tre selon la fr�quence d'�chantillonage, si vous la changez.
-Appuyer sur 'T' pour changer la hauteur du ton.
 Plus la valeur est �l�v�e, plus la voix est grave.
 Vous devez ajuster ce param�tre selon la fr�quence d'�chantillonage, si vous la changez.

Appuyer sur 'A' pour recalculer la voix avec les nouveaux param�tres.


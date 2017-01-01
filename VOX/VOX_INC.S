;****************************************************************
;		D‚finition des EQUS et des structures utilis‚es dans VOX.
vox_version	equ		"0102" ; Version 1.00.
vox_comp	equ		"0102" ; Compatibilit‚ depuis version 1.00
;****************************************************************


;****************************************************************
;		D‚finition des donn‚es internes.
;****************************************************************
vox_inf:	rsstruct
;		Donn‚es g‚n‚rales.
version:	rs.l		1 ; Version du driver(ASCII)(L).
comp:		rs.l		1 ; Compatibilit‚(ASCII)(L).
fgs:		rs.l		1 ; Flags de status(L).
vox_inf_chk_fg	equ		0 ; Flag indiquant que les donn‚es des phonŠmes ont ‚t‚ calcul‚s.
vox_inf_snd_fg	equ		1 ; Flag indiquant que les sons ont ‚t‚ calcul‚s.
vox_inf_form_fg equ		2 ; Flag indiquant que l'utilisation des formants recalcul‚s.
call_addr:	rs.l		1 ; Adresse d'appel du driver(L).
dat_lgt:	rs.l		1 ; Longueur des donn‚es des phonŠmes(L).
snd_lgt:	rs.l		1 ; Longueur des donn‚es speech(L).
spl_lgt:	rs.l		1 ; Longueur du sample en octets(L).
dat_nb:		rs.w		1 ; Nombre de donn‚es(W).
snd_nb:		rs.w		1 ; Nombre de sons(W).

;		ParamŠtres de la voix.
freq:		rs.w		1 ; Fr‚quence d'‚chantillonnage(W).
voice_freq:	rs.w		1 ; Fr‚quence de la voix(W).
rate:		rs.w		1 ; Vitesse de la parole(W).
tone:		rs.w		1 ; Ton(W).

;		Sauvegarde des donn‚es pour le sample en cours.

;		Donn‚es pour le g‚n‚rateur de bruit.
noise_freq:	rs.w		1 ; Fr‚quence du bruit(W).
noise_vol:	rs.w		1 ; Volume du bruit(W).
noise_sgn:	rs.w		1 ; Signe du signal rectangulaire(W).
noise_cnt:	rs.w		1 ; Compteur interne(W).
sizeof:		rs.l		1
		rsend
tone_lgt	equ		25
;****************************************************************


;****************************************************************
;		D‚finition du bloc de paramŠtres (print me).
;****************************************************************
vox_pb		rsstruct
; D‚finition des bits de fgs.
fgs:		rs.l		1 ; Flags(L).
vox_pb_form	equ		0 ; Bit indiquant l'utilisation des formants recalcul‚s.
txt_addr:	rs.l		1 ; Adresse du texte(L).
phoneme_txt_addr: rs.l		1 ; Adresse d'un buffer pour le texte en phonŠmes(L).
phoneme_dat_addr: rs.l		1 ; Adresse d'un buffer pour les donn‚es des phonŠmes(L).
snd_addr:	rs.l		1 ; Adresse d'un buffer pour les donn‚es n‚cessaires au calcul du sample(L).
spl_addr:	rs.l		1 ; Adresse d'un buffer pour le sample(L).
dat_size:	rs.l		1 ; Taille du buffer pour les donn‚es des phonŠmes(L).
freq:		rs.w		1 ; Fr‚quence de synthŠse(W).
voice_freq:	rs.w		1 ; Fr‚quence de la voix(W).
rate:		rs.w		1 ; D‚finit la vitesse de la parole: nombre de p‚riode par son(W).
tone:		rs.w		1 ; Ton(W).
formant_c1:	rs.l		1 ; Coef pour le recalcul des formants 1(W.W).
formant_c2:	rs.l		1 ; .
formant_c3:	rs.l		1 ; .
sizeof:		rs.l		1
		rsend
;****************************************************************


;****************************************************************
;		Description des structures utilis‚es.
;****************************************************************
;		Structure des donn‚es dans tabstart.
phoneme:	rsstruct
ascii:		rs.w		1 ; Ecriture ASCII du phonŠme(2B).
fgs:		rs.w		1 ; Flags(W): .
priority:	rs.w		1 ; Priorit‚ entre les phonŠmes(?)(W).
lgt1:		rs.w		1 ; Longueur(nombre de sons) 1(W).
lgt2:		rs.w		1 ; Longueur(nombre de sons) 2(w).
freq_inf0:	rs.w		1 ; Info servant lors du calcul des fr‚quences(W).
freq_inf1:	rs.w		1 ; Info servant lors du calcul des fr‚quences(W).
freq_lgt0:	rs.w		1 ; Longueur(nombre de sons) 0 … interpoler pour la fr‚quence(W).
freq_lgt1:	rs.w		1 ; Longueur(nombre de sons) 1 … interpoler pour la fr‚quence(W).
wfreq10:	rs.w		1 ; Fr‚quence 0 de l'onde 1(W).
wfreq11:	rs.w		1 ; Fr‚quence 1 de l'onde 1(w).
wfreq20:	rs.w		1 ; Fr‚quence 0 de l'onde 2(W).
wfreq21:	rs.w		1 ; Fr‚quence 1 de l'onde 2(W).
wfreq30:	rs.w		1 ; Fr‚quence 0 de l'onde 3(W).
wfreq31:	rs.w		1 ; Fr‚quence 1 de l'onde 3(W).
noise_freq:	rs.w		1 ; Fr‚quence du bruit(W).
vol_inf:	rs.w		1 ; Info servant lors du calcul des volumes(W).
vol_lgt0:	rs.w		1 ; Longueur(nombre de sons) 0 … interpoler pour le volume(W).
vol_lgt1:	rs.w		1 ; Longueur(nombre de sons) 1 … interpoler pour le volume(W).
wvol10:		rs.w		1 ; Volume 0 de l'onde 1(W).
wvol11:		rs.w		1 ; Volume 1 de l'onde 1(W).
wvol20:		rs.w		1 ; Volume 0 de l'onde 2(W).
wvol21:		rs.w		1 ; Volume 1 de l'onde 2(W).
wvol30:		rs.w		1 ; Volume 0 de l'onde 3(W).
wvol31:		rs.w		1 ; Volume 1 de l'onde 3(W).
noise_vol0:	rs.w		1 ; Volume 0 du bruit(W).
noise_vol1:	rs.w		1 ; Volume 1 du bruit(W).
sizeof:		rs.l		1
		rsend

;		Structure du buffer de calcul.
calc:		rsstruct
last_freq1:	rs.w		1 ; Fr‚quence de l'onde 1 calcul‚e derniŠrement(W).
freq1:		rs.w		1 ; Fr‚quence actuelle de l'onde 1(W).
last_vol1:	rs.w		1 ; Volume de l'onde 1 calcul‚ derniŠrement(W)
vol1:		rs.w		1 ; Volume actuel de l'onde 1(W).

last_freq2:	rs.w		1 ; Fr‚quence de l'onde 2 calcul‚e derniŠrement(W).
freq2:		rs.w		1 ; Fr‚quence actuelle de l'onde 2(W).
last_vol2:	rs.w		1 ; Volume de l'onde 2 calcul‚ derniŠrement(W).
vol2:		rs.w		1 ; Volume actuel de l'onde 2(W).

last_freq3:	rs.w		1 ; Fr‚quence de l'onde 3 calcul‚e derniŠrement(W).
freq3:		rs.w		1 ; Fr‚quence actuelle de l'onde 3(W).
last_vol3:	rs.w		1 ; Volume de l'onde 3 calcul‚ derniŠrement(W).
vol3:		rs.w		1 ; Volume actuel de l'onde 3(W).

last_noise_vol:	rs.w		1 ; Volume du bruit calcul‚ derniŠrement(W).
noise_vol:	rs.w		1 ; Volume actuel du bruit(W).

freq_lgt:	rs.w		1 ; Longueur(nombre de sons) pour la fr‚quence(W).
vol_lgt:	rs.w		1 ; Longueur(nombre de sons) pour le volume(W).

nxt_freq_lgt:	rs.w		1 ; Longueur(nombre de sons) pour la fr‚quence pour le d‚but du phonŠme suivant(W).
nxt_vol_lgt:	rs.w		1 ; Longueur(nombre de sons) pour le volume pour le d‚but du phonŠme suivant(W).

freq_pos:	rs.w		1 ; Position 0 dans les sons du phonŠme actuel pour la fr‚quence(W).
vol_pos:	rs.w		1 ; Position 0 dans les sons du phonŠme actuel pour le volume(W).
sizeof:		rs.l		1
		rsend

;		Structure des donn‚es dans le buffer Speech.
snd:		rsstruct
freq:		rs.w		1 ; Fr‚quence globale de la voix sur ce son(W).
noise_vol:	rs.w		1 ; Volume du bruit(W).
noise_freq:	rs.w		1 ; Fr‚quence du bruit(W).
freq1:		rs.w		1 ; Fr‚quence de l'onde 1(W).
vol1:		rs.w		1 ; Volume de l'onde 1(W).
freq2:		rs.w		1 ; Fr‚quence de l'onde 2(W).
vol2:		rs.w		1 ; Volume de l'onde 2(W).
freq3:		rs.w		1 ; Fr‚quence de l'onde 3(W).
vol3:		rs.w		1 ; Volume de l'onde 3(W).
sizeof:		rs.l		1
		rsend

;		Structure des donn‚es dans le buffer phoneme_dat.
dat:		rsstruct
offset:		rs.w		1 ; Offset du phonŠme dans Tabstart(W).
freq:		rs.w		1 ; Fr‚quence globale du phonŠme(W).
lgt:		rs.w		1 ; Longeur(nombre de sons) totale DU phonŠme(W).
		rs.w		1 ; .
sizeof:		rs.l		1
		rsend

;		Structure du buffer de calcul utilis‚ lors de la synthŠse.
synth:		rsstruct
coef:		rs.l		1 ; Coefficient pour calculer le pas(L, virgule fixe).
tone_stp:	rs.l		1 ; Pas pour le ton laryngien(L, virgule fixe).
tone_cnt:	rs.l		1 ; Compteur pour le ton laryngien(L, virgule fixe).

vol1:		rs.l		1
vol_stp1:	rs.l		1
freq1:		rs.l		1 ; Pas dans la table pour le formant 1(L, virgule fixe).
freq_stp1:	rs.l		1 ; Pas de la fr‚quence 1(L, virgule fixe).

vol2:		rs.l		1
vol_stp2:	rs.l		1
freq2:		rs.l		1 ; Pas dans la table pour le formant 2(L, virgule fixe).
freq_stp2:	rs.l		1 ; Pas de la fr‚quence 2(L, virgule fixe).

vol3:		rs.l		1
vol_stp3:	rs.l		1
freq3:		rs.l		1 ; Pas dans la table pour le formant 3(L, virgule fixe).
freq_stp3:	rs.l		1 ; Pas de la fr‚quence 3(L, virgule fixe).
sizeof:		rs.l		1
		rsend
;****************************************************************


;****************************************************************
;		Num‚ro des routines.
;****************************************************************
_cv_txt		equ		0 ; Initialisation du driver.
_chk_dat	equ		1 ; .
_calc_snd	equ		2 ; .
_synthesize	equ		3 ; .
_recalc_form	equ		4 ; .
;****************************************************************


;****************************************************************
;		Erreurs.
;****************************************************************
err_none	equ		0 ; Aucune erreur.
err_unknownrout	equ		1 ; Routine inconnue.
err_phonemedatlgt equ		2 ; Buffer pour les donne‚s des phonŠmes trop petit.
err_phonemetxt	equ		3 ; Erreur dans le texte des phonŠmes.
err_spl		equ		4 ; Plus de samples … calculer.
;****************************************************************


;****************************************************************
;		Offset des phonŠmes.
;****************************************************************
p_EY		equ		0*phoneme.sizeof
p_AY		equ		1*phoneme.sizeof
p_OY		equ		2*phoneme.sizeof
p_AW		equ		3*phoneme.sizeof
p_OW		equ		4*phoneme.sizeof
p_UW		equ		5*phoneme.sizeof
p_AR		equ		6*phoneme.sizeof
p_WX		equ		7*phoneme.sizeof
p_YX		equ		8*phoneme.sizeof
p_AE		equ		9*phoneme.sizeof
p_IY		equ		10*phoneme.sizeof
p_ER		equ		11*phoneme.sizeof
p_AO		equ		12*phoneme.sizeof
p_UX		equ		13*phoneme.sizeof
p_UH		equ		14*phoneme.sizeof
p_AH		equ		15*phoneme.sizeof
p_AA		equ		16*phoneme.sizeof
p_OH		equ		17*phoneme.sizeof
p_AX		equ		18*phoneme.sizeof
p_IX		equ		19*phoneme.sizeof
p_IH		equ		20*phoneme.sizeof
p_EH		equ		21*phoneme.sizeof
p_DH		equ		22*phoneme.sizeof
p_ZH		equ		23*phoneme.sizeof
p_CH		equ		24*phoneme.sizeof
p_LX		equ		26*phoneme.sizeof
p_RX		equ		27*phoneme.sizeof
p_SH		equ		28*phoneme.sizeof
p_NX		equ		29*phoneme.sizeof
p_TH		equ		30*phoneme.sizeof
p__H		equ		31*phoneme.sizeof
p__V		equ		32*phoneme.sizeof
p__Z		equ		33*phoneme.sizeof
p__J		equ		34*phoneme.sizeof
p__L		equ		36*phoneme.sizeof
p__R		equ		37*phoneme.sizeof
p__W		equ		38*phoneme.sizeof
p__Y		equ		39*phoneme.sizeof
p__Q		equ		40*phoneme.sizeof
p__P		equ		41*phoneme.sizeof
p__T		equ		44*phoneme.sizeof
p__K		equ		47*phoneme.sizeof
p__B		equ		50*phoneme.sizeof
p__D		equ		53*phoneme.sizeof
p__G		equ		56*phoneme.sizeof
p__M		equ		59*phoneme.sizeof
p__N		equ		60*phoneme.sizeof
p__F		equ		61*phoneme.sizeof
p__S		equ		62*phoneme.sizeof
p_hyphen	equ		63*phoneme.sizeof
p_point		equ		64*phoneme.sizeof
p_comma		equ		65*phoneme.sizeof
p_question	equ		66*phoneme.sizeof
p_space		equ		67*phoneme.sizeof
p_UL		equ		68*phoneme.sizeof
p_UM		equ		69*phoneme.sizeof
p_UN		equ		70*phoneme.sizeof
p_IL		equ		71*phoneme.sizeof
p_IM		equ		72*phoneme.sizeof
p_IN		equ		73*phoneme.sizeof
;****************************************************************

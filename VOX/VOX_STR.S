;****************************************************************
;		D‚finition des EQUS et des structures utilis‚es dans VOX.
vox_version	equ		"0100" ; Version 1.00.
vox_comp	equ		"0100" ; Compatibilit‚ depuis version 1.00
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
;		D‚finition du bloc de paramŠtres Screen Eye (print me).
;****************************************************************
vox_pb		rsstruct
; D‚finition des bits de fgs.
fgs:		rs.l		1 ; Flags(L).
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

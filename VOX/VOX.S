		output		C:\AUTO\VOX.PRG
		opt		X+,O+
		bra		Start

;		Equates.
		incdir		E:\ASSEMBLE\EQUS\
; EQUs g‚n‚raux.
		include		GENERAL.S

;		Macros du systŠme d'exploitation.
		incdir		E:\ASSEMBLE\MACROS\
; TOS.
		include		GEMDOS.S
		include		BIOS.S
		include		XBIOS.S
; GEM.
;		include		AES.S
;		include		VDI.S

;****************************************************************
;		VOX est un programme de synthŠse vocale.
;		Par Mathieu LEGRIS. Bessancourt. Avril-mai 1996.
;
; Ces routines sont ind‚pendantes.
; 
; Pour appeler une routine, il faut d'abord chercher l'adresse du bloc
;d'informations que l'on peut trouver avec le cookie (du nom de 'VOX ', ne
;pas ouvlier l'espace!).
;Ensuite il faut poser le numŠro de la routine sur la pile puis l'adresse du
;bloc de paramŠtres et appeler le driver (en tant que sous-routine).
;
; *En GFA:
; vox_call_addr% est l'adresse de VOX (variable globale).
; vox_pb% est l'adresse du bloc de paramŠtres.
; vox_rout& est le num‚ro de la routine … appeler (variable globale).
;
;		PROCEDURE vox_call(vox_rout&)
;		 ~C:vox_call_addr%(L:vox_pb%,W:vox_rout&)
;		RETURN
;
; *En assembleur:
; VOX_call_addr pointe sur l'adresse d'appel de VOX (trouv‚e dans le cookie).
; VOX_pb_addr pointe sur l'adresse du bloc de paramŠtres.
; d0.w est le num‚ro de la routine.
;
;(VOX_call:)	move.l		VOX_pb_addr,-(sp)
;		move.w		d0,-(sp)
;		jsr		([VOX_call_addr])
;		addq.l		#6,sp
;		(rts)
;****************************************************************


;****************************************************************
;		Installation du synth‚tiseur vocal.
;****************************************************************
Start:		incdir		E:\ASSEMBLE\INCLUDE\
		include		INIT_MEM.S ; Taille du prg dans d7.
;----------------------------------------------------------------
;		Installation de VOX.
;----------------------------------------------------------------
		lea		Infos_txt,a0 ; Affiche infos.
		jsr		Print

;		V‚rifie si le driver n'est pas d‚j… install‚.
		move.l		Cookie,d0 ; Nom du cookie.
		jsr		Get_cookie
		lea		Already_txt,a0 ; Driver d‚j… install‚?
		beq.s		Install_err

;		Initialisation du driver.
		lea		VOX_inf_buf,a6
		move.l		#vox_version,(vox_inf.version.w,a6) ; Version.
		move.l		#vox_comp,(vox_inf.comp.w,a6) ; Compatibilit‚.
		clr.l		(vox_inf.fgs.w,a6) ; Flags … 0.
		move.l		#Call,(vox_inf.call_addr.w,a6) ; Adresse d'appel.

;		Installe le cookie.
		move.l		Cookie,d0 ; Nom du cookie.
		move.l		Cookie+4,d1 ; ParamŠtre du cookie: adresse du driver.
		jsr		Put_cookie
		lea		Cookie_err_txt,a0 ; Impossible de placer le cookie?
		bne.s		Install_err

;		Tout est OK.
		lea		Installed_txt,a0
		move.l		a0,d7
		jsr		Print
		bsr		Test
		Ptermres	#0,d7 ; Quitte et laisse r‚sident.


;		Il s'est produit une erreur: on fait flasher le texte
;d'erreur et on quitte.
Install_err:	move.l		a0,d7
		jsr		Txt_flash
		bsr		Test
		lea		Not_installed_txt,a0
		move.l		a0,d7
		jsr		Print
		bsr		Test
Quit:		Pterm0 ; Quitte.

;----------------------------------------------------------------
;		DATAs
;----------------------------------------------------------------
; Cookie.
Cookie:		dc.b		"VOX "
		dc.l		VOX_inf_buf

;		Textes.
Infos_txt:	dc.b		13,10,27,"p"
		dc.b		"              V   O   X                 ",27,"q",13,10
		dc.b		" The Atari Falcon 030 Vocal Synthesizer ",13,10
		dc.b		" Version 1.0á by M.L., May 1996, France ",13,10,0
Already_txt:	dc.b		"        VOX already installed !         ",0
Cookie_err_txt:	dc.b		"        Cannot install cookie !         ",0
Installed_txt:	dc.b		"VOX installed.",13,10,10,0
Not_installed_txt: dc.b		13,10,"VOX not installed.",13,10,10,0
		even
;****************************************************************


;****************************************************************
;		Routine de test (d7=adresse du texte).
;****************************************************************
Test:		Devconnect	#1,#7,#0,#8,#0 ; .
		Setmode		#1
		
		lea		VOX_inf_buf,a6
		lea		Test_pb,a5
		clr.l		(vox_pb.fgs.w,a5)
		move.w		#120,(vox_pb.tone.w,a5)
		move.w		#150,(vox_pb.rate.w,a5)
		move.w		#12500,(vox_pb.freq.w,a5)
		move.w		#12500,(vox_pb.voice_freq.w,a5)
		move.l		d7,(vox_pb.txt_addr.w,a5)
		move.l		#Test_phoneme_buf,(vox_pb.phoneme_txt_addr.w,a5)
		move.l		#Test_dat_buf,(vox_pb.phoneme_dat_addr.w,a5)
		move.l		#8192,(vox_pb.dat_size.w,a5)

		move.l		#Test_pb,-(sp)
		move.w		#_cv_txt,-(sp)
		jsr		Call
		addq.l		#6,sp

		move.l		#Test_pb,-(sp)
		move.w		#_chk_dat,-(sp)
		jsr		Call
		addq.l		#6,sp

		move.l		(vox_inf.snd_lgt.w,a6),d0
		Malloc		d0
		tst.l		d0
		bmi		Test_err0
		move.l		d0,Test_snd_buf
		move.l		d0,(vox_pb.snd_addr.w,a5)

		move.l		(vox_inf.spl_lgt.w,a6),d0
		lsl.l		#2,d0
		Malloc		d0
		tst.l		d0
		bmi		Test_err1
		move.l		d0,Test_spl_buf
		move.l		d0,(vox_pb.spl_addr.w,a5)

		move.l		#Test_pb,-(sp)
		move.w		#_calc_snd,-(sp)
		jsr		Call
		addq.l		#6,sp

		move.l		#Test_pb,-(sp)
		move.w		#_synthesize,-(sp)
		jsr		Call
		addq.l		#6,sp

		move.l		Test_spl_buf,d0
		move.l		(vox_inf.spl_lgt.w,a6),d1
		lsl.l		#2,d1
		add.l		d0,d1
		Setbuffer	d1,d0,#0
		Buffoper	#1
Test_wait_lp:	Buffoper	#-1
		andi.b		#1,d0
		bne.s		Test_wait_lp		

		Mfree		Test_spl_buf
Test_err1:	Mfree		Test_snd_buf
Test_err0:	rts

; Buffers.
Test_pb:	ds.b		256
Test_phoneme_buf: ds.b		1024
Test_dat_buf:	ds.b		8192
Test_snd_buf:	dc.l		0
Test_spl_buf:	dc.l		0
;****************************************************************


;****************************************************************
;		Gestion des appels aux routines.
;Entr‚es:
;
;Sorties:
; -d0: 0 si tout va bien sinon num‚ro de l'erreur.
;****************************************************************
Call:		moveq		#err_unknownrout,d0
		move.l		(6.w,sp),a5 ; Adresse du bloc de paramŠtres.
		move.w		(4.w,sp),d1 ; Num‚ro de la routine.
		bmi.s		Call_err ; Num‚ro possible ?
		cmpi.w		#rout_nb,d1
		bge.s		Call_err

		lea		VOX_inf_buf,a6 ; Adresse du bloc d'Informations.
		jsr		([Routines_tbl.l,d1.w*4])
		bne.s		Call_err
		moveq		#err_none,d0
Call_err:	rts

; Table des routines.
Routines_tbl:	dc.l		Cv_txt
		dc.l		Chk_dat
		dc.l		Calc_snd
		dc.l		Synthesize
		dc.l		Recalc_form
rout_nb		equ		5 ; Nombre de routines.
;****************************************************************


;****************************************************************
;		Conversion du texte en phonŠmes.
;****************************************************************
;----------------------------------------------------------------
;		Routine principale.
;----------------------------------------------------------------
Cv_txt:		move		ccr,-(sp)
		bsr		Sort_txt ; Tri des caractŠres valides.
		movea.l		(vox_pb.phoneme_txt_addr.w,a5),a4 ; Adresse du buffer pour les phonŠmes.
		move.l		(vox_pb.txt_addr.w,a5),a3 ; Adresse du texte.
		addq.l		#1,a3

;		Boucle des mots.
Cv_w_lp:	move.b		(a3),d0 ; Premier caractŠre du mot.
		beq		Cv_txt_end

;	Se place dans la table, avec la premiŠre lettre d'un phonŠme du mot,
;au d‚but des phonŠmes concernant cette lettre.
		ext.w		d0
		btst		#0,(Type_tbl.l,d0.w) ; CaractŠre valide?
		bne.s		Cv_w_ok0 ; Si bit 0 non nul alors oui.
		moveq		#$40,d0
Cv_w_ok0:	subi.w		#$40,d0
		lea		Phoneme_tbl,a2
		adda.w		(a2,d0.w*2),a2 ; Adresse de d‚but de recherche dans la table.
		bra.s		Cv_w_ok1

;	Recherche dans la table le prochain phonŠme.
No_match_lp:	tst.b		(a2)+
		bne.s		No_match_lp

;	Conversion des lettres en phonŠme.
Cv_w_ok1:	movea.l		a3,a1 ; Adresse du mot courant.
; Comparaison du texte avec le phonŠme actuel.
Cv_w_lp0:	tst.b		(a1) ; Fin de chaine?
		beq.s		No_match_lp ; Si oui on a pas trouv‚ alors on recommence.
		move.b		(a2),d0 ; CaractŠre du phonŠme.
		bclr		#7,d0 ; Elimine bit 7.
		cmp.b		(a1)+,d0 ; Comparaison avec un caractŠre du texte.
		bne.s		No_match_lp ; Si <> alors prochain phonŠme.
		tst.b		(a2)+ ; Sinon on continuer la comparaison,
		bpl.s		Cv_w_lp0 ; si on est pas … la fin du phonŠme.

;	V‚rifie le pr‚fixe.
		movea.l		a3,a0 ; On reprend le texte au d‚but du mot.
Chk_prefix_lp0:	move.b		(a2),d0 ; Donn‚e pour le pr‚fixe.
		bclr		#7,d0 ; Vire le bit 7.
		ext.w		d0
		beq.s		Chk_prefix_lp0_ok ; Si nul, ok.
		cmpi.b		#9,d0 ; Si sup‚rieur … 9,
		bgt.s		Chk_prefix_lp0_ok0 ; on branche.
		bsr		Chk_prefix ; Sinon il faut v‚rifier.
		beq.s		No_match_lp
		bra.s		Chk_prefix_lp0_ok
; Si la donn‚e du pr‚fixe est sup‚rieure … 9, il s'agit du caractŠre qui doit
;pr‚c‚der le phonŠme. Si le caractŠre du texte est <>, ce n'est pas le bon phonŠme.
Chk_prefix_lp0_ok0: cmp.b	-(a0),d0
		bne.s		No_match_lp
; V‚rifie si on est arriv‚ … la fin des donn‚es du pr‚fixe.
Chk_prefix_lp0_ok: tst.b	(a2)+
		bpl.s		Chk_prefix_lp0

;	V‚rifie le suffixe.
		lea		(a1),a0 ; On se place … la fin du phonŠme dans le texte.
Chk_suffix_lp0:	move.b		(a2),d0 ; Donn‚e pour le suffixe.
		bclr		#7,d0 ; Vire le bit 7.
		ext.w		d0
		beq.s		Chk_suffix_lp0_ok ; Si nul, ok.
		cmpi.b		#9,d0 ; Si sup‚rieur … 9,
		bgt.s		Chk_suffix_lp0_ok0 ; on branche.
		bsr		Chk_suffix ; Sinon il faut v‚rifier.
		beq		No_match_lp
		bra.s		Chk_suffix_lp0_ok
; Si la donn‚e du pr‚fixe est sup‚rieure … 9, il s'agit du caractŠre qui doit
;suivre le phonŠme. Si le caractŠre du texte est <>, ce n'est pas le bon phonŠme.
Chk_suffix_lp0_ok0: cmp.b	(a0)+,d0
		bne		No_match_lp
; V‚rifie si on est arriv‚ … la fin des donn‚es du suffixe.
Chk_suffix_lp0_ok: tst.b	(a2)+
		bpl.s		Chk_suffix_lp0

; La conversion du phonŠme a r‚ussi: on le recopie.
Got_match_lp:	move.b		(a2)+,(a4)+
		bne.s		Got_match_lp
		subq.l		#1,a4
		movea.l		a1,a3 ; Adresse dans le texte pour le prochain phonŠme.
		bra		Cv_w_lp ; Conversion du prochain phonŠme.

Cv_txt_end:	clr.b		(a4)
		bset		#2,(2.w,sp) ; Z=1: OK.
		rtr

;		Il y a un bug quelque part.
Chk_bug:	illegal

;----------------------------------------------------------------
;		V‚rification de la compatibilit‚ du phonŠme avec les lettres pr‚c‚dentes du texte.
;----------------------------------------------------------------
Chk_prefix:	move.b		-(a0),d1 ; CaractŠre du texte pr‚c‚dent.
		ext.w		d1
		tst.b		d0
		ble.s		Chk_bug ; Bug.
		cmpi.b		#9,d0
		bgt.s		Chk_bug ; Bug.
		ext.w		d0
		jmp		([Chk_prefix_tbl.l,d0.w*4])

;	Le caractŠre ne doit pas etre une lettre mais un symbole(chiffre, espace, etc...).
;(Le bit 0 correspondant au caractŠre dans type_tab doit etre nul).
Chk_prefix1	btst.b		#0,(Type_tbl.l,d1.w)
		eori		#4,ccr ; Inverse Z.
		rts
;	Le caractŠre doit etre une voyelle. (Le bit 1 correspondant au caractŠre dans
;type_tab doit etre mis).
Chk_prefix2:	btst.b		#1,(Type_tbl.l,d1.w)
		rts
;	Le caractŠre doit etre une consonne. (Le bit 2 dans type_tab doit etre mis).
Chk_prefix3:	btst.b		#2,(Type_tbl.l,d1.w)
		rts
;	Le caractŠre doit etre: B,D,G,J,M,N,R,V,W ou Z. (Le bit 4 doit etre mis).
Chk_prefix4:	btst.b		#4,(Type_tbl.l,d1.w)
		rts
;	Le caractŠre doit etre: C,G,J,X,S ou Z. (Le bit 3 doit etre mis).
Chk_prefix5:	btst.b		#3,(Type_tbl.l,d1.w) ; Si le bit est mis, c'est ok.
		bne.s		Chk_prefix_ok1
; Si le bit 3 n'est pas mis, le caractŠre doit etre un H qui doit etre
;pr‚c‚d‚ d'un C ou d'un S.
		cmpi.b		#'H',d1
		bne.s		Chk_prefix_err
		move.b		-(a0),d1
		cmpi.b		#'C',d1
		beq.s		Chk_prefix_ok0
		cmpi.b		#'S',d1
		beq.s		Chk_prefix_ok0
		bra.s		Chk_prefix_err
;	Le caractŠre doit etre: D,J,L,N,R,S,T ou Z. (Le bit 5 doit etre mis).
Chk_prefix6:	btst.b		#5,(Type_tbl.l,d1.w)
		bne.s		Chk_prefix_ok1
; Si le bit 5 n'est pas mis, le caractŠre doit etre un H qui doit etre
;pr‚c‚d‚ par C,S ou T.
		cmpi.b		#'H',d1
		bne.s		Chk_prefix_err
		move.b		-(a0),d1
		cmpi.b		#'C',d1
		beq.s		Chk_prefix_ok0
		cmpi.b		#'S',d1
		beq.s		Chk_prefix_ok0
		cmpi.b		#'T',d1
		beq.s		Chk_prefix_ok0
		bra.s		Chk_prefix_err
;	Le caractŠre doit etre E,I ou Y.
Chk_prefix7:	cmpi.b		#'E',d1
		beq.S		Chk_prefix_ok0
		cmpi.b		#'I',d1
		beq.s		Chk_prefix_ok0
		cmpi.b		#'Y',d1
		beq.s		Chk_prefix_ok0
		bra.s		Chk_prefix_err
;	Recherche la premiŠre consonne pr‚c‚dente.
Chk_prefix8:	addq.l		#1,a0
Chk_prefix_lp:	move.b		-(a0),d1
		ext.w		d1
		btst.b		#2,(Type_tbl.l,d1.w)
		bne.s		Chk_prefix_lp
		addq.l		#1,a0
Chk_prefix_ok0: moveq		#-1,d1 ; OK: le phonŠme correspond comme pr‚fixe pourl'instant.
Chk_prefix_ok1: rts
Chk_prefix_err:	moveq		#0,d1 ; Erreur: le phonŠme ne correspond pas.
		rts

Chk_prefix_tbl:	dc.l		Chk_bug,Chk_prefix1,Chk_prefix2
		dc.l		Chk_prefix3,Chk_prefix4,Chk_prefix5
		dc.l		Chk_prefix6,Chk_prefix7,Chk_prefix8
		dc.l		Chk_bug

;----------------------------------------------------------------
;		V‚rification de la compatibilit‚ du phonŠme avec les lettres suivantes du texte.
;----------------------------------------------------------------
Chk_suffix:	move.b		(a0)+,d1 ; CaractŠre du texte suivant.
		ext.w		d1
		tst.b		d0
		ble		Chk_bug ; Bug.
		cmpi.b		#9,d0
		bgt		Chk_bug ; Bug.
		ext.w		d0
		jmp		([Chk_suffix_tbl.l,d0.w*4])

;	Le caractŠre ne doit pas etre une lettre mais un symbole(chiffre, espace, etc...).
;(Le bit 0 correspondant au caractŠre dans type_tab doit etre nul).
Chk_suffix1	btst.b		#0,(Type_tbl.l,d1.w)
		eori		#4,ccr ; Inverse Z.
		rts
;	Le caractŠre doit etre une voyelle. (Le bit 1 correspondant au caractŠre dans
;type_tab doit etre mis).
Chk_suffix2:	btst.b		#1,(Type_tbl.l,d1.w)
		rts
;	Le caractŠre doit etre une consonne. (Le bit 2 dans type_tab doit etre mis).
Chk_suffix3:	btst.b		#2,(Type_tbl.l,d1.w)
		rts
;	Le caractŠre doit etre: B,D,G,J,M,N,R,V,W ou Z. (Le bit 4 doit etre mis).
Chk_suffix4:	btst.b		#4,(Type_tbl.l,d1.w)
		rts
;	Le caractŠre doit etre: C,G,J,X,S ou Z. (Le bit 3 doit etre mis).
Chk_suffix5:	btst.b		#3,(Type_tbl.l,d1.w) ; Si le bit est mis, c'est ok.
		bne		Chk_suffix_ok1
; Si le bit 3 n'est pas mis, le caractŠre doit etre un H qui doit etre
;pr‚c‚d‚ d'un C ou d'un S.
		cmpi.b		#'H',d1
		bne		Chk_suffix_err
		move.b		(a0)+,d1
		cmpi.b		#'C',d1
		beq		Chk_suffix_ok0
		cmpi.b		#'S',d1
		bne		Chk_suffix_err
		bra		Chk_suffix_ok0
;	Le caractŠre doit etre: D,J,L,N,R,S,T ou Z. (Le bit 5 doit etre mis).
Chk_suffix6:	btst.b		#5,(Type_tbl.l,d1.w)
		bne		Chk_suffix_ok1
; Si le bit 5 n'est pas mis, le caractŠre doit etre un H qui doit etre
;pr‚c‚d‚ par C,S ou T.
		cmpi.b		#'H',d1
		bne		Chk_suffix_err
		move.b		(a0)+,d1
		cmpi.b		#'C',d1
		beq		Chk_suffix_ok0
		cmpi.b		#'S',d1
		beq		Chk_suffix_ok0
		cmpi.b		#'T',d1
		beq.s		Chk_suffix_ok0
		bra.s		Chk_suffix_err
;	Le caractŠre doit etre E,I ou Y.
Chk_suffix7:	cmpi.b		#'E',d1
		beq.S		Chk_suffix_ok0
		cmpi.b		#'I',d1
		beq.s		Chk_suffix_ok0
		cmpi.b		#'Y',d1
		beq.s		Chk_suffix_ok0
		bra.s		Chk_suffix_err
;	Recherche la premiŠre consonne suivante.
Chk_suffix8:	subq.l		#1,a0
Chk_suffix_lp:	move.b		(a0)+,d1
		ext.w		d1
		btst.b		#2,(Type_tbl.l,d1.w) ; Flag de consonne.
		bne.s		Chk_suffix_lp
		subq.l		#1,a0
		bra.s		Chk_suffix_ok0
;	V‚rifie la terminaison du mot qui doit etre: -ER,-ES,-ED,-ELY,-EFUL,-ING.
Chk_suffix9:	cmpi.b		#'I',d1
		bne.s		Chk_suffix90
		cmpi.b		#'N',(a0)+
		bne.s		Chk_suffix_err
		cmpi.b		#'G',(a0)+
		bne.s		Chk_suffix_err
		bra.s		Chk_suffix_ok0
Chk_suffix90:	cmpi.b		#'E',d1
		bne.s		Chk_suffix_err
		move.b		(a0)+,d1
		cmpi.b		#'R',d1 ; Terminaison -ER.
		beq.s		Chk_suffix_ok0
		cmpi.b		#'S',d1 ; Terminaison -ES.
		beq.s		Chk_suffix_ok0
		cmpi.b		#'D',d1 ; Terminaison -ED.
		beq.s		Chk_suffix_ok0
		cmpi.b		#'L',d1 ; Terminaison -ELY.
		bne.s		Chk_suffix91
		cmpi.b		#'Y',(a0)+
		beq.s		Chk_suffix_ok0
		bra.s		Chk_suffix_err
Chk_suffix91:	cmpi.b		#'F',d1 ; Terminaison -EFUL.
		bne.s		Chk_suffix_err
		cmpi.b		#'U',(a0)+
		bne.s		Chk_suffix_err
		cmpi.b		#'L',(a0)+
		beq.s		Chk_suffix_ok0
Chk_suffix_err:	moveq		#0,d1 ; Erreur: le phoneme de la table ne correspond pas.
		rts
Chk_suffix_ok0: moveq		#-1,d1 ; OK: le phoneme de la table correspond comme suffixe pour l'instant.
Chk_suffix_ok1: rts

Chk_suffix_tbl:	dc.l		Chk_bug,Chk_suffix1,Chk_suffix2
		dc.l		Chk_suffix3,Chk_suffix4,Chk_suffix5
		dc.l		Chk_suffix6,Chk_suffix7,Chk_suffix8
		dc.l		Chk_suffix9

;----------------------------------------------------------------
;		Tri des caractŠres valides du texte et conversion en
; majuscules.
;----------------------------------------------------------------
Sort_txt:	movea.l		(vox_pb.txt_addr.w,a5),a0 ; Adresse du texte.
		move.b		#' ',(a0)+ ; Espace de d‚part.
		lea		Type_tbl,a4 ; Table des caractŠres.
		lea		(a0),a1
		moveq		#0,d0
Sort_txt_lp:	move.b		(a0)+,d0
		andi.b		#$7f,d0 ; Elimine bit 7.
		beq.s		Sort_txt_end ; Si nul alors fin de chaine.
		cmpi.b		#$60,d0 ; Si plus petit que 'a' (code ASCII $61), alors c'est
		blt.s		Sort_txt_ok ; d‚j… une majuscule ou un caractŠre que l'on accepte.
		andi.b		#$5f,d0 ; Sinon on convertit en majuscule.
Sort_txt_ok:	tst.b		(a4,d0.w) ; CaractŠre valide dans la table?
		beq.s		Sort_txt_lp ; Si nul, non valide.
		move.b		d0,(a1)+ ; Sinon on stocke le caractŠre.
		bra.s		Sort_txt_lp

Sort_txt_end:	clr.b		(a1) ; 0 de fin de chaine.
		rts

;----------------------------------------------------------------
;		Datas.
;----------------------------------------------------------------
;		Table donnant les flags pour chaque caractŠre.
; -bit 0: s'il est mis, c'est une lettre, sinon, c'est un symbole.
; -bit 1: s'il est mis, c'est une voyelle: A,E,I,O,U,Y).
; -bit 2: s'il est mis, c'est une consonne: B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,V,W,X,Z.
; -bit 3: s'il est mis, c'est: C,G,J,S,X,Z.
; -bit 4: s'il est mis, c'est: B,D,G,J,N,R,V,W,Z.
; -bit 5: s'il est mis, c'est: D,J,L,N,R,S,T,Z.
; -bit 6: s'il est mis, c'est un symbole valide: " ",!,",#,$,%,&,',*,+,",",-,.,/,:,;,<,=,>,?.
; -bit 7: s'il est mis, c'est un chiffre: 0,1,2,3,4,5,6,7,8,9.
; Si l'octet est nul, le caractŠre est invalide.
Type_tbl:	dcb.b		32,$00 ; ASCII 0-31: symboles invalides.
		dcb.b		8,$40 ; ASCII 32-39: symboles valides.
		dcb.b		2,$00 ; ASCII 40-41: symboles invalides(parenthŠses).
		dcb.b		6,$40 ; ASCII 42-47: symboles valides.
		dcb.b		10,$80 ; ASCII 48-57: chiffres.
		dcb.b		7,$40 ; ASCII 58-64: symboles valides.
		dc.b		$03,$15,$0d,$35,$03,$05,$1d,$05 ; ASCII 65-90: lettres.
		dc.b		$03,$3d,$05,$25,$15,$35,$03,$05
		dc.b		$05,$35,$2d,$25,$03,$15,$15,$0d
		dc.b		$03,$3d
		dcb.b		37,$00 ; ASCII 91-127: caractŠres invalides. 
;****************************************************************


;****************************************************************
;		Calcule les donn‚es pour le calcul des sons.
;****************************************************************
;----------------------------------------------------------------
;		G‚n‚ral.
;----------------------------------------------------------------
Chk_dat:	move		ccr,-(sp)
		move.l		(vox_inf.fgs.w,a6),d7
		bclr.l		#vox_inf_chk_fg,d7
		move.l		d7,(vox_inf.fgs.w,a6)

		move.w		(vox_pb.freq.w,a5),(vox_inf.freq.w,a6)
		move.w		(vox_pb.voice_freq.w,a5),(vox_inf.voice_freq.w,a6)
		move.w		(vox_pb.rate.w,a5),(vox_inf.rate.w,a6)
		move.w		(vox_pb.tone.w,a5),(vox_inf.tone.w,a6)

;		Calcule les donn‚es.
		bsr		Write_dat ; Pr‚pare les donn‚es.
		bne		Chk_dat_err
		lea		Tabstart,a1
		move.l		(vox_pb.fgs.w,a5),d7
		btst.l		#vox_pb_form,d7
		beq.s		Chk_dat_ok0
		lea		Tabstart2,a1
Chk_dat_ok0:		
		bsr		Chk_dat0
		bsr		Chk_dat1
		bsr		Chk_dat2
		bsr		Chk_dat3
		bsr		Chk_dat4

;		Calcule le nombre de donn‚es et de sons.
		movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		lea		(dat.sizeof.w,a0),a0
		moveq		#0,d0
		moveq		#0,d1
		moveq		#0,d2
Chk_dat_lp:	tst.w		(dat.offset.w,a0) ; Fin des donn‚es?
		bmi.s		Chk_dat_ok
		addq.l		#1,d0
		add.w		(dat.lgt.w,a0),d1 ; Nombre de sons actuel.
		lea		(dat.sizeof.w,a0),a0 ; Prochaine donn‚e.
		bra.s		Chk_dat_lp

Chk_dat_ok:	move.w		d0,(vox_inf.dat_nb.w,a6) ; Nombre de donn‚es.
		addq.w		#2,d0
		mulu.w		#dat.sizeof,d0
		move.l		d0,(vox_inf.dat_lgt.w,a6) ; Taille des donn‚es.

		move.w		d1,(vox_inf.snd_nb.w,a6) ; Nombre de sons.
		addq.w		#1,d1
		mulu.w		#snd.sizeof,d1 ; Taille.
		move.l		d1,(vox_inf.snd_lgt.w,a6)

;		Calcule le nombre de samples.
		move.w		(vox_inf.rate.w,a6),d1 ; Vitesse de la parole: nombre de p‚riodes(ou samples) par son.
		mulu.w		(vox_inf.snd_nb.w,a6),d1
		move.l		d1,(vox_inf.spl_lgt.w,a6) ; Nombre de samples.
		
		move.l		(vox_inf.fgs.w,a6),d7
		bset.l		#vox_inf_chk_fg,d7
		move.l		d7,(vox_inf.fgs.w,a6)
		bset		#2,(1.w,sp)
		rtr
Chk_dat_err:	bclr		#2,(1.w,sp)
		rtr

;----------------------------------------------------------------
;		Pr‚pare les donn‚es relatives aux phonŠmes.
;----------------------------------------------------------------
Write_dat:	move		ccr,-(sp)
		movea.l		(vox_pb.phoneme_txt_addr.w,a5),a0
		movea.l		(vox_pb.phoneme_dat_addr.w,a5),a1
		move.l		(vox_pb.dat_size.w,a5),d7 ; Taille du buffer pour les donn‚es.
		divu.w		#dat.sizeof,d7 ; Nombre maximum de donn‚es possible.
		moveq		#3,d6 ; Nombre de donn‚es … 3(minimum).
		move.w		#-1,(dat.offset.w,a1) ; D‚but du buffer.
		move.w		#-1,(dat.freq.w,a1)
		move.w		#-1,(dat.lgt.w,a1)
		lea		(dat.sizeof.w,a1),a1
Write_dat_lp0:	move.w		#-1,(dat.offset.w,a1)
		move.w		#-1,(dat.freq.w,a1)
		move.w		#-1,(dat.lgt.w,a1)

		move.b		(a0)+,d0 ; Si nul, fin du texte des phonŠmes.
		beq		Write_dat_end

		moveq		#err_phonemedatlgt,d5 ; Buffer trop petit?
		addq.l		#1,d6
		cmp.l		d7,d6 ; Sommes-nous arriv‚ … la fin du buffer?
		bgt		Write_dat_err

		moveq		#err_phonemetxt,d5 ; Erreur dans le texte.
;		Si le caractŠre est un chiffre (de 1 … 9), il s'agit de la
;hauteur de la voix pour le phonŠme pr‚c‚dent.
		cmpi.b		#'1',d0
		blt.s		Write_dat_ok00
		cmpi.b		#'9',d0
		bgt.s		Write_dat_ok00
		subi.b		#'0',d0
		tst.w		(dat.freq-dat.sizeof.w,a1) ; D‚j… une donn‚e(<>0)?
		bne		Write_dat_err ; Alors il y a erreur.
		move.w		d0,(dat.freq-dat.sizeof.w,a1)
		bra.s		Write_dat_lp0

;		Si le caractŠre est >, le phonŠme pr‚c‚dent durera plus longtemps.
Write_dat_ok00:	cmpi.b		#'>',d0
		bne.s		Write_dat_ok01
		tst.w		(dat.freq-dat.sizeof.w,a1) ; DŠj… une donn‚e(<>0)?
		bne		Write_dat_err ; Alors il y a erreur.
		move.w		#$8000,(dat.freq-dat.sizeof.w,a1) ; Indique qu'il faudra augmenter le nombre de sons.
		bra.s		Write_dat_lp0

;		Si le caractŠre est <, le phonŠme pr‚c‚dent durera moins longtemps.
Write_dat_ok01:	cmpi.b		#'<',d0
		bne.s		Write_dat_ok02
		tst.w		(dat.freq-dat.sizeof.w,a1) ; D‚j… une donn‚e(<>0)?
		bne		Write_dat_err ; Si oui, il y a erreur.
		move.w		#$4000,(dat.freq-dat.sizeof.w,a1) ; Indique qu'il faudra diminuer le nombre de sons.
		bra.s		Write_dat_lp0

Write_dat_ok02:	bsr		Cv_upper ; Convertit en majuscules.
		move.b		d0,d1
		move.b		(a0),d0 ; Meme chose avec le caractŠre suivant.
		bsr		Cv_upper

; 		Stocke les offsets des phonŠmes dans tabstart.
		lea		Tabstart,a2
		move.l		(vox_pb.fgs.w,a5),d2
		btst.l		#vox_pb_form,d2
		beq.s		Write_dat_ok03
		lea		Tabstart2,a2
Write_dat_ok03:

		moveq		#0,d2
Write_dat_lp1:	cmp.b		(phoneme.ascii.b,a2,d2.w),d1 ; Compare 1Šre lettre du phonŠme avec celui de la table.
		bne.s		Write_dat_ok10
		cmpi.b		#' ',(phoneme.ascii+1.b,a2,d2.w) ; Le phonŠme de la table a-t-il 2 caractŠres?
		beq.s		Write_dat_ok12
		cmp.b		(phoneme.ascii+1.b,a2,d2.w),d0 ; Sinon, le deuxiŠme caractŠre correspond-il?
		beq.s		Write_dat_ok11
Write_dat_ok10:	addi.w		#phoneme.sizeof,d2 ; Prochain phonŠme dans la table.
		tst.b		(phoneme.ascii.b,a2,d2.w) ; Fin de la table?
		bpl.s		Write_dat_lp1
		bra.s		Write_dat_err ; Si oui, le phonŠme n'est pas trouv‚ et il y a erreur.

Write_dat_ok11:	addq.l		#1,a0 ; On avance dans le buffer puisque les 2 caractŠres correspondent.
Write_dat_ok12:	cmpi.b		#' ',(phoneme.ascii.b,a2,d2.w) ; La qualit‚ de la parole est meilleure si l'on saute les espace.
		beq		Write_dat_lp0
		move.w		d2,(dat.offset.w,a1) ; Sauve offset(par rapport au d‚but de la table).
		clr.w		(dat.freq.w,a1) ; Laisse de la place pour la fr‚quence,
		clr.w		(dat.lgt.w,a1) ; et pour la longueur du phonŠme.
		lea		(dat.sizeof.w,a1),a1 ; Prochaine donn‚e.
		bra		Write_dat_lp0 ; On boucle.

Write_dat_end:	move.w		#p__Q,(dat.offset.w,a1) ; Offset de fin.
		clr.w		(dat.freq.w,a1)
		clr.w		(dat.lgt.w,a1)
		lea		(dat.sizeof.w,a1),a1
		move.w		#-1,(dat.offset.w,a1) ; Fin des don‚es.
		move.w		#-1,(dat.freq.w,a1)
		move.w		#-1,(dat.lgt.w,a1)
		move.w		d6,(vox_inf.dat_nb.w,a6)
		bset		#2,(1.w,sp)
		rtr
Write_dat_err:	move.l		d5,d0
		bclr		#2,(1.w,sp)
		rtr

;----------------------------------------------------------------
;		Transformation de certains phonŠmes dans certains cas.
;----------------------------------------------------------------
Chk_dat0:	movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		lea		(dat.sizeof.w,a0),a0
Chk_dat0_lp:	move.w		(dat.offset.w,a0),d0 ; Offset du phonŠme actuel.
		bmi		Chk_dat0_end ; Si fin des donn‚es, on sort.
		cmpi.w		#p_space,d0 ; Espace?
		beq		Chk_dat0_lp_ok ; Alors on boucle: il n'y a rien … changer.
		ble.s		Chk_dat0_ok00 ; Si inf‚rieur, on branche.

;		Si l'offset est sup‚rieur … $8e6, il s'agit d'un phonŠme qui en comprend
;en fait deux. Les deux mots(W) suivants les lettres repr‚sentants le phonŠme
;sont des offsets par rapport … tabstart qui pointe chacun sur un phonŠme(simple celui-la).
;Le premier phonŠme vient remplacer l'actuel et le second est ins‚r‚.
		move.w		(2.b,a1,d0.w),(dat.offset.w,a0) ; Remplace le phonŠme actuel.
		move.w		(4.b,a1,d0.w),d1
		move.w		(dat.freq.w,a0),d2 ; Garde la hauteur du phonŠme.
		moveq		#0,d3
		lea		(dat.sizeof.w,a0),a0
		bsr		Shift ; D‚cale et insert.
		lea		(-dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d0

;		Ajoute des phonŠmes dans certains cas.
Chk_dat0_ok00:
; Pour les phonŠmes EY,AY et OY, on ajoute le phonŠme YX.
		cmpi.w		#p_UW,d0 ; 'UW'.
		bgt.s		Chk_dat0_ok10
		move.w		#p_YX,d1 ; 'YX'.
; Pour les phonŠmes AW,OW et UW, on ajoute le phonŠme WX.
		cmpi.w		#p_OY,d0 ; 'OY'.
		ble.s		Chk_dat0_ok01
		move.w		#p_WX,d1 ; 'WX'.
; Ins‚re le nouveau phonŠme.
Chk_dat0_ok01:	move.w		(dat.freq.w,a0),d2 ; Hauteur.
		moveq		#0,d3
		lea		(dat.sizeof.w,a0),a0
		bsr		Shift
		lea		(-dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d0 ; PhonŠme actuel.

;		Effectue des replacements dans certains cas.

;	Cas du R.
; Si le phonŠme actuel est R, que le pr‚c‚dent est un phonŠme vocalique
;(inf‚rieur ou ‚gal … EH dans la table), et que le phonŠme suivant est aussi
;vocalique, alors le phonŠme R est remplac‚ par le phonŠme RX.
Chk_dat0_ok10:	cmpi.w		#p__R,d0 ; 'R'.
		bne.s		Chk_dat0_ok20
		move.w		(dat.offset-dat.sizeof.w,a0),d1 ; PhonŠme pr‚c‚dent.
		bmi		Chk_dat0_lp_ok
		cmpi.w		#p_EH,d1 ; 'EH'?.
		bgt		Chk_dat0_lp_ok
		move.w		(dat.offset+dat.sizeof.w,a0),d1 ; PhonŠme suivant.
		bmi		Chk_dat0_ok11
		cmpi.w		#p_EH,d1 ; 'EH'?.
		ble		Chk_dat0_lp_ok
Chk_dat0_ok11:	move.w		#p_RX,(dat.offset.w,a0) ; PhonŠme actuel='RX'.
		bra		Chk_dat0_lp_ok

;	Cas du L.
; Si le phonŠme actuel est L, que le pr‚c‚dent est un phonŠme vocalique et que
;le phonŠme suivant est aussi vocalique, alors le phonŠme L est remplac‚ par
;le phonŠme LX.
Chk_dat0_ok20:	cmpi.w		#p__L,d0 ; 'L'.
		bne.s		Chk_dat0_ok30
		move.w		(dat.offset-dat.sizeof.w,a0),d1 ; PhonŠme pr‚cedent.
		bmi		Chk_dat0_lp_ok
		cmpi.w		#p_EH,d1 ; 'EH'?
		bgt		Chk_dat0_lp_ok
		move.w		(dat.offset+dat.sizeof.w,a0),d1 ; PhonŠme suivant.
		bmi		Chk_dat0_ok21
		cmpi.w		#p_EH,d1 ; 'EH'?
		ble		Chk_dat0_lp_ok
Chk_dat0_ok21:	move.w		#p_LX,(dat.offset.w,a0) ; PhonŠme actuel='LX'.
		bra.s		Chk_dat0_lp_ok

;	Si le phonŠme actuel est un S.
Chk_dat0_ok30:	cmpi.w		#p__S,d0 ; 'S'.
		bne.s		Chk_dat0_lp_ok
; Si le phonŠme actuel est un S et qu'il est pr‚c‚d‚ du phonŠme G, alors le
;phonŠme S est remplac‚ par le phonŠme Z.
		cmpi.w		#p__G,(dat.offset-dat.sizeof.w,a0) ; 'G'?
		bne.s		Chk_dat0_ok40
		move.w		#p__Z,(dat.offset.w,a0) ; PhonŠme actuel='Z'.
		bra.s		Chk_dat0_lp_ok
; Si le premier phonŠme (le phonŠme actuel) est un S, que le troisiŠme est
;vocalique et que le deuxiŠme phonŠme est P, alors le deuxiŠme phonŠme (P) est
;remplac‚ par le phonŠme B.
Chk_dat0_ok40:	cmpi.w		#p_EH,(dat.offset+2*dat.sizeof.w,a0) ; 'EH'.
		bgt.s		Chk_dat0_lp_ok
		cmpi.w		#p__P,(dat.offset+dat.sizeof.w,a0) ; 'P'.
		bne.s		Chk_dat0_ok50
		move.w		#p__B,(dat.offset+dat.sizeof.w,a0) ; PhonŠme suivant='B'.
		bra.s		Chk_dat0_lp_ok
; Si le premier phonŠme est un S, que le troisiŠme est vocalique et que le
;deuxiŠme phonŠme est un T, alors le deuxiŠme phonŠme (T) est remplac‚ par le
;phonŠme D.
Chk_dat0_ok50:	cmpi.w		#p__T,(dat.offset+dat.sizeof.w,a0) ; 'T'.
		bne.s		Chk_dat0_ok60
		move.w		#p__D,(dat.offset+dat.sizeof.w,a0) ; PhonŠme suivant='D'.
		bra.s		Chk_dat0_lp_ok
; Si le premier phonŠme est un S, que le troisiŠme est vocalique et que le
;deuxiŠme phonŠme est un K, alors le deuxiŠme phonŠme (K) est remplac‚ par le
;phonŠme G.
Chk_dat0_ok60:	cmpi.w		#p__K,(dat.offset+dat.sizeof.w,a0) ; 'K'.
		bne.s		Chk_dat0_lp_ok
		move.w		#p__G,(dat.offset+dat.sizeof.w,a0) ; PhonŠme suivant='G'.

Chk_dat0_lp_ok:	lea		(dat.sizeof.w,a0),a0
		tst.w		(dat.offset.w,a0)
		bpl		Chk_dat0_lp
Chk_dat0_end:	rts

;----------------------------------------------------------------
;		Lien entre un phonŠme consonantique et phonŠme vocalique.
;----------------------------------------------------------------
Chk_dat1:	movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		bra.s		Chk_dat1_lp_ok

Chk_dat1_lp:
; Recherche un phonŠme consonantique (>EH et <S dans la table).
		cmpi.w		#p_EH,d0 ; 'EH'.
		ble.s		Chk_dat1_lp_ok
		cmpi.w		#p__S,d0 ; 'S'.
		bge.s		Chk_dat1_lp_ok
; Si le phonŠme suivant est vocalique (<EH dans la table), on recopie sa
;hauteur sur le phonŠme consonantique.
		move.w		(dat.offset+dat.sizeof.w,a0),d0 ; PhonŠme suivant.
		bmi		Chk_dat1_lp_ok
		cmpi.w		#p_EH,d0 ; 'EH'.
		bgt.s		Chk_dat1_lp_ok
		move.w		(dat.freq+dat.sizeof.w,a0),d0
		beq.s		Chk_dat1_lp_ok
		move.w		d0,(dat.freq.w,a0)

Chk_dat1_lp_ok:	lea		(dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d0
		bpl.s		Chk_dat1_lp
		rts

;----------------------------------------------------------------
;		Cas de phonŠmes multiples.
;----------------------------------------------------------------
; Si le bit 7 de fgs est mis, alors il faut ins‚rer le phonŠme qui suit
;(dans la table) celui-ci.
Chk_dat2:	movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		bra.s		Chk_dat2_lp_ok

Chk_dat2_lp:	btst		#7,(phoneme.fgs.b,a1,d0.w)
		beq.s		Chk_dat2_lp_ok
		move.w		d0,d1
		addi.w		#phoneme.sizeof,d1
		move.w		(dat.freq.w,a0),d2
		moveq		#0,d3
		lea		(dat.sizeof.w,a0),a0
		bsr		Shift
		bra.s		Chk_dat2_ok0
Chk_dat2_lp_ok:	lea		(dat.sizeof.w,a0),a0
Chk_dat2_ok0:	move.w		(dat.offset.w,a0),d0
		bpl.s		Chk_dat2_lp
		rts

;----------------------------------------------------------------
;		Fixe la dur‚e et la hauteur du phonŠme.
;----------------------------------------------------------------
Chk_dat3:	movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		bra.s		Chk_dat3_lp_ok

Chk_dat3_lp:	move.w		(phoneme.lgt2.b,a1,d0.w),d1 ; Longueur par d‚faut 1 du phonŠme.
		move.w		(dat.freq.w,a0),d2 ; Si le bit 7 est mis,
		bpl.s		Chk_dat3_ok0
		move.w		d1,d3 ; on augmente la longueur du phonŠme:
		lsr.w		#1,d3 ; x=x+x/2+1.
		addq.w		#1,d3
		add.w		d3,d1
		bra.s		Chk_dat3_ok2

Chk_dat3_ok0:	btst.l		#14,d2 ; Si le bit 6 est mis,
		bpl.s		Chk_dat3_ok1
		lsr.w		#1,d1 ; on diminue la longueur du phonŠme:
		addq.w		#1,d1 ; x=x/2+1.
		bra.s		Chk_dat3_ok2

Chk_dat3_ok1:	tst.w		d2 ; Si non nul,
		beq.s		Chk_dat3_ok2
		move.w		(phoneme.lgt1.b,a1,d0.w),d1 ; on utilise la longueur par d‚faut 2.

Chk_dat3_ok2:	andi.w		#$3f,d2
		move.w		d2,(dat.freq.w,a0) ; Sauve hauteur.
		move.w		d1,(dat.lgt.w,a0) ; Sauve nombre de sons.

Chk_dat3_lp_ok:	lea		(dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d0
		bpl.s		Chk_dat3_lp
		rts

;----------------------------------------------------------------
;		Ponctuation.
;----------------------------------------------------------------
Chk_dat4:	movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		bra.s		Chk_dat4_lp0_ok

Chk_dat4_lp0:	cmpi.w		#p__S,d0 ; 'S': si sup‚rieur au phonŠme S dans la table,
		ble.s		Chk_dat4_lp0_ok ; Il s'agit d'un phonŠme de ponctuation.
		moveq		#0,d6

; Recherche alors en arriŠre jusqu'… une autre ponctuation (dont l'espace)
;ou une voyelle.
Chk_dat4_lp1:	subi.l		#dat.sizeof,d6
		move.w		(dat.offset.b,a0,d6.l),d0
		bmi.s		Chk_dat4_lp0_ok
		cmpi.w		#p__S,d0 ; 'S'.
		bgt.s		Chk_dat4_lp2_ok
		cmpi.w		#p_EH,d0 ; 'EH'.
		bgt.s		Chk_dat4_lp1

; Augmente le nombre de sons du phonŠme si le bit 5 et/ou le bit 6 est/sont
;mis dans la donn‚e 32 du phonŠme dans la tabstart.
		bra.s		Chk_dat4_lp2_ok
Chk_dat4_lp2:	move.w		(dat.offset.b,a0,d6.l),d1
		btst		#5,(phoneme.fgs.b,a1,d0.w)
		beq.s		Chk_dat4_ok0
		btst		#6,(phoneme.fgs.b,a1,d0.w)
		beq.s		Chk_dat4_lp2_ok
Chk_dat4_ok0:	move.w		(dat.lgt.b,a0,d6.l),d1 ; Augmente la longueur de ce phonŠme.
		lsr.w		#1,d1
		addq.w		#1,d1
		add.w		d1,(dat.lgt.b,a0,d6.l) ; x=x+x/2+1.
Chk_dat4_lp2_ok: addi.l		#dat.sizeof,d6
		bne.s		Chk_dat4_lp2

Chk_dat4_lp0_ok: lea		(dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d0
		bpl.s		Chk_dat4_lp0
		rts

;----------------------------------------------------------------
;		D‚cale les donn‚es de 4 octets(1 position).
;Entr‚es:
; -d1.w: offset.		-a0: adresse actuelle dans le buffer.
; -d2.b: donn‚e 1.
; -d3.b: donn‚e 2.
;----------------------------------------------------------------
Shift:		move		ccr,-(sp)
		movem.l		d6-d7/a1,-(sp)
		moveq		#0,d7
		move.w		(vox_inf.dat_nb.w,a6),d7 ; Nombre de donn‚es.
		mulu.w		#dat.sizeof,d7
		move.l		(vox_pb.dat_size.w,a5),d6 ; Taille max du buffer.
		subi.l		#dat.sizeof,d6 ; dat.sizeof.
		cmp.l		d6,d7 ; Si dat_lgt>dat_size-dat.sizeof, alors erreur.
		bgt.s		Shift_err

		movea.l		(vox_pb.phoneme_dat_addr.w,a5),a1
		adda.l		d7,a1 ; Adresse de la fin des donn‚es.
		bra.s		Shift_lp_ok
Shift_lp:	move.w		(dat.offset.w,a1),(dat.offset+dat.sizeof.w,a1)
		move.w		(dat.freq.w,a1),(dat.freq+dat.sizeof.w,a1)
		move.w		(dat.lgt.w,a1),(dat.lgt+dat.sizeof.w,a1)
Shift_lp_ok:	lea		(-dat.sizeof.w,a1),a1
		cmpa.l		a0,a1
		bge.s		Shift_lp

Shift_ok:	move.w		d1,(dat.offset.w,a0) ; Insert les nouvelles donn‚es.
		move.w		d2,(dat.freq.w,a0)
		move.w		d3,(dat.lgt.w,a0)
		addq.w		#1,(vox_inf.dat_nb.w,a6)
		movem.l		(sp)+,d6-d7/a1
		bset		#2,(1.w,sp) ; OK.
		rtr
Shift_err:	moveq		#err_phonemedatlgt,d0 ; Buffer trop petit.
		movem.l		(sp)+,d6-d7/a1
		bclr		#2,(1.w,sp) ; Erreur.
		rtr

;----------------------------------------------------------------
;		DATAS.
;----------------------------------------------------------------
;****************************************************************


;****************************************************************
;		Calcule des donn‚es sample.
;****************************************************************
;----------------------------------------------------------------
;		Routine g‚n‚rale.
;----------------------------------------------------------------
Calc_snd:	move		ccr,-(sp)
		move.l		(vox_inf.fgs.w,a6),d7
		bclr.l		#vox_inf_snd_fg,d7
		move.l		d7,(vox_inf.fgs.w,a6)

		lea		Calc_buf,a4
		movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0

		lea		Tabstart,a1
		move.l		(vox_pb.fgs.w,a5),d7
		btst.l		#vox_pb_form,d7
		beq.s		Calc_snd_ok0
		lea		Tabstart2,a1
Calc_snd_ok0:
		movea.l		(vox_pb.snd_addr.w,a5),a2


;		Efface d'abord le buffer.
		moveq		#0,d0
		lea		(a2),a3
		move.w		(vox_inf.snd_nb.w,a6),d7
		bra.s		Calc_snd_clear_lp_ok
Calc_snd_clear_lp: move.l	d0,(a3)+
		move.l		d0,(a3)+
		move.l		d0,(a3)+
		move.l		d0,(a3)+
		move.w		d0,(a3)+
Calc_snd_clear_lp_ok: dbf	d7,Calc_snd_clear_lp


;		Boucle principale.
		move.w		d0,(calc.freq_lgt.w,a4)
		move.w		d0,(calc.vol_lgt.w,a4)
		bra		Calc_snd_lp0_ok
Calc_snd_lp0:	move.w		(phoneme.wfreq10.b,a1,d0.w),(calc.freq1.w,a4)
		move.w		(phoneme.wfreq20.b,a1,d0.w),(calc.freq2.w,a4)
		move.w		(phoneme.wfreq30.b,a1,d0.w),(calc.freq3.w,a4)
		move.w		(phoneme.wvol10.b,a1,d0.w),(calc.vol1.w,a4)
		move.w		(phoneme.wvol20.b,a1,d0.w),(calc.vol2.w,a4)
		move.w		(phoneme.wvol30.b,a1,d0.w),(calc.vol3.w,a4)
		move.w		(phoneme.noise_vol0.b,a1,d0.w),(calc.noise_vol.w,a4)
		clr.w		(calc.freq_pos.w,a4) ; Position … 0.
		clr.w		(calc.vol_pos.w,a4) ; Position … 0.

		move.w		(dat.lgt.w,a0),d2 ; Nombre de sons du phonŠme actuel.
; Si le nombre de sons pour la fr‚quence dans les donn‚es calcul‚es pour ce
;phonŠme est < au nombre de sons calcul‚ … la boucle pr‚c‚dente pour le
;phonŠme pr‚c‚dent, alors c'est le premier qui devient le nombre de sons.
		cmp.w		(calc.freq_lgt.w,a4),d2
		bge.s		Calc_snd_ok00
		move.w		d2,(calc.freq_lgt.w,a4)
; Meme chose avec le nombre de sons pour le volume.
Calc_snd_ok00:	cmp.w		(calc.vol_lgt.w,a4),d2
		bge.s		Calc_snd_ok01
		move.w		d2,(calc.vol_lgt.w,a4)
Calc_snd_ok01:
		bsr		Intrpl_snd ; Interpole.

		move.w		(calc.freq_lgt.w,a4),(calc.freq_pos.w,a4) ; Position pour le calcul suivant.
		move.w		(calc.vol_lgt.w,a4),(calc.vol_pos.w,a4) ; Position pour le calcul suivant.
		move.w		(calc.freq1.w,a4),(calc.last_freq1.w,a4) ; Pour la boucle suivante.
		move.w		(calc.freq2.w,a4),(calc.last_freq2.w,a4)
		move.w		(calc.freq3.w,a4),(calc.last_freq3.w,a4)
		move.w		(calc.vol1.w,a4),(calc.last_vol1.w,a4)
		move.w		(calc.vol2.w,a4),(calc.last_vol2.w,a4)
		move.w		(calc.vol3.w,a4),(calc.last_vol3.w,a4)
		move.w		(calc.noise_vol.w,a4),(calc.last_noise_vol.w,a4)


;		.
		move.w		(dat.offset+dat.sizeof.w,a0),d1 ; Offset du phoneme suivant.
		bmi		Calc_snd2
; Priorit‚ du nombre de sons du phonŠme actuel par rapport … celle du phonŠme
;suivant.
		move.w		(phoneme.priority.w,a1,d0.w),d2
		cmp.w		(phoneme.priority.w,a1,d1.w),d2
		bge.s		Calc_snd_ok10
		move.w		(phoneme.freq_lgt1.w,a1,d1.w),(calc.freq_lgt.w,a4)
		move.w		(phoneme.freq_lgt0.w,a1,d1.w),(calc.nxt_freq_lgt.w,a4)
		move.w		(phoneme.vol_lgt1.w,a1,d1.w),(calc.vol_lgt.w,a4)
		move.w		(phoneme.vol_lgt0.w,a1,d1.w),(calc.nxt_vol_lgt.w,a4)
		exg		d0,d1
		bra.s		Calc_snd_ok11
Calc_snd_ok10:	move.w		(phoneme.freq_lgt1.w,a1,d0.w),(calc.nxt_freq_lgt.w,a4)
		move.w		(phoneme.freq_lgt0.w,a1,d0.w),(calc.freq_lgt.w,a4)
		move.w		(phoneme.vol_lgt1.w,a1,d0.w),(calc.nxt_vol_lgt.w,a4)
		move.w		(phoneme.vol_lgt0.w,a1,d0.w),(calc.vol_lgt.w,a4)
Calc_snd_ok11:

		move.w		(dat.lgt.w,a0),d2 ; Nombre de sons du phonŠme actuel.
; Si le nombre de sons pour la fr‚quence dans les donn‚es calcul‚es pour ce
;phonŠme est < au nombre de sons calcul‚ … la boucle pr‚c‚dente pour le
;phonŠme pr‚c‚dent, alors c'est le premier qui devient le nombre de sons.
		cmp.w		(calc.freq_lgt.w,a4),d2
		bge.s		Calc_snd_ok12
		move.w		d2,(calc.freq_lgt.w,a4)
; Meme chose avec le nombre de sons pour le volume.
Calc_snd_ok12:	cmp.w		(calc.vol_lgt.w,a4),d2
		bge.s		Calc_snd_ok13
		move.w		d2,(calc.vol_lgt.w,a4)
Calc_snd_ok13:


;	Calcul des transitions des fr‚quences et des volumes.
; P‚riode 1.
; Si c'est R, on ne calcule pas le premier.
		cmpi.w		#p__R,d1 ; Offset de 'R'.
		bne.s		Calc_snd_ok20
		moveq		#0,d2
		bra.s		Calc_snd_ok21
Calc_snd_ok20:	move.w		(phoneme.wfreq10.w,a1,d1.w),d2
		move.w		(phoneme.freq_inf0.w,a1,d0.w),d3
		bsr		Calc
Calc_snd_ok21:	add.w		(phoneme.wfreq11.w,a1,d0.w),d2
		move.w		d2,(calc.freq1.w,a4)
; P‚riode 2.
		move.w		(phoneme.wfreq20.w,a1,d1.w),d2
		move.w		(phoneme.freq_inf0.w,a1,d0.w),d3
		bsr		Calc
		add.w		(phoneme.wfreq21.w,a1,d0.w),d2
		move.w		d2,(calc.freq2.w,a4)
; P‚riode 3.
		move.w		(phoneme.wfreq30.w,a1,d1.w),d2
		move.w		(phoneme.freq_inf1.w,a1,d0.w),d3
		bsr		Calc
		add.w		(phoneme.wfreq31.w,a1,d0.w),d2
		move.w		d2,(calc.freq3.w,a4)

; Volume 1.
		move.w		(phoneme.wvol10.w,a1,d1.w),d2
		move.w		(phoneme.vol_inf.w,a1,d0.w),d3
		bsr		Calc
		add.w		(phoneme.wvol11.w,a1,d0.w),d2
		move.w		d2,(calc.vol1.w,a4)
; Volume 2.
		move.w		(phoneme.wvol20.w,a1,d1.w),d2
		move.w		(phoneme.vol_inf.w,a1,d0.w),d3
		bsr		Calc
		add.w		(phoneme.wvol21.w,a1,d0.w),d2
		move.w		d2,(calc.vol2.w,a4)
; Volume 3.
		move.w		(phoneme.wvol30.w,a1,d1.w),d2
		move.w		(phoneme.vol_inf.w,a1,d0.w),d3
		bsr		Calc
		add.w		(phoneme.wvol31.w,a1,d0.w),d2
		move.w		d2,(calc.vol3.w,a4)
; Volume du bruit.
		move.w		(phoneme.noise_vol0.w,a1,d1.w),d2
		move.w		(phoneme.vol_inf.w,a1,d0.w),d3
		bsr		Calc
		add.w		(phoneme.noise_vol1.w,a1,d0.w),d2
		move.w		d2,(calc.noise_vol.w,a4)


;		Calcul des p‚riodes des sons qui ne vont pas etre interpol‚s.
		move.w		(dat.lgt.w,a0),d2 ; Nombre total de sons.
		sub.w		(calc.freq_pos.w,a4),d2
		sub.w		(calc.freq_lgt.w,a4),d2 ; Nombre de sons restants.
		ble.s		Calc_snd_ok30
		move.w		(calc.freq_pos.w,a4),d3
		mulu.w		#snd.sizeof,d3
		add.w		d2,(calc.freq_pos.w,a4) ; Avance la position.
		bra.s		Calc_snd_lp1_ok
Calc_snd_lp1:	move.w		(calc.last_freq1.w,a4),(snd.freq1.b,a2,d3.l) ; Fr‚quence 1.
		move.w		(calc.last_freq2.w,a4),(snd.freq2.b,a2,d3.l) ; Fr‚quence 2.
		move.w		(calc.last_freq3.w,a4),(snd.freq3.b,a2,d3.l) ; Fr‚quence 3.
		addi.l		#snd.sizeof,d3
Calc_snd_lp1_ok: dbf		d2,Calc_snd_lp1

;		Calcul des volumes des sons qui ne vont pas etre interpol‚s.
Calc_snd_ok30:	move.w		(dat.lgt.w,a0),d2 ; Nombre total de sons.
		sub.w		(calc.vol_pos.w,a4),d2
		sub.w		(calc.vol_lgt.w,a4),d2 ; Nombre de sons restants.
		ble.s		Calc_snd_ok31
		move.w		(calc.vol_pos.w,a4),d3
		mulu.w		#snd.sizeof,d3
		add.w		d2,(calc.vol_pos.w,a4) ; Avance la position.
		bra.s		Calc_snd_lp2_ok
Calc_snd_lp2:	move.w		(calc.last_vol1.w,a4),(snd.vol1.b,a2,d3.l) ; Volume 1.
		move.w		(calc.last_vol2.w,a4),(snd.vol2.b,a2,d3.l) ; Volume 2.
		move.w		(calc.last_vol3.w,a4),(snd.vol3.b,a2,d3.l) ; Volume 3.
		move.w		(calc.last_noise_vol.w,a4),(snd.noise_vol.b,a2,d3.l) ; Volume du bruit.
		addi.l		#snd.sizeof,d3
Calc_snd_lp2_ok: dbf		d2,Calc_snd_lp2
Calc_snd_ok31:

;		Interpole … nouveau.
		bsr		Intrpl_snd

;		Recopie les donn‚es pour le prochain phonŠme.
		move.w		(calc.freq1.w,a4),(calc.last_freq1.w,a4)
		move.w		(calc.freq2.w,a4),(calc.last_freq2.w,a4)
		move.w		(calc.freq3.w,a4),(calc.last_freq3.w,a4)
		move.w		(calc.vol1.w,a4),(calc.last_vol1.w,a4)
		move.w		(calc.vol2.w,a4),(calc.last_vol2.w,a4)
		move.w		(calc.vol3.w,a4),(calc.last_vol3.w,a4)
		move.w		(calc.noise_vol.w,a4),(calc.last_noise_vol.w,a4)
		move.w		(calc.nxt_freq_lgt.w,a4),(calc.freq_lgt.w,a4)
		move.w		(calc.nxt_vol_lgt.w,a4),(calc.vol_lgt.w,a4)

;		Prochain phonŠme.
		move.w		(dat.lgt.w,a0),d0
		mulu.w		#snd.sizeof,d0
		adda.l		d0,a2 ; Adresse des sons du prochain phonŠme.
Calc_snd_lp0_ok: lea		(dat.sizeof.w,a0),a0 ; Prochain phonŠme.
		move.w		(dat.offset.w,a0),d0 ; Offset du phonŠme.
		bpl		Calc_snd_lp0
		clr.w		(a2) ; Mot nul de fin de donn‚e.

;----------------------------------------------------------------
;		Positionne la fr‚quence du bruit des phonŠmes sur leurs sons.
;----------------------------------------------------------------
Calc_snd2:	movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		movea.l		(vox_pb.snd_addr.w,a5),a2
		bra.s		Calc_snd2_lp0_ok
Calc_snd2_lp0:	move.w		(dat.lgt.w,a0),d1 ; Nombre de sons.
		move.w		(phoneme.noise_freq.b,a1,d0.w),d2 ; Fr‚quence du bruit.
		bra.s		Calc_snd2_lp1_ok
Calc_snd2_lp1:	move.w		d2,(snd.noise_freq.w,a2)
		lea		(snd.sizeof.w,a2),a2
Calc_snd2_lp1_ok: dbf		d1,Calc_snd2_lp1

Calc_snd2_lp0_ok: lea		(dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d0
		bpl.s		Calc_snd2_lp0

;----------------------------------------------------------------
;		Calcul la hauteur de la voix pour chaque phonŠme.
;----------------------------------------------------------------
		movea.l		(vox_pb.phoneme_dat_addr.w,a5),a0
		movea.l		(vox_pb.snd_addr.w,a5),a2
		move.w		(vox_inf.tone.w,a6),d0 ; Hauteur normale.
		moveq		#0,d2
		bra		Calc_snd3_lp00_ok
Calc_snd3_lp00:	moveq		#0,d5
		move.w		(dat.lgt.w,a0),d5
		subq.w		#1,d5
		blt.s		Calc_snd3_lp00_ok
		cmpi.w		#p_space,d4 ; Offset de l'espace vide.
		beq.s		Calc_snd3_lp00 ; Alors on boucle.
		cmpi.w		#p__S,d4 ; Offset du S.
		bgt.s		Calc_snd3_ok20 ; Si sup‚rieur, il s'agit d'une ponctuation.
		tst.w		(dat.freq.w,a0) ; Si la donn‚e de hauteur de la voix n'est pas nulle, on branche.
		bne.s		Calc_snd3_ok10

;		Sinon, on revient progressivement … la hauteur normale, si 
;elle ne l'est pas.
Calc_snd3_lp01:	move.w		d0,(snd.freq.w,a2)
		cmp.w		(vox_inf.tone.w,a6),d0
		beq.s		Calc_snd3_lp01_ok
		blt.s		Calc_snd3_ok00
		subq.w		#1,d0 ; Si la valeur actuelle est >66, on la diminue.
		bra.s		Calc_snd3_lp01_ok
Calc_snd3_ok00:	addq.w		#1,d0 ; Si la valeur actuelle est <66, on l'augmente.
Calc_snd3_lp01_ok: lea		(snd.sizeof.w,a2),a2
		dbf		d5,Calc_snd3_lp01

;	Fin de la boucle.
Calc_snd3_lp00_ok: lea		(dat.sizeof.w,a0),a0
		move.w		(dat.offset.w,a0),d4
		bpl		Calc_snd3_lp00

;		Fin.
		move.l		(vox_inf.fgs.w,a6),d7
		bset.l		#vox_inf_snd_fg,d7
		move.l		d7,(vox_inf.fgs.w,a6)
		bset		#2,(1.w,sp) ; Z=1: OK.
		rtr


;		Si la donn‚e de hauteur de la voix n'est pas nulle, il faut
;changer la hauteur.
Calc_snd3_ok10:	move.w		(dat.freq.w,a0),d0
		move.w		d0,d7
		add.w		d0,d0
		add.w		d7,d0 ; *3.
		neg.w		d0
		add.w		(vox_inf.tone.w,a6),d0 ; Nouvelle hauteur augment‚e.
Calc_snd3_lp10:	move.w		d0,(snd.freq.w,a2) ; Nouvelle hauteur.
		lea		(snd.sizeof.w,a2),a2
		dbf		d5,Calc_snd3_lp10
		bra.s		Calc_snd3_lp00_ok


;		S'il s'agit d'une ponctuation, il faut augmenter ou diminuer
;la hauteur selon qu'il s'agit d'un point ou d'un point d'interrogation.
Calc_snd3_ok20:	moveq		#-tone_lgt,d2
		moveq		#0,d3
; On se d‚place en arriŠre de fa‡on … savoir sur combien de sons on doit
;modifier la hauteur de la voix: le maximum est sur 20 sons. Si on rencontre
;une autre ponctuation ou le d‚but des donn‚es avant d'avoir atteint ces 20
;sons, on calcule seulement pour les sons concern‚s.
Calc_snd3_lp20:	subi.l		#dat.sizeof,d3 ; Remonte dans les donn‚es.
		tst.w		(dat.offset.w,a0,d3.l) ; Fin des donn‚es?
		bmi.s		Calc_snd3_ok21 ; Si oui on s'arrete l….
		cmpi.w		#p__S,(dat.offset.w,a0,d3.l)
		bgt.s		Calc_snd3_ok21
		moveq		#0,d4
		add.w		(dat.lgt.b,a0,d3.l),d2 ; Ajoute le nombre de sons.
		blt.s		Calc_snd3_lp20 ; Si toujours <20, on boucle.
		moveq		#0,d2 ; 20 sons maximum.

; Positionne les paramŠtres selon le type de ponctuation.
Calc_snd3_ok21:	addi.w		#tone_lgt,d2 ; Nombre de sons … calculer.
		beq.s		Calc_snd3_ok ; Si nul on passe.
		cmpi.w		#p_point,(dat.offset.w,a0) ; Est-ce le point ('.') ?
		bne.s		Calc_snd3_ok22
		moveq		#1,d1 ; Si oui on fait diminuer la hauteur.
		bra.s		Calc_snd3_ok24
Calc_snd3_ok22:	cmpi.w		#p_question,(dat.offset.w,a0) ; Est-ce le point d'interrogation ('?') ?
		bne.s		Calc_snd3_ok23
		moveq		#-1,d1 ; Si oui on fait augmenter la hauteur.
		bra.s		Calc_snd3_ok24
Calc_snd3_ok23:	moveq		#1,d1 ; Il s'agit d'une autre ponctuation:
		lsr.w		#1,d2 ; on fait diminuer la hauteur et on
		addq.w		#1,d2 ; applique sur 2 fois moins de sons.

; Ecrit les nouvelles hauteurs.
Calc_snd3_ok24:	muls.w		#-snd.sizeof,d2 ; Offset pour se positionner aux sons pr‚c‚dents.
		moveq		#0,d3
Calc_snd3_lp21:	add.w		d1,d3 ; Augmente la valeur … ajouter … la hauteur.
		add.w		d3,(snd.freq.b,a2,d2.l)
		addi.l		#snd.sizeof,d2 ; Prochain son.
		ble.s		Calc_snd3_lp21

; Fin.
Calc_snd3_ok:	move.w		(vox_inf.tone.w,a6),d0 ; Hauteur normale: on remplit les
		bra		Calc_snd3_lp01 ; hauteurs des sons suivants.

;----------------------------------------------------------------
;		Petites routines de calcul appel‚es fr‚quemment.
;----------------------------------------------------------------
;		Fait un petit calcul.
Calc:		tst.w		d3
		beq.s		Calc_ok1
		subq.w		#1,d3
		bne.s		Calc_ok0
		asr.w		#1,d2
Calc_ok0:	rts
Calc_ok1:	moveq		#0,d2
		rts

;----------------------------------------------------------------
;		Calcul des volumes et des p‚riodes (en samples) de chaque son
;d'un phonŠme.
;----------------------------------------------------------------
Intrpl_snd:	movem.l		d0-d7/a0,-(sp)

;		Calcul des p‚riodes.
		moveq		#0,d0
		move.w		(calc.freq_pos.w,a4),d0
		mulu.w		#snd.sizeof,d0 ; Offset des sons en octets.
		lea		(a2,d0.l),a3 ; Adresse des sons.
; Fr‚quence du formant 1.
		move.w		(calc.last_freq1.w,a4),d0 ; Fr‚quence pr‚c‚dente(initiale).
		move.w		(calc.freq1.w,a4),d1 ; Fr‚quence finale.
		lea		(snd.freq1.w,a3),a0 ; .
		move.w		(calc.freq_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_freq ; Interpole les 2 fr‚quences.
; Fr‚quence du formant 2.
		move.w		(calc.last_freq2.w,a4),d0 ; Fr‚quence pr‚c‚dente(initiale).
		move.w		(calc.freq2.w,a4),d1 ; Fr‚quence finale.
		lea		(snd.freq2.w,a3),a0 ; .
		move.w		(calc.freq_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_freq ; Interpole les 2 fr‚quences.
; Fr‚quence du formant 3.
		move.w		(calc.last_freq3.w,a4),d0 ; Fr‚quence pr‚c‚dente(initiale).
		move.w		(calc.freq3.w,a4),d1 ; Fr‚quence finale.
		lea		(snd.freq3.w,a3),a0 ; .
		move.w		(calc.freq_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_freq ; Interpole entre les 2 fr‚quences.

;		Calcul des volumes.
		move.w		(calc.vol_pos.w,a4),d0
		mulu.w		#snd.sizeof,d0 ; Offset des sons en octets.
		lea		(a2,d0.l),a3 ; Adresse des sons.
; Volume du formant 1.
		move.w		(calc.last_vol1.w,a4),d0 ; Volume pr‚c‚dent(initial).
		move.w		(calc.vol1.w,a4),d1 ; Volume final.
		lea		(snd.vol1.w,a3),a0 ; .
		move.w		(calc.vol_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_vol ; Interpole entre les 2 volumes.
; Volume du formant 2.
		move.w		(calc.last_vol2.w,a4),d0 ; Volume pr‚c‚dent(initial).
		move.w		(calc.vol2.w,a4),d1 ; Volume final.
		lea		(snd.vol2.w,a3),a0 ; .
		move.w		(calc.vol_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_vol ; Interpole entre les 2 volumes.
; Volume du formant 3.
		move.w		(calc.last_vol3.w,a4),d0 ; Volume pr‚c‚dent(initial).
		move.w		(calc.vol3.w,a4),d1 ; Volume finale.
		lea		(snd.vol3.w,a3),a0 ; .
		move.w		(calc.vol_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_vol ; Interpole entre les 2 volumes.
; Volume du bruit.
		move.w		(calc.last_noise_vol.w,a4),d0 ; Volume pr‚c‚dent(initial).
		move.w		(calc.noise_vol.w,a4),d1 ; Volume final.
		lea		(snd.noise_vol.w,a3),a0 ; .
		move.w		(calc.vol_lgt.w,a4),d2 ; Nombre de sons pour lesquels il faut calculer.
		bsr		Intrpl_vol ; Interpole entre les 2 volumes.

		movem.l		(sp)+,d0-d7/a0
		rts

;----------------------------------------------------------------
;		Interpolation de la fr‚quence.
; -d0: fr‚quence initiale.
; -d1: fr‚quence finale.
; -d2: nombre de sons.
; -a0: adresse de la fr‚quence du premier son.
;----------------------------------------------------------------
Intrpl_freq:	ext.l		d2
		tst.l		d2 ; Si le nombre de sons est nul, alors fin.
		beq.s		Intrpl_freq_end
		
;		Calcul du pas d'interpolation.
		sub.w		d0,d1 ; freq1-freq0.
		swap		d1
		clr.w		d1
		divs.l		d2,d1 ; step=(freq1-freq0)/snd_nb

;		Calcul de la valeur de d‚part.
		move.l		d1,d3
		asr.l		#1,d3 ; /2.
		swap		d0
		clr.w		d0
		add.l		d3,d0 ; freq=freq0+step/2.
		swap		d0

;		Boucle d'interpolation.
		bra.s		Intrpl_freq_lp_ok
Intrpl_freq_lp:	tst.w		(a0) ; S'il n'y avait rien avant, on peut ‚crire directement la valeur.
		beq.s		Intrpl_freq_ok1
		tst.l		d1 ; Sinon, cela d‚pend si le pas est n‚gatif ou pas.
		bmi.s		Intrpl_freq_ok0
; S'il ne l'est pas, si la valeur ancienne est sup‚rieure … la nouvelle, on
;garde l'ancienne. Sinon, on ‚crit la nouvelle.
		cmp.w		(a0),d0
		bgt.s		Intrpl_freq_ok1
		bra.s		Intrpl_freq_ok2
; Si le pas est n‚gatif, c'est l'inverse: la nouvelle valeur n'est ‚crite que
;si elle est inf‚rieure … l'ancienne.
Intrpl_freq_ok0: cmp.w		(a0),d0
		bge.s		Intrpl_freq_ok2
Intrpl_freq_ok1: move.w		d0,(a0) ; Ecrit la nouvelle valeur.

Intrpl_freq_ok2: swap		d0
		add.l		d1,d0 ; freq+=step.
		swap		d0
		lea		(snd.sizeof.w,a0),a0 ; Prochain son.
Intrpl_freq_lp_ok: dbf		d2,Intrpl_freq_lp

Intrpl_freq_end: rts

;----------------------------------------------------------------
;		Interpolation du volume.
; -d0: volume initial.
; -d1: volume final.
; -d2: nombre de sons.
; -a0: adresse du volume du premier son.
;----------------------------------------------------------------
Intrpl_vol:	ext.l		d2
		tst.l		d2 ; Si le nombre de sons est nul, alors fin.
		beq.s		Intrpl_vol_end

;		Calcul du pas d'interpolation.
		sub.w		d0,d1 ; vol1-vol0.
		swap		d1
		clr.w		d1
		divs.l		d2,d1
		
;		Calcul de la valeur de d‚part.
		move.l		d1,d3
		asr.l		#1,d3 ; /2.
		swap		d0
		clr.w		d0
		add.l		d3,d0 ; vol=vol0+step/2.
		swap		d0

;		Boucle d'interpolation.
		bra.s		Intrpl_vol_lp_ok
Intrpl_vol_lp:	tst.w		(a0) ; S'il n'y avait rien avant, on peut ‚crire directement la valeur.
		beq.s		Intrpl_vol_ok1
		tst.l		d1 ; Sinon, cela d‚pend si le pas est n‚gatif ou pas.
		bmi.s		Intrpl_vol_ok0
; S'il ne l'est pas, si la valeur ancienne est sup‚rieure … la nouvelle, on
;garde l'ancienne. Sinon, on ‚crit la nouvelle.
		cmp.w		(a0),d0
		bgt.s		Intrpl_vol_ok1
		bra.s		Intrpl_vol_ok2
; Si le pas est n‚gatif, c'est l'inverse: la nouvelle valeur n'est ‚crite que
;si elle est inf‚rieure … l'ancienne.
Intrpl_vol_ok0:	cmp.w		(a0),d0
		bge.s		Intrpl_vol_ok2
Intrpl_vol_ok1:	move.w		d0,(a0) ; Ecrit la nouvelle valeur.

Intrpl_vol_ok2:	swap		d0
		add.l		d1,d0 ; vol+=step.
		swap		d0
		lea		(snd.sizeof.w,a0),a0 ; Prochain son.
Intrpl_vol_lp_ok: dbf		d2,Intrpl_vol_lp

Intrpl_vol_end:	rts
;****************************************************************


;****************************************************************
;		Calcul du sample.
;****************************************************************
;----------------------------------------------------------------
;		Routine principale.
;----------------------------------------------------------------
Synthesize:	move		ccr,-(sp)
		movea.l		(vox_pb.snd_addr.w,a5),a0
		movea.l		(vox_pb.spl_addr.w,a5),a1
		lea		Tone_tbl,a2
		lea		Synthesize_buf,a3
		lea		Sin_tbl,a4
		move.l		#sin_tbl_size*65536,d0 ; Table des sinus sur sin_tbl_size points.
		moveq		#0,d1
		move.w		(vox_inf.voice_freq.w,a6),d1
		divu.l		d1,d0 ; sin_tbl_size/F.
		move.l		d0,(synth.coef.w,a3)
		clr.l		(synth.tone_cnt.w,a3)

		moveq		#0,d1
		move.l		d1,(synth.freq1.w,a3)
		move.l		d1,(synth.vol1.w,a3)
		move.l		d1,(synth.freq2.w,a3)
		move.l		d1,(synth.vol2.w,a3)
		move.l		d1,(synth.freq3.w,a3)
		move.l		d1,(synth.vol3.w,a3)

		moveq		#0,d1
		move.l		d1,d2
		move.l		d1,d3
		move.l		d1,d5
		move.l		d1,d6

;		Boucle principale.
		move.w		(vox_inf.snd_nb.w,a6),d7
		bra		Synthesize_lp0_ok
Synthesize_lp0:	move.w		(vox_inf.rate.w,a6),d6

;		Calcul du pas de variation des volumes des formants.
; Formant 1.
		move.w		(snd.vol1.w,a0),d0
		swap		d0
		clr.w		d0
		move.l		(synth.vol1.w,a3),d4
		bgt.s		Synthesize_ok00
		move.l		d0,d4
		move.l		d4,(synth.vol1.w,a3)
Synthesize_ok00: sub.l		d4,d0
		divs.l		d6,d0
		move.l		d0,(synth.vol_stp1.w,a3)
; Formant 2.
		move.w		(snd.vol2.w,a0),d0
		swap		d0
		clr.w		d0
		move.l		(synth.vol2.w,a3),d4
		bgt.s		Synthesize_ok01
		move.l		d0,d4
		move.l		d4,(synth.vol2.w,a3)
Synthesize_ok01: sub.l		d4,d0
		divs.l		d6,d0
		move.l		d0,(synth.vol_stp2.w,a3)
; Formant 3.
		move.w		(snd.vol3.w,a0),d0
		swap		d0
		clr.w		d0
		move.l		(synth.vol3.w,a3),d4
		bgt.s		Synthesize_ok02
		move.l		d0,d4
		move.l		d4,(synth.vol3.w,a3)
Synthesize_ok02: sub.l		d4,d0
		divs.l		d6,d0
		move.l		d0,(synth.vol_stp3.w,a3)

;		Calcul du pas dans la table des sinus (p=sin_tbl_size*Fp/F) et du
;pas de variation de la fr‚quence pour chaque formant.
; Fr‚quence du formant 1.
		moveq		#0,d0
		move.w		(snd.freq1.w,a0),d0 ; Fr‚quence 1.
		mulu.l		(synth.coef.w,a3),d0
		bne.s		Synthesize_ok10
		clr.l		(synth.vol1.w,a3)
		clr.l		(synth.vol_stp1.w,a3)
Synthesize_ok10: move.l		(synth.freq1.w,a3),d4
		bne.s		Synthesize_ok11
		move.l		d0,d4
		move.l		d4,(synth.freq1.w,a3)
Synthesize_ok11: sub.l		d4,d0
		divs.l		d6,d0
		move.l		d0,(synth.freq_stp1.w,a3)
; Fr‚quence du formant 2.
		moveq		#0,d0
		move.w		(snd.freq2.w,a0),d0 ; Fr‚quence 2.
		mulu.l		(synth.coef.w,a3),d0
		bne.s		Synthesize_ok12
		clr.l		(synth.vol2.w,a3)
		clr.l		(synth.vol_stp2.w,a3)
Synthesize_ok12: move.l		(synth.freq2.w,a3),d4
		bne.s		Synthesize_ok13
		move.l		d0,d4
		move.l		d4,(synth.freq2.w,a3)
Synthesize_ok13: sub.l		d4,d0
		divs.l		d6,d0
		move.l		d0,(synth.freq_stp2.w,a3)
; Fr‚quence du formant 3.
		moveq		#0,d0
		move.w		(snd.freq3.w,a0),d0 ; Fr‚quence 3.
		mulu.l		(synth.coef.w,a3),d0
		bne.s		Synthesize_ok14
		clr.l		(synth.vol3.w,a3)
		clr.l		(synth.vol_stp3.w,a3)
Synthesize_ok14: move.l		(synth.freq3.w,a3),d4
		bne.s		Synthesize_ok15
		move.l		d0,d4
		move.l		d4,(synth.freq3.w,a3)
Synthesize_ok15: sub.l		d4,d0
		divs.l		d6,d0
		move.l		d0,(synth.freq_stp3.w,a3)


;		Volume et fr‚quence du bruit.
		move.w		(snd.noise_vol.w,a0),(vox_inf.noise_vol.w,a6) ; Volume du bruit.
		move.w		(snd.noise_freq.w,a0),(vox_inf.noise_freq.w,a6) ; Fr‚quence du bruit.
		clr.w		(vox_inf.noise_cnt.w,a6)
;		Calcul des samples.
		bra		Synthesize_lp1_ok
Synthesize_lp1:	dbf		d5,Synthesize_ok1
		moveq		#0,d5
		move.l		d5,d1
		move.l		d5,d2
		move.l		d5,d3
		
		move.w		(snd.freq.w,a0),d5 ; pitch (hauteur du son).
		move.l		#1024*65536,d0
		divu.l		d5,d0
		move.l		d0,(synth.tone_stp.w,a3)
		clr.l		(synth.tone_cnt.w,a3)

Synthesize_ok1:
; Calcul des positions dans la table des sinus et des fr‚quences.
		move.l		(synth.freq1.w,a3),d0
		swap		d1
		add.l		d0,d1
		swap		d1
		andi.w		#sin_tbl_size-1,d1
		add.l		(synth.freq_stp1.w,a3),d0
		move.l		d0,(synth.freq1.w,a3)

		move.l		(synth.freq2.w,a3),d0
		swap		d2
		add.l		d0,d2
		swap		d2
		andi.w		#sin_tbl_size-1,d2
		add.l		(synth.freq_stp2.w,a3),d0
		move.l		d0,(synth.freq2.w,a3)

		move.l		(synth.freq3.w,a3),d0
		swap		d3
		add.l		d0,d3
		swap		d3
		andi.w		#sin_tbl_size-1,d3
		add.l		(synth.freq_stp3.w,a3),d0
		move.l		d0,(synth.freq3.w,a3)

; Somme des amplitudes des sinusoides.
		move.l		(synth.vol1.w,a3),d4
		add.l		(synth.vol_stp1.w,a3),d4
		move.l		d4,(synth.vol1.w,a3)
		swap		d4
		ext.l		d4
		muls.l		(a4,d1.w*4),d4

		move.l		(synth.vol2.w,a3),d0
		add.l		(synth.vol_stp2.w,a3),d0
		move.l		d0,(synth.vol2.w,a3)
		swap		d0
		ext.l		d0
		muls.l		(a4,d2.w*4),d0
		add.l		d0,d4

		move.l		(synth.vol3.w,a3),d0
		add.l		(synth.vol_stp3.w,a3),d0
		move.l		d0,(synth.vol3.w,a3)
		swap		d0
		ext.l		d0
		muls.l		(a4,d3.w*4),d0
		add.l		d0,d4
		swap		d4
		ext.l		d4

; Ton laryngien.
		move.l		(synth.tone_cnt.w,a3),d0
		swap		d0
		muls.l		(a2,d0.w*4),d4
		swap		d4
		swap		d0
		add.l		(synth.tone_stp.w,a3),d0
		move.l		d0,(synth.tone_cnt.w,a3)

; Bruit.
		tst.w		(snd.noise_vol.w,a0) ; Volume du bruit nul?
		beq.s		Synthesize_ok2
		bsr		Noise
		add.w		d0,d4
Synthesize_ok2:

		move.w		d4,(a1)+
		move.w		d4,(a1)+

Synthesize_lp1_ok: dbf		d6,Synthesize_lp1

		lea		(snd.sizeof.w,a0),a0 ; Son suivant.
Synthesize_lp0_ok: dbf		d7,Synthesize_lp0


;		Fin.
Synthesize_end0: bset		#2,(1.w,sp) ; Z=1: OK.
		rtr
Synthesize_err:	bclr		#2,(1.w,sp) ; Z=0: Erreur.
		rtr
Synthesize_buf:	ds.b		256

;----------------------------------------------------------------
;		G‚n‚rateur de bruits(indentique au PSG).
;----------------------------------------------------------------
Noise:		move.l		d1,-(sp)

		subq.w		#1,(vox_inf.noise_cnt.w,a6)
		bpl.s		Noise_ok1

;		.
		move.w		(vox_inf.noise_freq.w,a6),d1
		beq.s		Noise_err

		not.w		(vox_inf.noise_sgn.w,a6) ; Change le signe du signal.

		bsr		Random
		andi.w		#$ffff,d0
		mulu.w		#4500,d0
		clr.w		d0
		swap		d0
		subi.w		#1500,d1
		add.w		d1,d0

		move.w		(vox_inf.freq.w,a6),d1
		lsr.w		#1,d1
		subi.w		#1000,d1
		cmp.w		d1,d0
		blt.s		Noise_ok0
		move.w		d1,d0

Noise_ok0:	moveq		#0,d1
		move.w		(vox_inf.freq.w,a6),d1
		
		divu.l		d0,d1
		lsr.l		#1,d1
		move.w		d1,(vox_inf.noise_cnt.w,a6)

;		.
Noise_ok1:	move.w		(vox_inf.noise_vol.w,a6),d0
		tst.w		(vox_inf.noise_sgn.w,a6)
		bpl.s		Noise_ok2
		neg.w		d0
Noise_ok2:	move.l		(sp)+,d1
		rts
Noise_err:	moveq		#0,d0
		clr.w		(vox_inf.noise_cnt.w,a6)
		move.l		(sp)+,d1
		rts
;----------------------------------------------------------------
;		G‚n‚rateur de nombre pseudo-al‚atoires.
;----------------------------------------------------------------
Random:		move.l		Random_nb,d0
;		bne.s		Random_ok
; Randomize.
;		move.l		$4ba,d0
;		asl.l		#8,d0
;		asl.l		#8,d0
;		or.l		$4ba,d0
;Random_ok:
; Calcul du prochain nombre.
		muls.l		#$bb40e62d,d0
		addq.l		#1,d0
		move.l		d0,Random_nb
		asr.l		#8,d0
		andi.l		#$ffffff,d0
		rts
Random_nb:	dc.l		$47796546
;****************************************************************


;****************************************************************
;		Routines de recalcul de la voix.
;****************************************************************
Recalc_form:	move		ccr,-(sp)
		lea		Tabstart,a0
		lea		Tabstart2,a1
		move.l		(vox_pb.formant_c1.w,a5),d0
		move.l		(vox_pb.formant_c2.w,a5),d1		
		move.l		(vox_pb.formant_c3.w,a5),d2

		moveq		#74-1,d7
Recalc_form_lp0: move.w		#phoneme.sizeof-1,d6
		lea		(a0),a2
		lea		(a1),a3
Recalc_form_lp1: move.b		(a2)+,(a3)+
		dbf		d6,Recalc_form_lp1
 		
 		moveq		#0,d3
		move.w		(phoneme.wfreq10.w,a0),d3
		mulu.l		d0,d3
		swap		d3
		move.w		d3,(phoneme.wfreq10.w,a1)

 		moveq		#0,d3
		move.w		(phoneme.wfreq11.w,a0),d3
		mulu.l		d0,d3
		swap		d3
		move.w		d3,(phoneme.wfreq11.w,a1)

 		moveq		#0,d3
		move.w		(phoneme.wfreq20.w,a0),d3
		mulu.l		d1,d3
		swap		d3
		move.w		d3,(phoneme.wfreq20.w,a1)

 		moveq		#0,d3
		move.w		(phoneme.wfreq21.w,a0),d3
		mulu.l		d1,d3
		swap		d3
		move.w		d3,(phoneme.wfreq21.w,a1)

 		moveq		#0,d3
		move.w		(phoneme.wfreq30.w,a0),d3
		mulu.l		d2,d3
		swap		d3
		move.w		d3,(phoneme.wfreq30.w,a1)		

 		moveq		#0,d3
		move.w		(phoneme.wfreq31.w,a0),d3
		mulu.l		d2,d3
		swap		d3
		move.w		d3,(phoneme.wfreq31.w,a1)

		lea		(phoneme.sizeof.w,a0),a0 ; Prochain phonŠme dans la table.
		lea		(phoneme.sizeof.w,a1),a1 ; Prochain phonŠme dans la table.
		dbf		d7,Recalc_form_lp0

Recalc_form_end0: bset	#2,(1.w,sp) ; Z=1: OK.
		rtr
Recalc_form_err: bclr	#2,(1.w,sp) ; Z=0: Erreur.
		rtr
;****************************************************************


;****************************************************************
;		Routines secondaires.
;****************************************************************
;----------------------------------------------------------------
;		Conversion d'un nombre ASCII.
;Entr‚e:
; -a0: adresse du nombre ASCII … convertir.
;Sortie:
; -d0: nombre convertit.
;----------------------------------------------------------------
Cv_ASCII:	movem.l		d1,-(sp)
		moveq		#0,d0
Cv_ASCII_lp:	move.b		(a0)+,d1
		andi.w		#$7f,d1
		subi.w		#$30,d1 ; -"0".
		blt.s		Cv_ASCII_ok
		cmpi.b		#9,d1 ; Est-ce un chiffre(0-9)?.
		bgt.s		Cv_ASCII_ok
		mulu.w		#10,d0 ; D‚cale d'une d‚cimale.
		add.w		d1,d0 ; Nouveau chiffre.
		bra.s		Cv_ASCII_lp
Cv_ASCII_ok:	movem.l		(sp)+,d1
		rts

;----------------------------------------------------------------
;		Convertion d'une lettre minuscule en majuscule.
;----------------------------------------------------------------
Cv_upper:	cmpi.b		#'a',d0
		blt.s		Cv_upper_ok
		cmpi.b		#'z',d0
		bgt.s		Cv_upper_ok
		subi.b		#$20,d0
Cv_upper_ok:	rts
;****************************************************************


;****************************************************************
;		Includes.
;****************************************************************
; Structures et equs.
		include		E:\ASSEMBLE\VOX\VOX_INC.S

; Initialisation.
use_scr		equ		false
use_snd		equ		false
use_it		equ		false
use_gem		equ		false
		include		E:\ASSEMBLE\INCLUDE\INIT\INIT_030.S
; .
		include		E:\ASSEMBLE\INCLUDE\TEXT.S
;****************************************************************


;****************************************************************
;		DATAs.
;****************************************************************
VOX_inf_buf:	ds.b		256
Calc_buf:	ds.b		256
;****************************************************************


;****************************************************************
;		Incbins.
;****************************************************************
Phoneme_tbl0:	incbin		PHON_TBL.DAT
Phoneme_tbl	equ		Phoneme_tbl0+4890
Tabstart:	incbin		TABSTAR2.DAT
Tabstart2:	ds.b		Tabstart2-Tabstart
sin_tbl_size	equ		4096
Sin_tbl:	incbin		SIN_TBL.DAT
Tone_tbl:	incbin		TONE.DAT
;****************************************************************

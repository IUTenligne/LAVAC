{************************************************}
{                                                }
{   Unité MMSTRING                               }
{                                                }
{   Projet LAVAC                                 }
{                                                }
{  (c) 1992-94 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }
{                                                }
{  par Guillaume de Bailliencourt                }
{                                                }
{  16/05/1994                                    }
{                                                }
{************************************************}

UNIT MMSTRING;

interface

uses Windows, Strings
		 {$IFDEF _DEBUG}
		 ,MMDEBUG
		 {$ENDIF};

const
ERR_CREATEFILE 		= 48; {Erreur de création de fichier.}
ERR_OPENFILE 			= 49; {Erreur d''ouverture de fichier.}
ERR_CREATECHUNK 	= 50; {Erreur de création du chunk.}
ERR_MEMALLOC 			= 51; {Erreur d''allocation mémoire.}
ERR_PREPARHDR 		= 52; {Erreur de préparation du block pour le périphérique.}
ERR_NEXTBLOCK 		= 53; {Erreur à l''enregistrement d''un block audio.}
ERR_WAVPERIPH 		= 54; {Erreur sur périphérique audio.}
ERR_MCI 					= 55; {Erreur MCI}
ERR_LESSONNAME 		= 56; {Le nom de la leçon est incorrect, modifiez le et recommencez.}
ERR_LESSONEXIST 	= 57; {Cette leçon existe déjà, \nvoulez vous :\n       la supprimer ? : [OUI]
												 \n       rajouter des sequences à
												 \n       l''ancienne ? : [NON]}
ERR_EXT 					= 58; {Ces fichiers ne sont liés à aucune application.}
ERR_LOCALSPACE 		= 59; {Il est Impossible d''utiliser la vidéo en local, \nl'espace disque local est insuffisant.\n
												 \nManquant : %lu octets}
ERR_DOSNUM 				= 60; {Erreur Dos : %d}
ERR_IONUM 				= 61; {Erreur I/O : %d}
STR_NONAME 				= 62; {Sans nom}
STR_STOP 					= 63; {&Stop}
STR_REC 					= 64; {Enregistre}
STR_START 				= 65; {&Démarre}
STR_PAUSE 				= 66; {Pause}
STR_RESTART 			= 67; {Enreg reprise}
STR_ENDREC 				= 68; {Enreg %d fin}
STR_STARTREC 			= 69; {Enreg %d début}
STR_BLANKREC 			= 70; {Enreg %d blanc}
STR_PROCESSREC 		= 71; {Enreg %d en cours}
STR_BLANK 				= 72; {Blanc : %ds}
STR_INSERTDISK 		= 73; {Insérez une disquette formatée et vierge...}
STR_INSNEXTDISK 	= 74; {Insérez le disque suivant de la sauvegarde...}
STR_INSANSDISK 		= 75; {Insérez la disquette ou se trouvent les réponses...}
STR_INSLASTDISK 	= 76; {Insérez la disquette suivante ou Annulez si la restauration est terminée...}
STR_TEACHER 			= 77; {Professeur}
STR_STUDENT 			= 78; {Etudiant}
STR_LESSON 				= 79; {Leçon}
STR_TEACHSTUD 		= 80; {Prof/Etud}
STR_EXE 					= 81; {Executable}
STR_BMP 					= 82; {Fichiers Image}
STR_AVI 					= 83; {Fichiers Vidéo}
STR_TXT 					= 84; {Fichiers Texte}
STR_WAV 					= 85; {Fichiers Son}
STR_QCM 					= 86; {Fichier QCM}
STR_LINKBMP 			= 87; {Image : Liée}
STR_LINKAVI 			= 88; {Vidéo : Liée}
STR_LINKTXT 			= 89; {Texte : Liée}
STR_LINKWAV 			= 90; {Son : Liée}
STR_LINKQCM 			= 91; {QCM : Liée}
STR_UNLINKBMP 		= 92; {Image : Non liée}
STR_UNLINKAVI 		= 93; {Vidéo : Non liée}
STR_UNLINKTXT 		= 94; {Texte : Non liée}
STR_UNLINKWAV 		= 95; {Son : Non liée}
STR_UNLINKQCM 		= 96; {QCM : Non liée}
STR_INITPOS 			= 97; {Position Initiale}
STR_STRECHED 			= 98; {Taille Adaptée}
STR_QCMANS 				= 99; {Réponses QCM}
STR_QCMEDIT 			= 100; {Modifier}
STR_QCMHIDE 			= 101; {Cacher la fenêtre QCM}
ERR_LOCALAVI 			= 102; {Impossible d''utiliser la vidéo en Local}
STR_STOPTEACH 		= 103; {Stop Prof}
STR_STOPSTUD 			= 104; {Stop Etud}
STR_STOPTEACHSTUD = 105; {Stop P/E}
STR_STOPREC 			= 106; {Stop Enreg}
STR_NONE 					= 107; {&Rien}
STR_ALL 					= 108; {&Tout}
STR_RESTORE 			= 109; {Restauration Réponses}
STR_ENDRESTORE 		= 110; {Restauration terminée.}
STR_MSG 					= 111; {Message}
STR_MSGSEL 				= 112; {Le professeur vous envoie une Leçon... Soyez prets à répondre...}
STR_MSGBMP 				= 113; {Le professeur vous envoie une image...}
STR_MSGTXT 				= 114; {Le professeur vous envoie un texte...}
STR_MSGWAV 				= 115; {Le professeur vous envoie un message sonore...}
STR_NEXT 					= 116; {Suite}
ERR_DIADIR 				= 117; {Ecoute ou Enregistrement sonore en cours, stoppez la pour dialoguer en direct.}
STR_DIADIR 				= 118; {Dialogue direct}
STR_STUDCON 			= 119; {Poste étudiant}
STR_SENDSEL 			= 120; {Envoi aux étudiants sélectionnés de la leçon No }

ERR_SRCDISK 			= 121; {Impossible d'accéder à l'unité source, opération interrompue.}
ERR_DSTDISK 			= 122; {Impossible d'accéder à l'unité cible, opération interrompue.}
ERR_ERR 		 			= 123; {Erreur}
ERR_SPCDISK 			= 124; {L'espace total requis sur l'unité cible est insuffisant, opération interrompue.}
STR_REMOVABLE			= 125; { (Amovible)}
STR_FIXED					= 126; { (Fixe)}
STR_KO						= 127; {%lu Ko}
STR_NOTKO					= 128; {? x %lu Ko}
STR_KOTOTAL				= 129; {%lu Ko total}
STR_NOTKOTOTAL		= 130; {? Ko total}
STR_KOFREE				= 131; {%lu Ko libre}
ERR_SRCLESSON			= 132; {Le fichier leçon source n'existe pas, opération interrompue.}
STR_CREATELESSON	= 133; {Création du fichier leçon, séquence n° %d...}
STR_COPYLESSON		= 134; {Copie du fichier leçon...}
STR_COPYFILE			= 135; {Copie du fichier\n}
STR_CURFILE				= 136; {\nFichier en cours : }
STR_COMPRESSLESSON= 137; {Compression des fichiers de la leçon...}
STR_COMPRESSFILE	= 138; {Compression du fichier }
STR_DELTEMP				= 139; {Destruction des fichiers temporaires...}
STR_WAITCOPY			= 140; {Copie en cours...}
STR_WAITRESTORE		= 141; {Restauration en cours...}
STR_WAITBACKUP		= 142; {Archivage en cours...}
STR_DELLESSON			= 143; {Voulez vous vraiment supprimer la leçon : \n}
STR_DEL						= 144; {Supprimer}
STR_LST						= 145; {Leçons LAVAC}


STR_TITRE         = 200; {QCM...}
ERR_GLOBALALLOC   = 201; {QCM...}
STR_QUITTE        = 202; {QCM...}
STR_OPEN          = 203; {QCM...}
ERR_STREAMERROR   = 204; {QCM...}
STR_TEXTLOAD      = 205; {QCM...}
STR_LOADLINE      = 206; {QCM...}
STR_SAVELINE      = 207; {QCM...}
STR_FIN           = 208; {QCM...}
STR_INCORRECT     = 210; {QCM...}
STR_APPEL         = 211; {QCM...}
STR_TOLINK        = 212; {QCM...}
STR_TOUNLINK      = 213; {QCM...}
STR_QUITTER       = 214; {QCM...}

STR_CMDFIRST      = 1000; {Commandes Lavac}

STR_ERRORFIRST    = 2000;

STR_MSGFIRST	    = 3000;

function mmLoadString(hInst : THANDLE; nID : integer) : PChar;

implementation
function mmLoadString(hInst : THANDLE; nID : integer) : PChar;

const alpszDup : Array[0..3] of PChar = (nil, nil, nil, nil);
			nDup 		 : integer = 0;
var szLoadString : Array[0..255] of char;

begin
	mmLoadString := '#Err!'+#0;
	if LoadString(hInst, nID, szLoadString, SizeOf(szLoadString)) > 0 then begin
		if alpszDup[nDup] <> nil then StrDispose(alpszDup[nDup]);
		alpszDup[nDup] := StrNew(szLoadString);
		if alpszDup[nDup] <> nil then begin
			mmLoadString := alpszDup[nDup];
			Inc(nDup);
			if nDup > 3 then nDup := 0;
		end;
	end;
end;

end.

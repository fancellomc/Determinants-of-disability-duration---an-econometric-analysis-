
/*****ETAPE 1: Le traitement des variables *******/ 

/*SUPPRESSION DES VAR QUE L'ON UTILISE PAS*/ 
data SIP; 
set microqua.SIP06; 
drop  eacom eahum eaethi ealour elip eahsem sq1g sq2g fepr fpermer flnais fnaip fnaim fhand fmaldu fsafa fdec fsep fcofam fdrog fviopr fgue zreli_1 eacap EDM TAG; 
run; 
 
data SIP; 
set SIP; 
IF duree_handi="" then delete; 
run; 

/*MODIFICATIONS DES VARIABLES*/ 
/*On crée une variable catégorielle pour les activités qui peuvent stimuler intellectuellement les individus*/ 
data SIP; 
set SIP; 
IF zben_1=1 or zsyn_1=1 or zpol_1=1 or zart_1=1 then activite_stimu=1; 
ELSE activite_stimu=0; 
drop zben_1 zsyn_1 zpol_1 zart_1; 
run; 
 
/*Nous attribuons des catégorie à la variable maladie_chronique*/ 
data SIP; 
set SIP; 
IF maladie_chronique="" then maladies_chroniques=0; 
IF maladie_chronique="Autre" then maladies_chroniques=1; 
IF maladie_chronique="Bouche et dents" then maladies_chroniques=1; 
IF maladie_chronique="Cancer" then maladies_chroniques=1; 
IF maladie_chronique="Cardio-vasculaire" then maladies_chroniques=1; 
IF maladie_chronique="Digestif" then maladies_chroniques=1; 
IF maladie_chronique="Dépendance" then maladies_chroniques=1; 
IF maladie_chronique="Endocrinienne ou métabolique" then maladies_chroniques=1; 
IF maladie_chronique="Nerveux ou psychique" then maladies_chroniques=1; 
IF maladie_chronique="Neurologique" then maladies_chroniques=1; 
IF maladie_chronique="ORL" then maladies_chroniques=1; 
IF maladie_chronique="Oculaire" then maladies_chroniques=1; 
IF maladie_chronique="Os et articulations" then maladies_chroniques=1; 
IF maladie_chronique="Peau" then maladies_chroniques=1; 
IF maladie_chronique="Pulmonaire" then maladies_chroniques=1; 
IF maladie_chronique="Urinaire et génital" then maladies_chroniques=1; 
drop maladie_chronique; 
run;

/*proc freq data=SIP; 
TABLES maladies_chroniques; 
run;*/

/*Variable catégorielle pour le nombre d'enfant*/ 
data SIP; 
set SIP; 
IF fnelev=0 then fnelev=0; 
ELSE IF fnelev=1 then fnelev=1; 
ELSE IF fnelev=2 then fnelev=2; 
ELSE IF fnelev=3 then fnelev=3;
ELSE IF fnelev>=4 then fnelev=4;  
run; 

/*Variable catégorielle pour la durée de chomage*/ 
data SIP; 
set SIP; 
IF duree_chomage="" then duree_chomage=0;
IF duree_chomage=1 then duree_chomage=6; 
IF duree_chomage=2 then duree_chomage=2; 
IF duree_chomage=3 then duree_chomage=3; 
IF duree_chomage=4 then duree_chomage=4;  
IF duree_chomage>=5 and duree_chomage<9999 then duree_chomage=1; 
IF duree_chomage=9999 then duree_chomage=5; 
run;


/*Taille finale de la base*/ 
proc contents data=SIP; run;

data SIP; 
set SIP; 
IF fnivdip="" then fnivdip=0; 
IF eadepl="" then eadepl=5; 
IF eairre="" then eairre=5; 
IF eaexi="" then eaexi=5; 
IF eabrui="" then eabrui=5; 
IF eaenv="" then eaenv=5; 
IF ealati="" then ealati=5; 
IF eapeur="" then eapeur=5;
IF eafam="" then eafam=6;
IF eacol="" then eacol=6;
run; 

/*data SIP; 
set SIP; 
duree_handi=duree_handi+1;
if duree_handi="" then duree_handi=0; 
run; */ 


/*On enlève les NA de zremen*/ 
data SIP; 
set SIP; 
if zremen="" then zremen=-2; 
run; 

/*****ETAPE 2: Quelques statistiques descriptives *******/ 

/*Les statistiques descriptives des variables catégorielle*/ 
proc freq data=SIP; 
TABLES Sexenq fnivdip fsitua sq3g
eadepl eairre eaexi eabrui eaenv ealati
eapeur eafam eacol activite_stimu
duree_chomage fnelev zspo_1 maladies_chroniques; 
run; 

proc freq data=SIP; 
TABLES duree_handi;
run;

/*Les statistiques descriptives des variables numériques*/ 
proc univariate data=SIP; 
VAR zremen agenq duree_handi; 
HISTOGRAM; 
run;


/*********************************************************/ 
/*****ETAPE 3: Modélisation de la durée du handicape *****/ 
/*********************************************************/ 


/***REMARQUE: ***/ 
	/*PB DE CENSURE:certain individus n'ont pas encore subit l'événement et pourtant ils sont présents dans l'I*/ 
	/*PB d'hétérogénéité: il y a des facteurs externes qui influencent la durée du hadicape*/ 

	/*Modélisation en prenant en compte le problème d'hétérogénéité, troncature et hétérogénéité inobservée*/ 
data SIP; 
Set SIP; 
if duree_handi=9999 then HANDI=0;
ELSE HANDI=1; 
run; 
	

	/*Changement en numérique*/
data NUM; 
set SIP;
eabrui_n=input(eabrui,8.);
eacol_n=input(eacol,8.); 
eadepl_n=input(eadepl,8.);  
eaenv_n=input(eaenv,8.);  
eaexi_n=input(eaexi,8.); 
eafam_n=input(eafam,8.); 
ealati_n=input(ealati,8.); 
eairre_n=input(eairre,8.);  
eapeur_n=input(eapeur,8.); 
fnivdip_n=input(fnivdip,8.); 
fsitua_n=input(fsitua,8.); 
sexenq_n=input(sexenq,8.); 
sq3g_n=input(sq3g,8.); 
run; 

proc corr data=NUM; 
VAR eabrui_n eacol_n eadepl_n eaenv_n eaexi_n eafam_n
ealati_n eairre_n eapeur_n; 
run; 

/*proc contents data=NUM; run; */

/*Modèle à hazard proportionnel avec phreg slide 55 modèle de COX en mettant la shared fraility*/ 

PROC PHREG DATA=NUM;
CLASS ident_ind;
MODEL duree_handi*HANDI(0)=eabrui_n eacol_n eadepl_n 
eaenv_n eaexi_n eafam_n ealati_n eairre_n eapeur_n fnivdip_n fsitua_n sexenq_n sq3g_n agenq fnelev zremen zspo_1 activite_stimu maladies_chroniques duree_chomage; 
RANDOM ident_ind/DIST=GAMMA;
HAZARDRATIO eabrui_n/CL=WALD;
HAZARDRATIO eacol_n/CL=WALD;
HAZARDRATIO eadepl_n/CL=WALD;
HAZARDRATIO eaenv_n/CL=WALD;
HAZARDRATIO eaexi_n/CL=WALD;
HAZARDRATIO eafam_n/CL=WALD;
HAZARDRATIO ealati_n/CL=WALD;
HAZARDRATIO eairre_n/CL=WALD;
HAZARDRATIO eapeur_n/CL=WALD;
HAZARDRATIO fnivdip_n/CL=WALD;
HAZARDRATIO fsitua_n/CL=WALD;
HAZARDRATIO sexenq_n/CL=WALD;
HAZARDRATIO sq3g_n/CL=WALD;
HAZARDRATIO agenq/CL=WALD;
HAZARDRATIO duree_chomage/CL=WALD;
HAZARDRATIO fnelev/CL=WALD;
HAZARDRATIO zremen/CL=WALD;
HAZARDRATIO zspo_1/CL=WALD;
HAZARDRATIO activite_stimu/CL=WALD;
HAZARDRATIO maladies_chroniques/CL=WALD;
RUN;
QUIT;




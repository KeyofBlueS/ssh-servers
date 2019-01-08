#!/bin/bash

# Version:    2.1.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-servers
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

#echo -n "Checking dependencies... "
for name in fping fusermount nmap ssh sshfs wakeonlan
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

for name in beep sox
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è consigliato da questo script per poter utilizzare le segnalazioni acustiche. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nSe preferisci, installa le dipendenze consigliate e riavvia questo script\n";}

#KEYFILE=/PATH/TO/KEYFILE
#SSHPORT=22
#SOCKSPORT=1080
#SERVERUSERNAME=user
#SERVERHOSTNAME=HOST
#REMOTEMOUNTPOINT=/
#SERVERMAC=
#SERVERIP_LAN=0.0.0.0
#LAN_COUNTDOWN=3
#CURRENTIP_LINK=
#CURRENTIP_PATH=
#CURRENTIP_FILE=
#SERVERIP_INTERNET=0.0.0.0
#INTERNET_COUNTDOWN=10
#TYPE=LOCALE|REMOTO
#SERVERIP=$SERVERIP_LAN
#AUDIO=BEEP

if [[ -e "$CURRENTIP_PATH/$CURRENTIP_FILE" ]]; then
CURRENTIP="$CURRENTIP_PATH/$CURRENTIP_FILE"
else
CURRENTIP="/dev/null"
fi

LOCALUSER=$USER
LOCALMOUNTPOINT="/media/"$LOCALUSER"/"$SERVERHOSTNAME"_SSHFS"

READTIME="-t 1 -n 1"

rm -f /tmp/$CURRENTIP_FILE.tmp

if echo $SSHPORT | grep -Eoq '([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])'; then
	echo -n
else
	SSHPORT=22
fi

if echo $SOCKSPORT | grep -Eoq '([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])'; then
	echo -n
else
	SOCKSPORT=1080
fi

if echo $REMOTEMOUNTPOINT | grep -Eq '^(/[^/ ]*)+/?$'; then
	echo -n
else
	REMOTEMOUNTPOINT=/
fi

if echo "$LAN_COUNTDOWN" | grep -Eq '^([0-9]|10|ask|exit)$'; then
	echo -n
else
	LAN_COUNTDOWN=5
fi
LANCOUNTSTEP=serverip_error_countdown_$LAN_COUNTDOWN

if echo "$INTERNET_COUNTDOWN" | grep -Eq '^([0-9]|10|ask|exit)$'; then
	echo -n
else
	INTERNET_COUNTDOWN=10
fi
INTERNETCOUNTSTEP=serverip_error_countdown_$INTERNET_COUNTDOWN

if echo $SERVERIP | grep -Eq '^(LAN|lan)$'; then
	SERVERIP=$SERVERIP_LAN
elif echo $SERVERIP | grep -Eq '^(INTERNET|internet)$'; then
	SERVERIP=$SERVERIP_INTERNET
fi

if echo $AUDIO | grep -Eq '^(BEEP|beep)$'; then
	BELL1=( "beep" )
	BELL2=( "beep -f 1000 -n -f 2000 -n -f 1500" )
	BELL3=( "beep -f 2000" )
elif echo $AUDIO | grep -Eq '^(SOX|sox)$'; then
	BELL1=( "play -q -n synth 0.2 square 1000 gain $GAIN fade h 0.01" )
	BELL2=( "play -q -n synth 0.2 square 1000 gain $GAIN : synth 0.2 square 2000 gain $GAIN fade h 0.01 : synth 0.2 square 1500 gain $GAIN fade h 0.01" )
	BELL3=( "play -q -n synth 0.2 square 2000 gain $GAIN fade h 0.01" )
elif echo $AUDIO | grep -Eq '^(NULL|null)$'; then
	BELL0="echo BEEP"
	BELL1="echo BEEP"
	BELL2="echo BEEP"
else
	BELL0="echo BEEP"
	BELL1="echo BEEP"
	BELL2="echo BEEP"
fi

if echo "$GAIN" | grep -Eq '^[+]?[0-9]+$'; then
	echo -n
elif echo "$GAIN" | grep -Eq '^-[0-9]+$'; then
	echo -n
else
	GAIN=-25
fi

serverip_default(){
if echo "$SERVERIP" | grep -x "$SERVERIP_LAN" | grep -Eoq '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'; then
	serverip_lan
elif echo "$SERVERIP" | grep -x "$SERVERIP_INTERNET" | grep -Eoq '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'; then
	serverip_internet
else
	echo -e "\e[1;31mIndirizzo IP non corretto!
	\e[0m"
	givemehelp
fi
}

menu0(){
$BELL2
echo -e "\e[1;34m
## $SERVERUSERNAME@$SERVERHOSTNAME IP="$SERVERIP" Port=$SSHPORT\e[0m"
echo -e "\e[1;31m
Che tipo di collegamento vuoi effettuare?
(L)ocale
(R)emoto
(E)sci dal programma
\e[0m"
read -p "Scelta (L/R/E): " testo

case $testo in
    L|l)
	{
	echo -e "\e[1;34m
## HAI SCELTO LOCALE\e[0m"
	serverip_lan
	}
    ;;
    R|r)
	{
	echo -e "\e[1;34m
## HAI SCELTO REMOTO\e[0m"
	serverip_internet
	}
    ;;
    E|e)
	{
	echo -e "\e[1;34mEsco dal programma\e[0m"
	exit 0
	}
    ;;
    *)
	echo -e "\e[1;31m## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m"
	menu0
    ;;
esac
}

serverip_manual(){
$BELL1
echo -e "\e[1;34m
## $SERVERUSERNAME@$SERVERHOSTNAME\e[0m"
echo -e "\e[1;31mInserisci manualmente l'indirizzo IP del server\e[0m"
unset ip; \
while ! [ "$ip" ];do
    printf "IP: %s\r" $ip;
    read -p IP:\  var;
    iparray=($( IFS=".";echo $var;));
    [ ${#iparray[@]} -eq 4 ] && \
        [ $iparray -ge 0 ] && [ $iparray -le 255 ] && \
        [ ${iparray[1]} -ge 0 ] && [ ${iparray[1]} -le 255 ] && \
        [ ${iparray[2]} -ge 0 ] && [ ${iparray[2]} -le 255 ] && \
        [ ${iparray[3]} -ge 0 ] && [ ${iparray[3]} -le 255 ] && \
        ip=$var;
    [ "$ip" ] || echo Formato indirizzo IP non corretto, riprova...;
  done; \
SERVERIP="$ip"
SERVERIP_LAN="$SERVERIP"
SERVERIP_INTERNET="$SERVERIP"
SERVERIP_STEP=serverip_manual
menu0
}

serverip_lan(){
TYPE=LOCALE
SERVERIP_START_STEP=serverip_lan
COUNTDOWN=$LAN_COUNTDOWN
RESET_COUNTDOWNSTEP=$LANCOUNTSTEP
if [[ -e "$CURRENTIP_PATH/$CURRENTIP_FILE" ]]; then
SERVERIP_STEP=serverip_lan_1
else
SERVERIP_STEP=$LANCOUNTSTEP
fi
serverip_lan_static
}
serverip_lan_static(){
echo "Indirizzo IP locale statico o più affidabile..."
SERVERIP="$SERVERIP_LAN"
PING="$(fping -r0 $SERVERIP_LAN | grep "alive")"
#SERVERIP_STEP=serverip_lan_1
ping_serverip
}
serverip_lan_1(){
echo "Indirizzo IP locale memorizzato 1..."
SERVERIP="$(cat "$CURRENTIP" | grep SERVERIP_LAN_1 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
PING="$(fping -r0 "$SERVERIP" | grep "alive")"
SERVERIP_STEP=$LANCOUNTSTEP
ping_serverip
}

serverip_internet(){
TYPE=REMOTO
SERVERIP_START_STEP=serverip_internet
COUNTDOWN=$INTERNET_COUNTDOWN
RESET_COUNTDOWNSTEP=$INTERNETCOUNTSTEP
if [[ -e "$CURRENTIP_PATH/$CURRENTIP_FILE" ]]; then
SERVERIP_STEP=serverip_internet_1
else
SERVERIP_STEP=$INTERNETCOUNTSTEP
fi
serverip_internet_static
}
serverip_internet_static(){
echo "Indirizzo IP pubblico statico o più affidabile..."
SERVERIP=$SERVERIP_INTERNET
PING="$(nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open")"
ping_serverip
}
serverip_internet_1(){
echo "Indirizzo IP pubblico memorizzato 1..."
SERVERIP="$(cat "$CURRENTIP" | grep SERVERIP_INTERNET_1 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
PING="$(nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open")"
SERVERIP_STEP=serverip_internet_2
ping_serverip
}
serverip_internet_2(){
echo "Indirizzo IP pubblico memorizzato 2..."
SERVERIP="$(cat "$CURRENTIP" | grep SERVERIP_INTERNET_2 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
PING="$(nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open")"
SERVERIP_STEP=serverip_internet_3
ping_serverip
}
serverip_internet_3(){
echo "Indirizzo IP pubblico memorizzato 3..."
SERVERIP="$(cat "$CURRENTIP" | grep SERVERIP_INTERNET_3 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
PING="$(nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open")"
SERVERIP_STEP=serverip_internet_4
ping_serverip
}
serverip_internet_4(){
echo "Indirizzo IP pubblico memorizzato 4..."
SERVERIP="$(cat "$CURRENTIP" | grep SERVERIP_INTERNET_4 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
PING="$(nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open")"
SERVERIP_STEP=$INTERNETCOUNTSTEP
ping_serverip
}

serverip_error_countdown_10(){
COUNTDOWN=10
COUNTDOWNSTEP=serverip_error_countdown_9
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_9(){
COUNTDOWN=9
COUNTDOWNSTEP=serverip_error_countdown_8
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_8(){
COUNTDOWN=8
COUNTDOWNSTEP=serverip_error_countdown_7
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_7(){
COUNTDOWN=7
COUNTDOWNSTEP=serverip_error_countdown_6
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_6(){
COUNTDOWN=6
COUNTDOWNSTEP=serverip_error_countdown_5
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_5(){
COUNTDOWN=5
COUNTDOWNSTEP=serverip_error_countdown_4
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_4(){
COUNTDOWN=4
COUNTDOWNSTEP=serverip_error_countdown_3
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_3(){
COUNTDOWN=3
COUNTDOWNSTEP=serverip_error_countdown_2
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_2(){
COUNTDOWN=2
COUNTDOWNSTEP=serverip_error_countdown_1
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_1(){
COUNTDOWN=1
COUNTDOWNSTEP=serverip_error_countdown_0
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_0(){
COUNTDOWN=0
COUNTDOWNSTEP=serverip_error_countdown_end
READTIMETEXT="o attendi $COUNTDOWN secondi "
serverip_error
}
serverip_error_countdown_end(){
echo "Tempo scaduto"
echo -e "\e[1;34m
	Riprovo...
\e[0m"
$SERVERIP_START_STEP
}
serverip_error_countdown_ask(){
READTIME="-n 2"
serverip_error
}
serverip_error_countdown_exit(){
echo -e "\e[1;34m
$SERVERUSERNAME@$SERVERHOSTNAME @ $SERVERIP ($TYPE) non raggiungibile,
è\e[0m" "\e[1;31mOFFLINE o rete non disponibile\e[0m"
echo -e "\e[1;34mEsco dal programma\e[0m"
exit 0
}

serverip_error(){
clear
echo -e "\e[1;34m
$SERVERUSERNAME@$SERVERHOSTNAME @ $SERVERIP ($TYPE) non raggiungibile,
è\e[0m" "\e[1;31mOFFLINE o rete non disponibile\e[0m"
#	echo -e "\e[1;31mProvo a risvegliare il device...\e[0m"
#	wakeonlan -i "$SERVERIP" $SERVERMAC
echo -e "\e[1;31mPremi:
A per provare ad (a)ggiornare gli indirizzi IP
M per inserire (m)anualmente l'indirizzo IP del server
O per provare a collegarsi c(o)munque al server
R "$READTIMETEXT"per (r)iprovare
E per uscire\e[0m"
read $READTIME -p "Scelta (A/M/O/R/E): " testo
case $testo in
    A|a)
	{
	serverip_update
	}
    ;;
    M|m)
	{
	serverip_manual
	}
    ;;
    O|o)
	{
	menu
	}
    ;;
    R|r)
	{
	echo -e "\e[1;34m
	Riprovo...
	\e[0m"
	$SERVERIP_START_STEP
	}
    ;;
    E|e)
	{
	rm -f /tmp/$CURRENTIP_FILE.tmp
	echo -e "\e[1;34mEsco dal programma\e[0m"
	exit 0
	}
    ;;
    "")
	{
	$COUNTDOWNSTEP	
	}
    ;;
    *)
	echo -e "\e[1;31m ## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m" && sleep 2
	$RESET_COUNTDOWNSTEP
    ;;
esac
}

serverip_update(){
echo -e "\e[1;34m
Provo ad aggiornare gli indirizzi IP...\e[0m"
rm -f /tmp/$CURRENTIP_FILE.tmp
wget -q $CURRENTIP_LINK -O /tmp/$CURRENTIP_FILE.tmp
cat "/tmp/$CURRENTIP_FILE.tmp" | grep -q "export SERVER"
if [ $? = 0 ]; then
	diff -q "$CURRENTIP" "/tmp/$CURRENTIP_FILE.tmp"
	if [ $? = 0 ]; then
		echo -e "\e[1;34m ## Era già aggiornato!\e[0m"
		rm -f /tmp/$CURRENTIP_FILE.tmp
	else
		echo -e "\e[1;34m ## Fatto!\e[0m"
		mv /tmp/$CURRENTIP_FILE.tmp $CURRENTIP
	fi
else
	echo -e "\e[1;31m ## FORMATO FILE NON CORRETTO o NON RAGGIUNGIBILE!\e[0m" && sleep 5
fi
$SERVERIP_START_STEP
}

ping_serverip(){
echo -e "\e[1;34m
## PING $SERVERUSERNAME@$SERVERHOSTNAME  IP=$SERVERIP Port=$SSHPORT
\e[0m"
$BELL1
if echo $PING | grep -q "alive"; then
	SERVERIP="$(fping -q -r0 -a $SERVERIP)"
	echo -n
elif echo $PING | grep -q "$SSHPORT/tcp open"; then
	echo -n
else
	$SERVERIP_STEP
fi
echo -e "\e[1;34m$SERVERUSERNAME@$SERVERHOSTNAME @ $SERVERIP ($TYPE) è\e[0m" "\e[1;32mONLINE\e[0m"
menu
}

menu(){
PING=""
$BELL2
echo -e "\e[1;31m
Che tipo di collegamento vuoi effettuare?
(S)ocks - Crea un socks server per condividere
	  la connessione del server sul client
(M)onta localmente il server tramite SSHFS
(G)UI - Con supporto alla GUI sul Client
(C)LI - Con il solo supporto alla CLI
(E)sci dal programma
\e[0m"
read -p "Scelta (S/M/G/C/E): " testo

case $testo in
    S|s)
	{
	clear
	echo $SOCKSPORT | grep -Eoq '([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])'
	if [ $? = 0 ]; then
		echo -n
	else
		echo -e "\e[1;31mPorta SOCKS non corretta, imposto quella di default (1080)\e[0m"
		SOCKSPORT=1080
	fi
	echo -e "\e[1;34m
	## SSH $SERVERUSERNAME@$SERVERHOSTNAME SOCKS
	\e[0m"
	$BELL3
	ssh -i "$KEYFILE" -ND $SOCKSPORT -p $SSHPORT $SERVERUSERNAME@$SERVERIP
	$SERVERIP_START_STEP
	}
    ;;
    M|m)
	{
	clear
	echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERHOSTNAME SSHFS
\e[0m"
	$BELL3
	fusermount -u "$LOCALMOUNTPOINT"
	sudo mkdir "$LOCALMOUNTPOINT"
	sudo chown $LOCALUSER "$LOCALMOUNTPOINT"
	sshfs -d -o IdentityFile="$KEYFILE" -o allow_other -o reconnect -o ServerAliveInterval=15 $SERVERUSERNAME@$SERVERIP:"$REMOTEMOUNTPOINT" "$LOCALMOUNTPOINT" -p $SSHPORT -C
	fusermount -u "$LOCALMOUNTPOINT"
	$SERVERIP_START_STEP
	}
    ;;
    G|g)
	{
	clear
	echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERHOSTNAME GUI
\e[0m"
	$BELL3
	ssh -i "$KEYFILE" -X -p $SSHPORT $SERVERUSERNAME@$SERVERIP
	$SERVERIP_START_STEP
	}
    ;;
    C|c)
	{
	clear
	echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERHOSTNAME CLI
\e[0m"
	$BELL3
	ssh -i "$KEYFILE" -p $SSHPORT $SERVERUSERNAME@$SERVERIP
	$SERVERIP_START_STEP
	}
    ;;
    E|e)
	{
	echo -e "\e[1;34mEsco dal programma\e[0m"
	exit 0
	}
    ;;
    *)
	clear
	echo -e "\e[1;31m## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m"
	menu
    ;;
esac
}

###############################################################################################################################################

create_configuration_file(){
CHECK="no"
echo -e '\e[1;34m### Creazione guidata file di configurazione per ssh-servers

Per una spiegazione più dettagliata vedi https://github.com/KeyofBlueS/ssh-servers/blob/master/Esempio-configurazione-ssh-server.sh\e[0m'
configuration_currentip_link
}

configuration_currentip_link(){
echo -e "\e[1;34m
### Inserisci l'URL del file contenente le informazioni del server remoto e premi invio
(vedi https://github.com/KeyofBlueS/current-ip)
Se il file non è disponibile o nel dubbio, lascia il campo vuoto e premi invio\e[0m"
read currentip_link_userinput
echo -e "\e[1;34m-> \e[1;32m$currentip_link_userinput\e[0m"
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_currentip_path
else
	configuration_configuration_file_check
fi
}

configuration_currentip_path(){
echo -e "\e[1;34m
### Inserisci il percorso locale in cui è presente il file contenente le informazioni del server remoto e premi invio
(vedi https://github.com/KeyofBlueS/current-ip)
Se il file non è disponibile o nel dubbio, lascia il campo vuoto, premi invio e continua comunque\e[0m"
read currentip_path_userinput
echo -e "\e[1;34m-> \e[1;32m$currentip_path_userinput\e[0m"
if echo $currentip_path_userinput | grep -Eq '^".*"$'; then
	eval currentip_path_userinput=$currentip_path_userinput
else
	eval currentip_path_userinput='"'$currentip_path_userinput'"'
fi
test -d "$currentip_path_userinput"
if [ $? = 0 ]; then
	echo ok
else
#	ERRORTEXT="Il percorso "$currentip_path_userinput" non esiste! Vuoi crearlo?"
	ERRORTEXT="Il percorso "$currentip_path_userinput" non esiste! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_currentip_path
#	YESCOMMAND=( "mkdir -p "$currentip_path_userinput"" )
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_currentip_file
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_currentip_file
else
	configuration_configuration_file_check
fi
}

configuration_currentip_file(){
echo -e "\e[1;34m
### Inserisci il nome del file contenente le informazioni del server remoto e premi invio
(vedi https://github.com/KeyofBlueS/current-ip)
Se il file non è disponibile o nel dubbio, lascia il campo vuoto e premi invio\e[0m"
read currentip_file_userinput
echo -e "\e[1;34m-> \e[1;32m$currentip_file_userinput\e[0m"
if echo $currentip_file_userinput | grep -Eq '^".*"$'; then
	eval currentip_file_userinput=$currentip_file_userinput
else
	eval currentip_file_userinput='"'$currentip_file_userinput'"'
fi
test -e "$currentip_path_userinput/$currentip_file_userinput"
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="Nel percorso "$currentip_path_userinput" il file "$currentip_file_userinput" non esiste! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_currentip_file
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_keyfile
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_keyfile
else
	configuration_configuration_file_check
fi
}

configuration_keyfile(){
echo -e "\e[1;34m
### Inserisci il percorso del file chiave, richiesto per il collegamento tramite key authtentication, e premi invio
Se il file non è disponibile o nel dubbio, lascia il campo vuoto, premi invio e continua comunque\e[0m"
read keyfile_userinput
echo -e "\e[1;34m-> \e[1;32m$keyfile_userinput\e[0m"
if echo $keyfile_userinput | grep -Eq '^".*"$'; then
	eval keyfile_userinput=$keyfile_userinput
else
	eval keyfile_userinput='"'$keyfile_userinput'"'
fi
test -e "$keyfile_userinput"
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="Il file "$keyfile_userinput" non esiste! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_keyfile
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_sshport
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_sshport
else
	configuration_configuration_file_check
fi
}

configuration_sshport(){
echo -e "\e[1;34m
### Inserisci la porta in ascolto del server ssh e premi invio
Nel dubbio, inserisci la porta di default (22) e premi invio\e[0m"
read sshport_userinput
echo -e "\e[1;34m-> \e[1;32m$sshport_userinput\e[0m"
echo "$sshport_userinput" | grep -Eoq '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="La porta ssh "$sshport_userinput" non è valida! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_sshport
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_socksport
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_socksport
else
	configuration_configuration_file_check
fi
}

configuration_socksport(){
echo -e "\e[1;34m
### Inserisci la porta in cui avviare un Server SOCKS per condividere la connessione del server sul client e premi invio
Nel dubbio, inserisci la porta di default (1080) e premi invio\e[0m"
read socksport_userinput
echo -e "\e[1;34m-> \e[1;32m$socksport_userinput\e[0m"
echo "$socksport_userinput" | grep -Eoq '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="La porta SOCKS "$socksport_userinput" non è valida! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_socksport
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_serverusername
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_serverusername
else
	configuration_configuration_file_check
fi
}

configuration_serverusername(){
echo -e "\e[1;34m
### Inserisci il nome dell'utente presente sul server su cui ci si vuole loggare (non inserire "root") e premi invio\e[0m"
read serverusername_userinput
echo -e "\e[1;34m-> \e[1;32m$serverusername_userinput\e[0m"
echo "$serverusername_userinput" | grep -Eq '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="Il formato del nome utente "$serverusername_userinput" non è valido! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_serverusername
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_serverhostname
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_serverhostname
else
	configuration_configuration_file_check
fi
}
 ##################################
configuration_serverhostname(){
echo -e "\e[1;34m
### Inserisci il nome dell'host del server su cui ci si vuole loggare e premi invio
Meramente informativo per una più facile identificazione del server, ma necessario per il montaggio tramite SSHFS\e[0m"
read serverhostname_userinput
echo -e "\e[1;34m-> \e[1;32m$serverhostname_userinput\e[0m"
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_remotemountpoint
else
	configuration_configuration_file_check
fi
}

configuration_remotemountpoint(){
echo -e "\e[1;34m
### Inserisci il punto di mount del server, la cartella radice da cui verrà montato localmente il server tramite SSHFS e premi invio
Nel dubbio, inserisci il percorso root (/) e premi invio\e[0m"
read remotemountpoint_userinput
echo -e "\e[1;34m-> \e[1;32m$remotemountpoint_userinput\e[0m"
if echo $remotemountpoint_userinput | grep -Eq '^".*"$'; then
	eval remotemountpoint_userinput=$remotemountpoint_userinput
else
	eval remotemountpoint_userinput='"'$remotemountpoint_userinput'"'
fi
echo $remotemountpoint_userinput | grep -Eq '^(/[^/ ]*)+/?$'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT=""$remotemountpoint_userinput" non è un percorso valido! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_remotemountpoint
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_servermac
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_servermac
else
	configuration_configuration_file_check
fi
}
 ##################################
configuration_servermac(){
echo -e "\e[1;34m
### Inserisci l'indirizzo MAC del server, richiesto per provare a risvegliare il server tramite Wake On LAN e premi invio
Nel dubbio, lascia il campo vuoto, premi invio e continua comunque\e[0m"
read servermac_userinput
echo -e "\e[1;34m-> \e[1;32m$servermac_userinput\e[0m"
if echo $servermac_userinput | grep -Eq '^".*"$'; then
	eval servermac_userinput=$servermac_userinput
else
	eval servermac_userinput='"'$servermac_userinput'"'
fi
echo "$servermac_userinput" | grep -Eoq '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="L'indirizzo MAC "$servermac_userinput" non è valido! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_servermac
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_serverip_lan
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_serverip_lan
else
	configuration_configuration_file_check
fi
}

configuration_serverip_lan(){
echo -e "\e[1;34m
### Inserisci l'indirizzo ip del server per la connessione ssh in rete locale e premi invio\e[0m"
read serverip_lan_userinput
echo -e "\e[1;34m-> \e[1;32m$serverip_lan_userinput\e[0m"
if echo $serverip_lan_userinput | grep -Eq '^".*"$'; then
	eval serverip_lan_userinput=$serverip_lan_userinput
else
	eval serverip_lan_userinput='"'$serverip_lan_userinput'"'
fi
echo "$serverip_lan_userinput" | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="L'indirizzo IP "$serverip_lan_userinput" non è valido! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_serverip_lan
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_lan_countdown
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_lan_countdown
else
	configuration_configuration_file_check
fi
}

configuration_lan_countdown(){
echo -e "\e[1;34m
### Secondi di attesa prima di provare a ricontattare il server nella rete locale nel caso questo fosse irraggiungibile, inserisci:
un valore da 0 a 10	- durante il countdown viene comunque chiesto all'utente come proseguire
ask	- per non riprovare automaticamente, viene chiesto all'utente come proseguire
exit	- per non riprovare automaticamente ed uscire dallo script
e premi invio\e[0m"
read lan_countdown_userinput
echo -e "\e[1;34m-> \e[1;32m$lan_countdown_userinput\e[0m"
echo "$lan_countdown_userinput" | grep -Eq '^([0-9]|10|ask|exit)$'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="L'impostazione inserita ("$lan_countdown_userinput") non è valida! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_lan_countdown
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_serverip_internet
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_serverip_internet
else
	configuration_configuration_file_check
fi
}

configuration_serverip_internet(){
echo -e "\e[1;34m
### Inserisci l'indirizzo ip del server per la connessione ssh in remoto e premi invio\e[0m"
read serverip_internet_userinput
echo -e "\e[1;34m-> \e[1;32m$serverip_internet_userinput\e[0m"
if echo $serverip_internet_userinput | grep -Eq '^".*"$'; then
	eval serverip_internet_userinput=$serverip_internet_userinput
else
	eval serverip_internet_userinput='"'$serverip_internet_userinput'"'
fi
echo "$serverip_internet_userinput" | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="L'indirizzo IP "$serverip_internet_userinput" non è valido! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_serverip_internet
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_internet_countdown
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_internet_countdown
else
	configuration_configuration_file_check
fi
}

configuration_internet_countdown(){
echo -e "\e[1;34m
### Secondi di attesa prima di provare a ricontattare il server su internet nel caso questo fosse irraggiungibile, inserisci:
un valore da 0 a 10	- durante il countdown viene comunque chiesto all'utente come proseguire
ask	- per non riprovare automaticamente, viene chiesto all'utente come proseguire
exit	- per non riprovare automaticamente ed uscire dallo script
e premi invio\e[0m"
read internet_countdown_userinput
echo -e "\e[1;34m-> \e[1;32m$internet_countdown_userinput\e[0m"
echo "$internet_countdown_userinput" | grep -Eq '^([0-9]|10|ask|exit)$'
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="L'impostazione inserita ("$internet_countdown_userinput") non è valida! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_internet_countdown
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_serverip
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_serverip
else
	configuration_configuration_file_check
fi
}

configuration_serverip(){
echo -e "\e[1;34m
### Imposta il tipo di collegamento preferito, inserisci:
LAN	- se il server si trova all'interno della rete locale
INTERNET	- se il server si trova su internet
e premi invio\e[0m"
read serverip_userinput
echo -e "\e[1;34m-> \e[1;32m$serverip_userinput\e[0m"
echo "$serverip_userinput" | grep -Eq '^(LAN|INTERNET)$'
if [ $? = 0 ]; then
	echo ok
elif echo "$serverip_userinput" | grep -xq 'lan'; then
	serverip_userinput=LAN
elif echo "$serverip_userinput" | grep -xq 'internet'; then
	serverip_userinput=INTERNET
else
	ERRORTEXT="L'impostazione inserita ("$serverip_userinput") non è corretta! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_serverip
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_audio
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_audio
else
	configuration_configuration_file_check
fi
}

configuration_audio(){
echo -e "\e[1;34m
### Imposta il tipo di segnale acustico da utilizzare, inserisci:
BEEP	- per impostare il segnale acustico tramite lo speaker interno (richiede beep)
SOX	- per impostare il segnale acustico tramite la scheda audio (richiede sox)
NULL	- per disattivare il segnale acustico
e premi invio\e[0m"
read audio_userinput
echo -e "\e[1;34m-> \e[1;32m$audio_userinput\e[0m"
echo "$audio_userinput" | grep -Eq '^(BEEP|SOX|NULL)$'
if [ $? = 0 ]; then
	echo ok
elif echo "$audio_userinput" | grep -xq 'beep'; then
	audio_userinput=BEEP
elif echo "$audio_userinput" | grep -xq 'sox'; then
	audio_userinput=SOX
elif echo "$audio_userinput" | grep -xq 'null'; then
	audio_userinput=NULL
else
	ERRORTEXT="L'impostazione inserita ("$audio_userinput") non è corretta! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_audio
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_gain
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_gain
else
	configuration_configuration_file_check
fi
}
 ##################################
configuration_gain(){
echo -e "\e[1;34m
### Regola il volume delle segnalazioni acustiche per SOX e premi invio
Inserisci qualsiasi valore negativo o positivo es -20, 0, 10, +20\e[0m"
read gain_userinput
echo -e "\e[1;34m-> \e[1;32m$gain_userinput\e[0m"
if echo "$gain_userinput" | grep -Eq '^[+]?[0-9]+$'; then
	echo ok
elif echo "$gain_userinput" | grep -Eq '^-[0-9]+$'; then
	echo ok
else
	ERRORTEXT="L'impostazione inserita ("$gain_userinput") non è corretta! Vuoi continuare comunque?"
	CONFIGURATION_CURRENT_STEP=configuration_gain
	YESCOMMAND=( "" )
	echo $CHECK | grep -xq "yes"
	if [ $? != 0 ]; then
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	else
		CONFIGURATION_NEXT_STEP=configuration_configuration_file_check
	fi
	userimput_error
fi
echo $CHECK | grep -xq "yes"
if [ $? != 0 ]; then
	configuration_configuration_file_check
else
	configuration_configuration_file_check
fi
}

configuration_configuration_file_check(){
CHECK="yes"
while true
do

if echo $currentip_path_userinput | grep -q " "; then
	if echo $currentip_path_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		currentip_path_userinput='"'$currentip_path_userinput'"'
	fi
else
	echo -n
fi

if echo $currentip_file_userinput | grep -q " "; then
	if echo $currentip_file_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		currentip_file_userinput='"'$currentip_file_userinput'"'
	fi
else
	echo -n
fi

if echo $keyfile_userinput | grep -q " "; then
	if echo $keyfile_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		keyfile_userinput='"'$keyfile_userinput'"'
	fi
else
	echo -n
fi

if echo $remotemountpoint_userinput | grep -q " "; then
	if echo $remotemountpoint_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		remotemountpoint_userinput='"'$remotemountpoint_userinput'"'
	fi
else
	echo -n
fi

if echo $servermac_userinput | grep -q " "; then
	if echo $servermac_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		servermac_userinput='"'$servermac_userinput'"'
	fi
else
	echo -n
fi

if echo $serverip_lan_userinput | grep -q " "; then
	if echo $serverip_lan_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		serverip_lan_userinput='"'$serverip_lan_userinput'"'
	fi
else
	echo -n
fi

if echo $serverip_internet_userinput | grep -q " "; then
	if echo $serverip_internet_userinput | grep -Eq '^".*"$'; then
		echo -n
	else
		serverip_internet_userinput='"'$serverip_internet_userinput'"'
	fi
else
	echo -n
fi

echo -e "\e[1;31m
### Configurazione terminata.
Vuoi modificare qualcosa o procedere con il salvataggio?\e[1;34m

Il contenuto del file di configurazione è:

(1)  - export CURRENTIP_LINK=$currentip_link_userinput
(2)  - export CURRENTIP_PATH=$currentip_path_userinput
(3)  - export CURRENTIP_FILE=$currentip_file_userinput
(4)  - export KEYFILE=$keyfile_userinput
(5)  - export SSHPORT=$sshport_userinput
(6)  - export SOCKSPORT=$socksport_userinput
(7)  - export SERVERUSERNAME=$serverusername_userinput
(8)  - export SERVERHOSTNAME=$serverhostname_userinput
(9)  - export REMOTEMOUNTPOINT=$remotemountpoint_userinput
(10) - export SERVEMAC=$servermac_userinput
(11) - export SERVERIP_LAN=$serverip_lan_userinput
(12) - export LAN_COUNTDOWN=$lan_countdown_userinput
(13) - export SERVERIP_INTERNET=$serverip_internet_userinput
(14) - export INTERNET_COUNTDOWN=$internet_countdown_userinput
(15) - export SERVERIP=$serverip_userinput
(16) - export AUDIO=$audio_userinput
(17) - export GAIN=$gain_userinput
(S)alva
(R)icomincia
(E)sci dal programma
\e[0m"
read -p "Scelta (1-17/S/R/E): " testo

case $testo in
    1)
	{
	configuration_currentip_link
	}
    ;;
    2)
	{
	configuration_currentip_path
	}
    ;;
    3)
	{
	configuration_currentip_file
	}
    ;;
    4)
	{
	configuration_keyfile
	}
    ;;
    5)
	{
	configuration_sshport
	}
    ;;
    6)
	{
	configuration_socksport
	}
    ;;
    7)
	{
	configuration_serverusername
	}
    ;;
    8)
	{
	configuration_serverhostname
	}
    ;;
    9)
	{
	configuration_remotemountpoint
	}
    ;;
    10)
	{
	configuration_servermac
	}
    ;;
    11)
	{
	configuration_serverip_lan
	}
    ;;
    12)
	{
	configuration_lan_countdown
	}
    ;;
    13)
	{
	configuration_serverip_internet
	}
    ;;
    14)
	{
	configuration_internet_countdown
	}
    ;;
    15)
	{
	configuration_serverip
	}
    ;;
    16)
	{
	configuration_audio
	}
    ;;
    17)
	{
	configuration_gain
	}
    ;;
    S|s)
	{
	echo -e "\e[1;34m
## CONTINUO...\e[0m"
	configuration_configuration_path
	}
    ;;
    R|r)
	{
	echo -e "\e[1;34m
## RICOMINCIA...\e[0m"
	create_configuration_file
	}
    ;;
    E|e)
	{
	echo -e "\e[1;34mEsco dal programma\e[0m"
	exit 0
	}
    ;;
    *)
	echo -e "\e[1;31m## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m"
    ;;
esac
done
}

configuration_configuration_path(){
CHECK="no"
echo -e "\e[1;34m
### Inserisci il percorso in cui verrà salvato questo file di configurazione e premi invio
es. $HOME/ssh-servers\e[0m"
read configuration_path_userinput
echo -e "\e[1;34m-> \e[1;32m$configuration_path_userinput\e[0m"
if echo $configuration_path_userinput | grep -Eq '^".*"$'; then
	eval configuration_path_userinput=$configuration_path_userinput
else
	eval configuration_path_userinput='"'$configuration_path_userinput'"'
fi
test -d "$configuration_path_userinput"
if [ $? = 0 ]; then
	echo ok
else
	ERRORTEXT="Il percorso "$configuration_path_userinput" non esiste. Vuoi crearlo?"
	CONFIGURATION_CURRENT_STEP=configuration_configuration_path
	CONFIGURATION_NEXT_STEP=configuration_configuration_file
	YESCOMMAND=( mk_configuration_path )
	userimput_error
fi
configuration_configuration_file
}

mk_configuration_path(){
mkdir -p "$configuration_path_userinput"
if [ $? = 0 ]; then
	echo ok
	configuration_configuration_file
else
	echo -e "\e[1;31m### Errore durante la creazione del percorso!\e[0m"
	configuration_configuration_path
fi
}

configuration_configuration_file(){
echo -e "\e[1;34m
### Inserisci il nome per questo file di configurazione e premi invio
es. "$serverusername_userinput"-"$serverhostname_userinput"\e[0m"
read configuration_file_userinput
echo -e "\e[1;34m-> \e[1;32m$configuration_file_userinput\e[0m"
if echo $configuration_path_userinput | grep -Eq '^".*"$'; then
	eval configuration_file_userinput=$configuration_file_userinput
else
	eval configuration_file_userinput='"'$configuration_file_userinput'"'
fi
test -e "$configuration_path_userinput/$configuration_file_userinput.sh"
if [ $? != 0 ]; then
	echo ok
else
	ERRORTEXT="Il file "$configuration_path_userinput/$configuration_file_userinput.sh" è già esistente! Vuoi sovrascriverlo?"
	CONFIGURATION_CURRENT_STEP=configuration_configuration_file
	CONFIGURATION_NEXT_STEP=configuration_configuration_file_save
	YESCOMMAND=( "" )
	userimput_error
fi
configuration_configuration_file_save
}

configuration_configuration_file_save(){
echo -e "\e[1;34m
### Salvataggio in corso...\e[0m"
touch "$configuration_path_userinput/$configuration_file_userinput.sh"

SSHSERVERS="$""@"
SAVEFILE=""$configuration_path_userinput"/"$configuration_file_userinput".sh"

cat <<EOT > $SAVEFILE
#!/bin/bash

export CURRENTIP_LINK=$currentip_link_userinput
export CURRENTIP_PATH=$currentip_path_userinput
export CURRENTIP_FILE=$currentip_file_userinput
export KEYFILE=$keyfile_userinput
export SSHPORT=$sshport_userinput
export SOCKSPORT=$socksport_userinput
export SERVERUSERNAME=$serverusername_userinput
export SERVERHOSTNAME=$serverhostname_userinput
export REMOTEMOUNTPOINT=$remotemountpoint_userinput
export SERVEMAC=$servermac_userinput
export SERVERIP_LAN=$serverip_lan_userinput
export LAN_COUNTDOWN=$lan_countdown_userinput
export SERVERIP_INTERNET=$serverip_internet_userinput
export INTERNET_COUNTDOWN=$internet_countdown_userinput
export SERVERIP=$serverip_userinput
export AUDIO=$audio_userinput
export GAIN=$gain_userinput

ssh-servers $SSHSERVERS
EOT

if [ $? = 0 ]; then
	echo ok
	chmod +x "$SAVEFILE"
else
	echo -e "\e[1;31m## ERRORE!\e[0m"
	configuration_configuration_path
fi

echo -e "\e[1;34m
### Il file di configurazione è stato correttamente salvato in "$SAVEFILE"

- Puoi modificarlo manualmente con en editor di testo, ad esempio nano, digitando:

\e[1;32m$ nano "$SAVEFILE"


\e[1;34m- Puoi avviarlo digitando:

\e[1;32m$ "$SAVEFILE"
\e[0m"

exit 0
}

userimput_error(){
while true
do
	echo -e "\e[1;31m$ERRORTEXT\e[0m"
echo -e "\e[1;31m(S)i
(R)iprova
(E)sci dal programma
\e[0m"
read -p "Scelta (S/R/E): " testo

case $testo in
    S|s)
	{
	echo -e "\e[1;34m
## CONTINUO...\e[0m"
	$YESCOMMAND
	$CONFIGURATION_NEXT_STEP
	}
    ;;
    R|r)
	{
	echo -e "\e[1;34m
## RIPROVA...\e[0m"
	$CONFIGURATION_CURRENT_STEP
	}
    ;;
    E|e)
	{
	echo -e "\e[1;34mEsco dal programma\e[0m"
	exit 0
	}
    ;;
    *)
	echo -e "\e[1;31m## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m"
    ;;
esac
done
}

givemehelp(){
echo "
# ssh-servers

# Version:    2.1.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-servers
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Lo script bash ssh-servers facilita la connessione ad uno o più server ssh remoti, automatizzando la connessione tramite
file di configurazione personalizzati e grazie a menu interattivi.

### CONFIGURAZIONE
Questo script non può essere utilizzato così com'è, ma deve essere necessariamente richiamato da un altro script/file di configurazione
che dovrà essere compilato in maniera precisa.
Per avviare la configurazione guidata, su un terminale digitare:
$ "'"ssh-servers --config"'"

L'esempio dello script/file di configurazione https://github.com/KeyofBlueS/ssh-servers/blob/master/Esempio-configurazione-ssh-server.sh
è commentato in modo esaustivo, basatevi su quello.
Una volta compilato e salvato lo script di configurazione, deve essere reso eseguibile, quindi se ad esempio il nostro script di
configurazione si chiama "'"mario-rossi-ssh-server.sh"'" e si trova nel percorso "'"$HOME/ssh-servers/"'", dovremo dare il comando:
$ chmod +x "'"$HOME/ssh-servers/mario-rossi-ssh-server.sh"'"
soltanto una volta per ogni script di configurazione creato.

### UTILIZZO
Una volta creati correttamente uno o più script di configurazione, basta avviarli su un terminale.
Ad esempio se vogliamo collegarci tramite lo script di configurazione "'"mario-rossi-ssh-server.sh"'", su un terminale digitare:
$ "'"$HOME/ssh-servers/mario-rossi-ssh-server.sh"'"

A questo punto seguire le istruzioni su schermo.

Una volta che il server è stato rilevato, è possibile avviare diversi tipi di connessione:
Socks - Crea un socks server per condividere
	      la connessione del server sul client
Monta localmente il server tramite SSHFS
GUI - Con supporto alla GUI sul Client
CLI - Con il solo supporto alla CLI

È possibile utilizzare le seguenti opzioni:
--local	      Avvia una connessione ssh verso un server in ascolto all'interno della rete LAN

--remote      Avvia una connessione ssh verso un server in ascolto su internet

--manual      Imposta manualmente l'indirizzo ip del server ssh

--default     Avvia la connessione di default definita nel file di configurazione per questo server

--config	Avvia la configurazione guidata

--help        Visualizza una descrizione ed opzioni di ssh-servers

### Nota
Se i server ssh posseggono un indirizzo ip pubblico dinamico, consiglio fortemente (i due script si integrano a vicenda) di
utilizzare [current-ip](https://github.com/KeyofBlueS/current-ip) sul lato server.
"
exit 0
}

general_error(){
 -e "\e[1;31m## ERRORE! Controlla il file di configurazione!\e[0m"
}

if [ "$1" = "--default" ]
then
   serverip_default
elif [ "$1" = "--local" ]
then
   serverip_lan
elif [ "$1" = "--remote" ]
then
   serverip_internet
elif [ "$1" = "--manual" ]
then
   serverip_manual
elif [ "$1" = "--help" ]
then
   givemehelp
elif [ "$1" = "" ]
then
   serverip_default
elif [ "$1" = "--config" ]
then
   create_configuration_file
else
   givemehelp
fi

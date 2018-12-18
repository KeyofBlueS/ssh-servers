#!/bin/bash

# Version:    2.0.0
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
#SERVERNAME=HOST
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

LOCALUSER=$USER
LOCALMOUNTPOINT="/media/"$LOCALUSER"/"$SERVERNAME"_SSHFS"

CURRENTIP=$CURRENTIP_PATH$CURRENTIP_FILE

LANCOUNTSTEP=serverip_error_countdown_$LAN_COUNTDOWN
INTERNETCOUNTSTEP=serverip_error_countdown_$INTERNET_COUNTDOWN

if [ -e /tmp/$CURRENTIP_FILE.tmp ]
then
    rm /tmp/$CURRENTIP_FILE.tmp
else
    echo
fi

if echo $AUDIO | grep -qx "BEEP"; then
	BELL1=( "beep" )
	BELL2=( "beep -f 1000 -n -f 2000 -n -f 1500" )
	BELL3=( "beep -f 2000" )
elif echo $AUDIO | grep -qx "SOX"; then
	BELL1=( "play -q -n synth 0.2 square 1000 gain $GAIN fade h 0.01" )
	BELL2=( "play -q -n synth 0.2 square 1000 gain $GAIN : synth 0.2 square 2000 gain $GAIN fade h 0.01 : synth 0.2 square 1500 gain $GAIN fade h 0.01" )
	BELL3=( "play -q -n synth 0.2 square 2000 gain $GAIN fade h 0.01" )
elif echo $AUDIO | grep -qx "NULL"; then
	BELL0="echo BEEP"
	BELL1="echo BEEP"
	BELL2="echo BEEP"
else
	BELL0="echo BEEP"
	BELL1="echo BEEP"
	BELL2="echo BEEP"
fi

serverip_default(){
if echo $SERVERIP | grep -x "$SERVERIP_LAN" | grep -Eoq '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'; then
	serverip_lan
elif echo $SERVERIP | grep -x "$SERVERIP_INTERNET" | grep -Eoq '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'; then
	serverip_internet
else
	givemehelp
fi
}

menu0(){
$BELL2
echo -e "\e[1;34m
## $SERVERUSERNAME@$SERVERNAME IP=$SERVERIP Port=$SSHPORT\e[0m"
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
## $SERVERUSERNAME@$SERVERNAME\e[0m"
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
  SERVERIP=$ip
  SERVERIP_LAN=$SERVERIP
  SERVERIP_INTERNET=$SERVERIP
SERVERIP_STEP=serverip_manual
menu0
}

serverip_lan(){
TYPE=LOCALE
SERVERIP_START_STEP=serverip_lan
COUNTDOWN=$LAN_COUNTDOWN
RESET_COUNTDOWNSTEP=$LANCOUNTSTEP
serverip_lan_static
}
serverip_lan_static(){
echo "Indirizzo IP locale statico o più affidabile..."
SERVERIP=$SERVERIP_LAN
PING="$(fping -r0 $SERVERIP_LAN | grep "alive")"
SERVERIP_STEP=serverip_lan_1
ping_serverip
}
serverip_lan_1(){
echo "Indirizzo IP locale memorizzato 1..."
SERVERIP="$(cat "$CURRENTIP" | grep SERVERIP_LAN_1 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
PING="$(fping -r0 $SERVERIP_LAN | grep "alive")"
SERVERIP_STEP=$LANCOUNTSTEP
ping_serverip
}

serverip_internet(){
TYPE=REMOTO
SERVERIP_START_STEP=serverip_internet
COUNTDOWN=$INTERNET_COUNTDOWN
RESET_COUNTDOWNSTEP=$INTERNETCOUNTSTEP
serverip_internet_static
}
serverip_internet_static(){
echo "Indirizzo IP pubblico statico o più affidabile..."
SERVERIP=$SERVERIP_INTERNET
PING="$(nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open")"
SERVERIP_STEP=serverip_internet_1
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
serverip_error
}
serverip_error_countdown_9(){
COUNTDOWN=9
COUNTDOWNSTEP=serverip_error_countdown_8
serverip_error
}
serverip_error_countdown_8(){
COUNTDOWN=8
COUNTDOWNSTEP=serverip_error_countdown_7
serverip_error
}
serverip_error_countdown_7(){
COUNTDOWN=7
COUNTDOWNSTEP=serverip_error_countdown_6
serverip_error
}
serverip_error_countdown_6(){
COUNTDOWN=6
COUNTDOWNSTEP=serverip_error_countdown_5
serverip_error
}
serverip_error_countdown_5(){
COUNTDOWN=5
COUNTDOWNSTEP=serverip_error_countdown_4
serverip_error
}
serverip_error_countdown_4(){
COUNTDOWN=4
COUNTDOWNSTEP=serverip_error_countdown_3
serverip_error
}
serverip_error_countdown_3(){
COUNTDOWN=3
COUNTDOWNSTEP=serverip_error_countdown_2
serverip_error
}
serverip_error_countdown_2(){
COUNTDOWN=2
COUNTDOWNSTEP=serverip_error_countdown_1
serverip_error
}
serverip_error_countdown_1(){
COUNTDOWN=1
COUNTDOWNSTEP=serverip_error_countdown_0
serverip_error
}
serverip_error_countdown_0(){
COUNTDOWN=0
COUNTDOWNSTEP=serverip_error_countdown_end
serverip_error
}
serverip_error_countdown_end(){
$SERVERIP_START_STEP
}

serverip_error(){
clear
echo -e "\e[1;34m
$SERVERUSERNAME@$SERVERNAME @ $SERVERIP ($TYPE) non raggiungibile,
è\e[0m" "\e[1;31mOFFLINE o rete non disponibile\e[0m"
#	echo -e "\e[1;31mProvo a risvegliare il device...\e[0m"
#	wakeonlan -i "$SERVERIP" $SERVERMAC
echo -e "\e[1;31mPremi:
A per provare ad aggiornare gli indirizzi IP
M per inserire manualmente l'indirizzo IP del server
R o attendi $COUNTDOWN secondi per riprovare
E per uscire\e[0m"
read -t 1 -n 1 -p "Scelta (A/M/R/E): " testo
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
	if [ -e /tmp/$CURRENTIP_FILE.tmp ]
	then
	    rm /tmp/$CURRENTIP_FILE.tmp
	else
	    echo
	fi
	echo -e "\e[1;34mEsco dal programma\e[0m"
	exit 0
	}
    ;;
    "")
	{
	echo "Tempo scaduto"
	echo -e "\e[1;34m	Riprovo...
	\e[0m"
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
diff -q "$CURRENTIP" "/tmp/$CURRENTIP_FILE.tmp"
if [ $? != 0 ]; then
	echo -e "\e[1;34mProvo ad aggiornare gli indirizzi IP...\e[0m"
	wget -q $CURRENTIP_LINK -O /tmp/$CURRENTIP_FILE.tmp
	if [ $? = 0 ]; then
		cp /tmp/$CURRENTIP_FILE.tmp $CURRENTIP
	else
		echo
	fi
fi
$SERVERIP_START_STEP
}

ping_serverip(){
echo -e "\e[1;34m
## PING $SERVERUSERNAME@$SERVERNAME  IP=$SERVERIP Port=$SSHPORT
\e[0m"
$BELL1
if echo $PING | grep -q "alive"; then
	SERVERIP="$(fping -q -r0 -a $SERVERIP_LAN)"
	menu
elif echo $PING | grep -q "$SSHPORT/tcp open"; then
	menu
else
$SERVERIP_STEP
fi
}

menu(){
PING=""
$BELL2
echo -e "\e[1;34m$SERVERUSERNAME@$SERVERNAME @ $SERVERIP ($TYPE) è\e[0m" "\e[1;32mONLINE\e[0m"
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
	echo -e "\e[1;34m
	## SSH $SERVERUSERNAME@$SERVERNAME SOCKS
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
## SSH $SERVERUSERNAME@$SERVERNAME SSHFS
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
## SSH $SERVERUSERNAME@$SERVERNAME GUI
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
## SSH $SERVERUSERNAME@$SERVERNAME CLI
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

givemehelp(){
echo "
# ssh-servers

# Version:    2.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-servers
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Lo script bash ssh-servers facilita la connessione ad uno o più server ssh remoti, automatizzando la connessione tramite
file di configurazione personalizzati e grazie a menu interattivi.

### CONFIGURAZIONE
Questo script non può essere utilizzato così com'è, ma deve essere necessariamente richiamato da un altro script/file di configurazione
che dovrà essere compilato in maniera precisa. L'esempio dello script/file di configurazione
https://github.com/KeyofBlueS/ssh-servers/blob/master/Esempio-configurazione-ssh-server.sh
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

--help        Visualizza una descrizione ed opzioni di ssh-servers

### Nota
Se i server ssh posseggono un indirizzo ip pubblico dinamico, consiglio fortemente (i due script si integrano a vicenda) di
utilizzare [current-ip](https://github.com/KeyofBlueS/current-ip) sul lato server.
"
exit 0
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
else
   givemehelp
fi

#!/bin/bash

# Version:    1.5.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-servers
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# Dependencies:
# sudo apt get install beep sox fping nmap wakeonlan openssh-client sshfs fusermount

#echo -n "Checking dependencies... "
for name in fping fusermount nmap ssh sshfs wakeonlan
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

for name in beep sox
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è consigliato da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze consigliate e riavvia questo script\n";}

#KEYFILE=/PATH/TO/KEYFILE
#SSHPORT=22
#SERVERUSERNAME=user
#SERVERIP_LAN=0.0.0.0
#SERVERIP_INTERNET=0.0.0.0
#SERVERIP=$SERVERIP_LAN
#SERVERMAC=
#TYPE=LOCALE|REMOTO
#SERVERNAME=HOST
#SOCKSPORT=1080
#REMOTEMOUNTPOINT=/
LOCALUSER=$USER
LOCALMOUNTPOINT="/media/"$LOCALUSER"/"$SERVERNAME"_SSHFS"

CURRENTIP=$CURRENTIP_PATH$CURRENTIP_FILE

LANCOUNTSTEP=serverip_lan_error_countdown_$LAN_COUNTDOWN
INTERNETCOUNTSTEP=serverip_internet_error_countdown_$INTERNET_COUNTDOWN

if [ -e /tmp/$CURRENTIP_FILE.tmp ]
then
    rm /tmp/$CURRENTIP_FILE.tmp
else
    echo
fi

# BEEP
BEEP1=( "beep" )
BEEP2=( "beep -f 1000 -n -f 2000 -n -f 1500" )
BEEP3=( "beep -f 2000" )
# SOX
#GAIN="-50"
#BEEP1=( "play -q -n synth 0.2 square 1000 gain $GAIN fade h 0.01" )
#BEEP2=( "play -q -n synth 0.2 square 1000 gain $GAIN : synth 0.2 square 2000 gain $GAIN fade h 0.01 : synth 0.2 square 1500 gain $GAIN fade h 0.01" )
#BEEP3=( "play -q -n synth 0.2 square 2000 gain $GAIN fade h 0.01" )

menu0(){
$BEEP2
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
	ping_lan
	}
    ;;
    R|r)
	{
  echo -e "\e[1;34m
## HAI SCELTO REMOTO\e[0m"
	serverip_internet_static
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

serverip_lan_error_countdown_10(){
LANCOUNT=10
LANCOUNTSTEP=serverip_lan_error_countdown_9
serverip_lan_error
}

serverip_lan_error_countdown_9(){
LANCOUNT=9
LANCOUNTSTEP=serverip_lan_error_countdown_8
serverip_lan_error
}

serverip_lan_error_countdown_8(){
LANCOUNT=8
LANCOUNTSTEP=serverip_lan_error_countdown_7
serverip_lan_error
}

serverip_lan_error_countdown_7(){
LANCOUNT=7
LANCOUNTSTEP=serverip_lan_error_countdown_6
serverip_lan_error
}

serverip_lan_error_countdown_6(){
LANCOUNT=6
LANCOUNTSTEP=serverip_lan_error_countdown_5
serverip_lan_error
}

serverip_lan_error_countdown_5(){
LANCOUNT=5
LANCOUNTSTEP=serverip_lan_error_countdown_4
serverip_lan_error
}

serverip_lan_error_countdown_4(){
LANCOUNT=4
LANCOUNTSTEP=serverip_lan_error_countdown_3
serverip_lan_error
}

serverip_lan_error_countdown_3(){
LANCOUNT=3
LANCOUNTSTEP=serverip_lan_error_countdown_2
serverip_lan_error
}

serverip_lan_error_countdown_2(){
LANCOUNT=2
LANCOUNTSTEP=serverip_lan_error_countdown_1
serverip_lan_error
}

serverip_lan_error_countdown_1(){
LANCOUNT=1
LANCOUNTSTEP=serverip_lan_error_countdown_0
serverip_lan_error
}

serverip_lan_error_countdown_0(){
LANCOUNT=0
LANCOUNTSTEP=serverip_lan_error_countdown_end
serverip_lan_error
}

serverip_lan_error_countdown_end(){
LANCOUNT=$LAN_COUNTDOWN
LANCOUNTSTEP=serverip_lan_error_countdown_$LAN_COUNTDOWN
ping_lan
}

serverip_lan_error(){
clear
echo -e "\e[1;34m
$SERVERUSERNAME@$SERVERNAME @ $SERVERIP_LAN non raggiungibile, è\e[0m" "\e[1;31mOFFLINE o rete non disponibile\e[0m"
#	echo -e "\e[1;31mProvo a risvegliare il device...\e[0m"
#	wakeonlan -i "$SERVERIP" $SERVERMAC
echo -e "\e[1;31mPremi:
M per inserire manualmente l'indirizzo IP del server
R o attendi $LANCOUNT secondo per riprovare
E per uscire\e[0m"
read -t 1 -n 1 -p "Scelta (M/R/E): " testo
case $testo in
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
	$LANCOUNTSTEP
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
	clear
	$LANCOUNTSTEP
#	serverip_internet_static
	}
    ;;
    *)
echo -e "\e[1;31m ## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m" && sleep 2
LANCOUNTSTEP=serverip_lan_error_countdown_$LAN_COUNTDOWN
serverip_lan_error
    ;;
esac
}

ping_lan(){
while true
do
TYPE=LOCALE
  echo -e "\e[1;34m
## PING $SERVERUSERNAME@$SERVERNAME  IP=$SERVERIP Port=$SSHPORT
\e[0m"
  $BEEP1
  fping -r0 $SERVERIP_LAN | grep "alive"
  if [ $? = 0 ]; then
	SERVERIP=`fping -q -r0 -a $SERVERIP_LAN`
	echo -e "\e[1;34m
	$SERVERUSERNAME@$SERVERNAME @ $SERVERIP è\e[0m" "\e[1;32mONLINE\e[0m"
	break
  fi
$LANCOUNTSTEP
	done
menu
}

serverip_manual(){
$BEEP1
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
SERVERIP_INTERNET_STEP=serverip_manual
menu0
}

serverip_internet_static(){
echo "Indirizzo IP statico o più affidabile:"
  SERVERIP=$SERVERIP_INTERNET
SERVERIP_INTERNET_STEP=serverip_internet_1
ping_wan
}

serverip_internet_1(){
echo "Indirizzo IP dinamico o memorizzato 1"
  SERVERIP=`cat "$CURRENTIP" | grep SERVERIP_INTERNET_1 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'`
SERVERIP_INTERNET_STEP=serverip_internet_2
ping_wan
}

serverip_internet_2(){
echo "Indirizzo IP dinamico o memorizzato 2"
  SERVERIP=`cat "$CURRENTIP" | grep SERVERIP_INTERNET_2 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'`
SERVERIP_INTERNET_STEP=serverip_internet_3
ping_wan
}

serverip_internet_3(){
echo "Indirizzo IP dinamico o memorizzato 3"
  SERVERIP=`cat "$CURRENTIP" | grep SERVERIP_INTERNET_3 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'`
SERVERIP_INTERNET_STEP=serverip_internet_4
ping_wan
}

serverip_internet_4(){
echo "Indirizzo IP dinamico o memorizzato 4"
  SERVERIP=`cat "$CURRENTIP" | grep SERVERIP_INTERNET_4 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'`
SERVERIP_INTERNET_STEP=serverip_internet_error

ping_wan
}

serverip_internet_error_countdown_10(){
INTERNETCOUNT=10
INTERNETCOUNTSTEP=serverip_internet_error_countdown_9
serverip_internet_error
}

serverip_internet_error_countdown_9(){
INTERNETCOUNT=9
INTERNETCOUNTSTEP=serverip_internet_error_countdown_8
serverip_internet_error
}

serverip_internet_error_countdown_8(){
INTERNETCOUNT=8
INTERNETCOUNTSTEP=serverip_internet_error_countdown_7
serverip_internet_error
}

serverip_internet_error_countdown_7(){
INTERNETCOUNT=7
INTERNETCOUNTSTEP=serverip_internet_error_countdown_6
serverip_internet_error
}

serverip_internet_error_countdown_6(){
INTERNETCOUNT=6
INTERNETCOUNTSTEP=serverip_internet_error_countdown_5
serverip_internet_error
}

serverip_internet_error_countdown_5(){
INTERNETCOUNT=5
INTERNETCOUNTSTEP=serverip_internet_error_countdown_4
serverip_internet_error
}

serverip_internet_error_countdown_4(){
INTERNETCOUNT=4
INTERNETCOUNTSTEP=serverip_internet_error_countdown_3
serverip_internet_error
}

serverip_internet_error_countdown_3(){
INTERNETCOUNT=3
INTERNETCOUNTSTEP=serverip_internet_error_countdown_2
serverip_internet_error
}

serverip_internet_error_countdown_2(){
INTERNETCOUNT=2
INTERNETCOUNTSTEP=serverip_internet_error_countdown_1
serverip_internet_error
}

serverip_internet_error_countdown_1(){
INTERNETCOUNT=1
INTERNETCOUNTSTEP=serverip_internet_error_countdown_0
serverip_internet_error
}

serverip_internet_error_countdown_0(){
INTERNETCOUNT=0
INTERNETCOUNTSTEP=serverip_internet_error_countdown_end
serverip_internet_error
}

serverip_internet_error_countdown_end(){
INTERNETCOUNT=$INTERNET_COUNTDOWN
INTERNETCOUNTSTEP=serverip_internet_error_countdown_$INTERNET_COUNTDOWN
serverip_internet_static
}

serverip_internet_error(){
clear
echo -e "\e[1;34m
$SERVERUSERNAME@$SERVERNAME non raggiungibile, è\e[0m" "\e[1;31mOFFLINE o rete non disponibile\e[0m"
#	echo -e "\e[1;31mProvo a risvegliare il device...\e[0m"
#	wakeonlan -i "$SERVERIP" $SERVERMAC
echo -e "\e[1;31mPremi:
A per provare ad aggiornare gli indirizzi IP
M per inserire manualmente l'indirizzo IP del server
R o attendi $INTERNETCOUNT secondi per riprovare
E per uscire\e[0m"
read -t 1 -n 1 -p "Scelta (A/M/R/E): " testo
case $testo in
    A|a)
	{
	serverip_internet_update
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
	$INTERNETCOUNTSTEP
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
	clear
	$INTERNETCOUNTSTEP
#	serverip_internet_static
	}
    ;;
    *)
echo -e "\e[1;31m ## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m" && sleep 2
INTERNETCOUNTSTEP=serverip_internet_error_countdown_$INTERNET_COUNTDOWN
#ping_wan
serverip_internet_error
    ;;
esac
}

serverip_internet_update(){
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
serverip_internet_static
}

ping_wan(){
while true
do
TYPE=REMOTO
    echo -e "\e[1;34m
## NMAP $SERVERUSERNAME@$SERVERNAME  IP=$SERVERIP Port=$SSHPORT
\e[0m"
  $BEEP1
  nmap --host-timeout 3000ms -p "$SSHPORT" "$SERVERIP" | grep "$SSHPORT/tcp open"
  if [[ $? = 0 ]]; then
	echo -e "\e[1;34m
	$SERVERUSERNAME@$SERVERNAME @ $SERVERIP è\e[0m" "\e[1;32mONLINE\e[0m"
	break
  fi
$SERVERIP_INTERNET_STEP
	done
if [ -e /tmp/$CURRENTIP_FILE.tmp ]
then
    rm /tmp/$CURRENTIP_FILE.tmp
else
    echo
fi
menu
}

menu(){
clear
$BEEP2
echo -e "\e[1;34m
## L'indirizzo remoto è $SERVERIP ($TYPE)

## $SERVERUSERNAME@$SERVERNAME\e[0m"
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
while true
do
  echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERNAME SOCKS
\e[0m"
#  sleep 1
  $BEEP3
  ssh -i "$KEYFILE" -ND $SOCKSPORT -p $SSHPORT $SERVERUSERNAME@$SERVERIP
#	menu0
	menu
	done
	}
    ;;
    M|m)
	{
while true
do
  echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERNAME SSHFS
\e[0m"
#  sleep 1
  $BEEP3
  fusermount -u "$LOCALMOUNTPOINT"
  sudo mkdir "$LOCALMOUNTPOINT"
  sudo chown $LOCALUSER "$LOCALMOUNTPOINT"
  sshfs -d -o IdentityFile="$KEYFILE" -o allow_other -o reconnect -o ServerAliveInterval=15 $SERVERUSERNAME@$SERVERIP:"$REMOTEMOUNTPOINT" "$LOCALMOUNTPOINT" -p $SSHPORT -C
  fusermount -u "$LOCALMOUNTPOINT"
#	menu0
	menu
	done
	}
    ;;
    G|g)
	{
while true
do
  echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERNAME GUI
\e[0m"
#  sleep 1
  $BEEP3
  ssh -i "$KEYFILE" -X -p $SSHPORT $SERVERUSERNAME@$SERVERIP
#	menu0
	menu
	done
	}
    ;;
    C|c)
	{
while true
do
  echo -e "\e[1;34m
## SSH $SERVERUSERNAME@$SERVERNAME CLI
\e[0m"
#  sleep 1
  $BEEP3
  ssh -i "$KEYFILE" -p $SSHPORT $SERVERUSERNAME@$SERVERIP
#	menu0
	menu
	done
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
    menu
    ;;
esac
}

givemehelp(){
echo "
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
utilizzare "'"current-ip"'" https://github.com/KeyofBlueS/current-ip
"
exit 0
}

if [ "$1" = "--local" ]
then
   ping_lan
elif [ "$1" = "--remote" ]
then
   serverip_internet_static
elif [ "$1" = "--manual" ]
then
   serverip_manual
elif [ "$1" = "--default" ]
then
   menu
elif [ "$1" = "--help" ]
then
   STATUS="exit 0"
   givemehelp
else
   STATUS=menu0
   menu
fi

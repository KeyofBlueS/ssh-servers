#!/bin/bash

############################## Impostazioni comuni per questo server ##############################
# Percorso del file chiave, richiesto per il collegamento tramite key authtentication
export KEYFILE=~/.ssh/keys/key-ecdsa
# Porta in ascolto del server ssh (default 22)
export SSHPORT=22
# Porta in cui verrà avviato un Server SOCKS per condividere la connessione del server sul client
export SOCKSPORT=1080
# Nome dell'utente presente sul server su cui ci si vuole loggare (non utilizzare "root")
export SERVERUSERNAME=user
# $HOSTNAME del server (meramente informativo per una più facile identificazione del server, ma necessario per il montaggio tramite SSHFS)
export SERVERNAME=server_hostname
# Punto di mount del server, la cartella radice da cui verrà montato localmente il server tramite SSHFS
export REMOTEMOUNTPOINT=/
# Indirizzo/indirizzi MAC (separati da uno spazio) del server, richiesto per provare a risvegliare il server tramite Wake On LAN
export SERVEMAC="AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10"

############################## Impostazioni per il collegamento ssh in locale ##############################
# Indirizzo/indirizzi IP (separati da uno spazio) nella rete locale del server - si consiglia di impostare un indirizzo statico sul server
export SERVERIP_LAN="000.000.000.000"
# Secondi di attesa prima di provare a ricontattare il server nella rete locale nel caso questo sia irraggiungibile (inserire un valore da 0 a 10)
export LAN_COUNTDOWN=5

############################## Impostazioni per il collegamento ssh in remoto ##############################
# URL del file contenente gli indirizzi ip del server remoto (opzionale)
export CURRENTIP_LINK=https://www.miositoftp.com/user@server_hostname_current.txt
# Percorso locale in cui è presente il file contenente gli indirizzi ip del server remoto (opzionale; default $HOME/)
export CURRENTIP_PATH=$HOME/
# Nome del file contenente gli indirizzi ip del server remoto (opzionale)
# Se presente dovrà contenere gli indirizzi ip nel seguente formato:
#SERVERIP_INTERNET_1=000.000.000.000
#SERVERIP_INTERNET_2=000.000.000.000
#SERVERIP_INTERNET_3=000.000.000.000
#SERVERIP_INTERNET_4=000.000.000.000
export CURRENTIP_FILE=user@server_hostname_current.txt
# Indirizzo preferito (quello più affidabile) per la connessione in remoto (SERVERIP_INTERNET_1 2 3 o 4) o un IP pubblico statico
export SERVERIP_INTERNET=`cat $CURRENTIP_PATH$CURRENTIP_FILE | grep SERVERIP_INTERNET_2 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'`
#export SERVERIP_INTERNET=000.000.000.000
# Secondi di attesa prima di provare a ricontattare il server remoto nel caso questo sia irraggiungibile (inserire un valore da 0 a 10
export INTERNET_COUNTDOWN=10

############################## Impostazioni per il tipo di collegamento preferito ##############################
# Tipo di collegamento (meramente informativo, non necessario, inserire qualsiasi valore desiderato) es. LOCALE o REMOTO
#export TYPE=LOCALE
export TYPE=REMOTO
# Indirizzo IP locale o remoto: $SERVERIP_LAN o $SERVERIP_INTERNET
#export SERVERIP=$SERVERIP_LAN
export SERVERIP=$SERVERIP_INTERNET

############################## Avvio collegamento ##############################
# Percorso dello script per il collegamento (es. /opt/ssh-servers/ssh_servers.sh $@)
ssh-servers $@

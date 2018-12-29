#!/bin/bash

# Qualsiasi informazione che presenta uno spazio vuoto DEVE essere racchiusa tra doppie virgolette (") , es.
# export SERVEMAC=AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10 <- ERRATO
# export SERVEMAC="AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10" <- CORRETTO
# export CURRENTIP_PATH=$HOME/i miei ip <- ERRATO
# export CURRENTIP_PATH="$HOME/i miei ip" <- CORRETTO

############################## Impostazioni per il reperimento informazioni del server ##############################
### Vedi [current-ip](https://github.com/KeyofBlueS/current-ip)
# URL del file contenente le informazioni del server remoto (opzionale)
export CURRENTIP_LINK=https://www.miositoftp.com/user@server_hostname_current.txt
# Percorso locale in cui è presente il file contenente le informazioni del server remoto (opzionale)
export CURRENTIP_PATH=$HOME
# Nome del file contenente le informazioni del server remoto (opzionale)
# Se presente dovrà contenere le informazioni nel seguente formato:
#SSHPORT=22
#SERVERUSERNAME=server_username
#SERVERHOSTNAME=server_hostname
#SERVERIP_INTERNET_1=000.000.000.000
#SERVERIP_INTERNET_2=000.000.000.000
#SERVERIP_INTERNET_3=000.000.000.000
#SERVERIP_INTERNET_4=000.000.000.000
#SERVERIP_LAN_1=000.000.000.000
export CURRENTIP_FILE=user@server_hostname_current.txt

############################## Impostazioni comuni per questo server ##############################
# Percorso del file chiave, richiesto per il collegamento tramite key authtentication
export KEYFILE=~/.ssh/keys/key-ecdsa
# Porta in ascolto del server ssh (default 22)
#export SSHPORT="$(cat "$CURRENTIP_PATH/$CURRENTIP_FILE" | grep "export SSHPORT=" | grep -Eo '([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])')"
export SSHPORT=22
# Porta in cui verrà avviato un Server SOCKS per condividere la connessione del server sul client
export SOCKSPORT=1080
# Nome dell'utente presente sul server su cui ci si vuole loggare (non utilizzare "root")
#export SERVERUSERNAME="$(cat "$CURRENTIP_PATH/$CURRENTIP_FILE" | grep "export SERVERUSERNAME=" | cut -c23-55)"
export SERVERUSERNAME=server_username
# $HOSTNAME del server (meramente informativo per una più facile identificazione del server, ma necessario per il montaggio tramite SSHFS)
export SERVERNAME=server_hostname
# Punto di mount del server, la cartella radice da cui verrà montato localmente il server tramite SSHFS
export REMOTEMOUNTPOINT=/
# Indirizzo/indirizzi MAC (separati da uno spazio) del server, richiesto per provare a risvegliare il server tramite Wake On LAN
export SERVEMAC="AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10"

############################## Impostazioni per il collegamento ssh in locale ##############################
# Indirizzo/indirizzi preferiti (quello più affidabile, separati da uno spazio) per la connessione in locale (SERVERIP_LAN_1) o un IP statico
# si consiglia comunque di impostare un indirizzo statico sul server
#export SERVERIP_LAN="$(cat $CURRENTIP_PATH/$CURRENTIP_FILE | grep SERVERIP_LAN_1 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
export SERVERIP_LAN=000.000.000.000
# Secondi di attesa prima di provare a ricontattare il server nella rete locale nel caso questo sia irraggiungibile
# inserire un valore da 0 a 10, durante il countdown viene comunque chiesto all'utente come proseguire
# oppure inserire exit per non riprovare automaticamente ed uscire dallo script
# oppure inserire ask per non riprovare automaticamente, viene chiesto all'utente come proseguire
#export LAN_COUNTDOWN=exit
#export LAN_COUNTDOWN=ask
export LAN_COUNTDOWN=5

############################## Impostazioni per il collegamento ssh in remoto ##############################
# Indirizzo preferito (quello più affidabile) per la connessione in remoto (SERVERIP_INTERNET_1 2 3 o 4) o un IP pubblico statico
export SERVERIP_INTERNET="$(cat "$CURRENTIP_PATH/$CURRENTIP_FILE" | grep SERVERIP_INTERNET_2 | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
#export SERVERIP_INTERNET=000.000.000.000
# Secondi di attesa prima di provare a ricontattare il server nella rete locale nel caso questo sia irraggiungibile
# inserire un valore da 0 a 10, durante il countdown viene comunque chiesto all'utente come proseguire
# oppure inserire exit per non riprovare automaticamente ed uscire dallo script
# oppure inserire ask per non riprovare automaticamente, viene chiesto all'utente come proseguire
#export LAN_COUNTDOWN=exit
#export LAN_COUNTDOWN=ask
export INTERNET_COUNTDOWN=10

############################## Impostazioni per il tipo di collegamento preferito ##############################
# Indirizzo IP locale o remoto: $SERVERIP_LAN o $SERVERIP_INTERNET
#export SERVERIP=$SERVERIP_LAN
export SERVERIP=$SERVERIP_INTERNET

############################# Impostazioni per il tipo segnale acustico #############################
# Tipo di segnale acustico da utilizzare (BEEP, SOX, NULL)
# BEEP  Imposta il segnale acustico tramite lo speaker interno (richiede beep)
# SOX   Imposta il segnale acustico tramite la scheda audio (richiede sox)
# NULL  Disattiva il segnale acustico (default)
export AUDIO=BEEP
# Regola il volume delle segnalazioni acustiche per SOX
export GAIN=-50

############################## Avvio collegamento ##############################
# Percorso dello script per il collegamento (es. /opt/ssh-servers/ssh_servers.sh $@)
ssh-servers $@

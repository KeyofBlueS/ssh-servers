#!/bin/bash
set -a

# Qualsiasi informazione che presenta uno spazio vuoto DEVE essere racchiusa tra doppie virgolette (") , es.
# SERVEMAC=AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10 <- ERRATO
# SERVEMAC="AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10" <- CORRETTO
# CURRENTIP_PATH=$HOME/i miei ip <- ERRATO
# CURRENTIP_PATH="$HOME/i miei ip" <- CORRETTO

#Se le seguenti opzioni non verranno configurate (o configurate in modo erroneo), verranno utilizzati i loro valori di default:
#SSHPORT (default: 22)
#SOCKSPORT (default: 1080)
#REMOTEMOUNTPOINT (default: /)
#LAN_COUNTDOWN (default: 5)
#INTERNET_COUNTDOWN (default: 10)
#AUDIO (default: null)
#GAIN (default: -25)

############################## Impostazioni per il reperimento informazioni del server ##############################
### Vedi [current-ip](https://github.com/KeyofBlueS/current-ip)
# URL del file contenente le informazioni del server remoto (opzionale)
CURRENTIP_LINK=https://www.miositoftp.com/user@server_hostname_current.txt

# Percorso locale in cui è presente il file contenente le informazioni del server remoto (opzionale)
CURRENTIP_PATH=$HOME

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
CURRENTIP_FILE=user@server_hostname_current.txt

############################## Impostazioni comuni per questo server ##############################
# Percorso del file chiave, richiesto per il collegamento tramite key authtentication (opzionale)
KEYFILE=$HOME/.ssh/keys/key-ecdsa

# Porta in ascolto del server ssh (default: 22)
SSHPORT=22
# Per reperire l'informazione direttamente dal file contenente le informazioni del server remoto, utilizzare invece la linea seguente:
#SSHPORT=from-current-ip

# Porta in cui verrà avviato un Server SOCKS per condividere la connessione del server sul client (default: 1080)
SOCKSPORT=1080

# Nome dell'utente presente sul server su cui ci si vuole loggare (non utilizzare "root")
SERVERUSERNAME=server_username
# Per reperire l'informazione direttamente dal file contenente le informazioni del server remoto, utilizzare invece la linea seguente:
#SERVERUSERNAME=from-current-ip

# $HOSTNAME del server (meramente informativo per una più facile identificazione del server, ma necessario per il montaggio tramite SSHFS)
SERVERHOSTNAME=server_hostname
# Per reperire l'informazione direttamente dal file contenente le informazioni del server remoto, utilizzare invece la linea seguente:
#SERVERHOSTNAME=from-current-ip

# Punto di mount del server, la cartella radice da cui verrà montato localmente il server tramite SSHFS (default: /)
REMOTEMOUNTPOINT=/

# Indirizzo/indirizzi MAC (separati da uno spazio) del server, richiesto per provare a risvegliare il server tramite Wake On LAN (opzionale - ANCORA NON IMPLEMENTATO)
SERVEMAC="AB:01:CD:23:EF:45 GH:67:IJ:89:KL:10"

############################## Impostazioni per il collegamento ssh in locale ##############################
# Indirizzo/indirizzi preferiti (quello più affidabile, separati da uno spazio) per la connessione in locale o un IP statico
# si consiglia comunque di impostare un indirizzo statico sul server
SERVERIP_LAN=000.000.000.000
# Per reperire l'informazione direttamente dal file contenente le informazioni del server remoto, utilizzare invece la linea seguente:
#SERVERIP_LAN=from-current-ip

# Secondi di attesa prima di provare a ricontattare il server nella rete locale nel caso questo fosse irraggiungibile (default: 5)
# inserire un valore in secondi, durante il countdown viene comunque chiesto all'utente come proseguire
# oppure inserire exit per non riprovare automaticamente ed uscire dallo script
# oppure inserire ask per non riprovare automaticamente, viene chiesto all'utente come proseguire
#LAN_COUNTDOWN=exit
#LAN_COUNTDOWN=ask
LAN_COUNTDOWN=5

############################## Impostazioni per il collegamento ssh in remoto ##############################
# Indirizzo preferito (quello più affidabile) per la connessione in remoto o un IP pubblico statico
SERVERIP_INTERNET=000.000.000.000
# Per reperire l'informazione direttamente dal file contenente le informazioni del server remoto, utilizzare invece la linea seguente ed
# imposta from-current-ip-1 2 3 o 4 (quello più affidabile):
#SERVERIP_INTERNET=from-current-ip-1
#SERVERIP_INTERNET=from-current-ip-2
#SERVERIP_INTERNET=from-current-ip-3
#SERVERIP_INTERNET=from-current-ip-4

# Secondi di attesa prima di provare a ricontattare il server nella rete locale nel caso questo fosse irraggiungibile (default: 10)
# inserire un valore in secondi, durante il countdown viene comunque chiesto all'utente come proseguire
# oppure inserire exit per non riprovare automaticamente ed uscire dallo script
# oppure inserire ask per non riprovare automaticamente, viene chiesto all'utente come proseguire
#INTERNET_COUNTDOWN=exit
#INTERNET_COUNTDOWN=ask
INTERNET_COUNTDOWN=10

############################## Impostazioni per il tipo di collegamento preferito ##############################
# Imposta il tipo di collegamento preferito, inserisci:
#LAN	- se il server si trova all'interno della rete locale
#INTERNET	- se il server si trova su internet
#SERVERIP=lan
SERVERIP=internet

############################# Impostazioni per il tipo segnale acustico #############################
# Tipo di segnale acustico da utilizzare (beep, sox, null) (default: null)
# beep  Imposta il segnale acustico tramite lo speaker interno (richiede beep)
# sox   Imposta il segnale acustico tramite la scheda audio (richiede sox)
# null  Disattiva il segnale acustico
AUDIO=beep
#AUDIO=sox
#AUDIO=null

# Regola il volume delle segnalazioni acustiche per SOX (default: -25)
# Inserire qualsiasi valore negativo o positivo es -20, 0, 10, +20
GAIN=-25

############################## Avvio collegamento ##############################
# Percorso dello script per il collegamento (es. /opt/ssh-servers/ssh_servers.sh $@)
ssh-servers $@

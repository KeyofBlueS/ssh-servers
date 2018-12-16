# ssh-servers

# Version:    1.5.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-servers
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Lo script bash ssh-servers facilita la connessione ad uno o più server ssh remoti, automatizzando la connessione tramite
[file di configurazione personalizzati](https://github.com/KeyofBlueS/ssh-servers/blob/master/Esempio-configurazione-ssh-server.sh) e grazie a menu interattivi.

### INSTALLAZIONE
```sh
curl -o /tmp/ssh_servers.sh 'https://raw.githubusercontent.com/KeyofBlueS/ssh-servers/master/ssh_servers.sh'
sudo mkdir -p /opt/ssh-servers/
sudo mv /tmp/ssh_servers.sh /opt/ssh-servers/
sudo chown root:root /opt/ssh-servers/ssh_servers.sh
sudo chmod 755 /opt/ssh-servers/ssh_servers.sh
sudo chmod +x /opt/ssh-servers/ssh_servers.sh
sudo ln -s /opt/ssh-servers/ssh_servers.sh /usr/local/bin/ssh-servers
```

### CONFIGURAZIONE
Questo script non può essere utilizzato così com'è, ma deve essere necessariamente richiamato da un altro [script/file di configurazione](https://github.com/KeyofBlueS/ssh-servers/blob/master/Esempio-configurazione-ssh-server.sh)
che dovrà essere compilato in maniera precisa. L'esempio dello [script/file di configurazione](https://github.com/KeyofBlueS/ssh-servers/blob/master/Esempio-configurazione-ssh-server.sh)
è commentato in modo esaustivo, basatevi su quello.
Una volta compilato e salvato lo script di configurazione, deve essere reso eseguibile, quindi se ad esempio il nostro script di
configurazione si chiama "mario-rossi-ssh-server.sh" e si trova nel percorso $HOME/ssh-servers/, dovremo dare il comando:
```sh
$ chmod +x "$HOME/ssh-servers/mario-rossi-ssh-server.sh"
```
soltanto una volta per ogni script di configurazione creato.

### UTILIZZO
Una volta creati correttamente uno o più script di configurazione, basta avviarli su un terminale.
Ad esempio se vogliamo collegarci tramite lo script di configurazione "mario-rossi-ssh-server.sh, su un terminale digitare:
```sh
$ "$HOME/ssh-servers/mario-rossi-ssh-server.sh"
```

A questo punto seguire le istruzioni su schermo.

Una volta che il server è stato rilevato, è possibile avviare diversi tipi di connessione:
```
Socks - Crea un socks server per condividere la connessione del server sul client
Monta localmente il server tramite SSHFS
GUI - Con supporto alla GUI sul Client
CLI - Con il solo supporto alla CLI
```
È possibile utilizzare le seguenti opzioni:
```
--local	      Avvia una connessione ssh verso un server in ascolto all'interno della rete LAN

--remote      Avvia una connessione ssh verso un server in ascolto su internet

--manual      Imposta manualmente l'indirizzo ip del server ssh

--default     Avvia la connessione di default definita nel file di configurazione per questo server

--help        Visualizza una descrizione ed opzioni di ssh-servers
```

### NOTA
Se i server ssh posseggono un indirizzo ip pubblico dinamico, consiglio fortemente (i due script si integrano a vicenda) di
utilizzare [current-ip](https://github.com/KeyofBlueS/current-ip) sul lato server.

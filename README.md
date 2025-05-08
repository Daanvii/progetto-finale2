#  PROGETTO DI FINE CORSO
Si vuole implementare un'infrastruttura su Azure
utilizzando Terraform che consiste in un cluster K3s ad
alta disponibilità con 3 nodi. Su questo cluster verrà
deployato un progetto Docker fornito e disponibile al
seguente indirizzo:

                              https://github.com/MrMagicalSoftware/docker-k8s/blob/
                              main/esercitazione-docker-file.md
##

 Ho creato i miei file all'interno di progetto-finale
![image](https://github.com/user-attachments/assets/488a81e6-8392-4830-adb8-b7f467b23d4f)


         terraform init -> Scarica i provider e prepara Terraform.
#
         terraform plan -> Verifica i cambiamenti prima del deploy.
#
         terraform apply -> Applica le modifiche e crea le risorse.
#
         terraform destroy -> Rimuove tutte le risorse create da Terraform
#
Una volta creata la VM e fatto l'apply è andato. 

![Screenshot 2025-05-08 065626](https://github.com/user-attachments/assets/30602280-e383-4f05-b2f3-cb4b9c4d976b)

## 

# Configurazione manuale
Procedo alla configurazione manuale
#
Mi sono spostata su powershell per avviare la vm utilizzando la chiave ssh
#

Entro nella vm dopo aver fatto il login su azure
![Screenshot 2025-05-08 092914](https://github.com/user-attachments/assets/3bf4efa3-1f6d-44e5-a6b5-bd8c3a36f586)
#
          sudo apt-get update -> Questo comando aggiorna la lista dei pacchetti disponibili per il sistema
#
          sudo apt-get install -y ca-certificates curl gnupg lsb-release -> Questo comando prepara la VM per gestire installazioni sicure e scaricare pacchetti affidabili


#
#

Installo i file app.js, package.js e Dockerfile in hello-docker
#

Ho ricevuto errori permission denied accedendo ai file di configurazione Docker config.json
Anche il comando docker images ha restituito un warning di permessi.
Ho quindi provato a risolvere il problema aggiungendo l’utente al gruppo Docker con:
#
          sudo usermod -aG docker $USER
          newgrp docker
#

![Screenshot 2025-05-08 093101](https://github.com/user-attachments/assets/532548ee-919c-4971-8722-de4e9066465d)
#
Alla fine ho impostato i permessi in modo da leggere, scrivere ed eseguire all'interno della cartella.
#
          sudo chown -R adminuser:adminuser /home/adminuser/.docker
          chmod 755 /home/adminuser/.docker

![Screenshot 2025-05-08 093116](https://github.com/user-attachments/assets/502ee7ac-f768-4b3f-b397-e2573d27985d)

#

Quando avvio il comando Sudo docker build -t hello-docker (Crea un’immagine Docker a partire da un Dockerfile) resta bloccato per più di 30 min
#
![Screenshot 2025-05-08 093123](https://github.com/user-attachments/assets/726241dc-41ca-4097-ad82-222356cb9022)
#
*che faccio??*
#
Il processo si blocca quindi verifico cosa è andato storto:
Mi assicuro che i file ci siano in hello-docker
#
![Screenshot 2025-05-08 094317](https://github.com/user-attachments/assets/da8db211-b940-42d2-a99f-a713fc3d1a16)

L'immagine appare
#
![Screenshot 2025-05-08 095215](https://github.com/user-attachments/assets/04dbd469-b100-4581-ab5b-276968565e04)

Il Dockerfile non risulta correttamente installato
#
![Screenshot 2025-05-08 100426](https://github.com/user-attachments/assets/14784c00-ced7-436c-b570-13cfcd10d5f3)

#
Faccio una pulizia utilizzando Sudo docker system prune -af (Rimuove tutti i container, volumi, reti, cache di build e immagini non utilizzate.)

#

![Screenshot 2025-05-08 103902](https://github.com/user-attachments/assets/3743845d-5512-4d18-89a1-553aa902ba28)

#
Riprovo a mandare  sudo docker build -t hello-docker .
![Screenshot 2025-05-08 104948](https://github.com/user-attachments/assets/2a332e6a-4c96-45b0-9274-fb1e9fd13575)

#
Mi autentico su Docker 
![Screenshot 2025-05-08 110637](https://github.com/user-attachments/assets/d1ccf475-6631-4bc3-b808-cb0a74a0001c)

provo a rimandare sudo docker build -t hello-docker .

il processo è bloccato.


## Faccio il destroy e ricomincio, mandando tutti i comandi su setup.sh
#
![Screenshot 2025-05-08 124102](https://github.com/user-attachments/assets/0f3b6af1-51bb-4e82-87bf-0a6c41c58351)

#
Poichè mi dà errore, invece di usare la chiave ssh per entrare nella VM utilizzo username e password 
#
![image](https://github.com/user-attachments/assets/eed094c9-698e-4491-8b3e-d4ece192c1b6)
#
          terraform init
#
          terraform plan
#
          terraform appy
#
Il codice risulta bloccarsi sempre allo stesso punto
#
![image](https://github.com/user-attachments/assets/b85e2e5c-3e98-436c-95c5-52bcc891445b)

# 

![image](https://github.com/user-attachments/assets/cf05c51d-ec19-4c35-a38b-d5d3938fc5eb)

## Come avrei concluso se tutto fosse andato a buon fine :')
#
http://<IP_PUBBLICO>:30080 sul web e controllato se ci fosse la scritta "Hello World!"
#


# RISOLUZIONE PROBLEMA!!
#
cambiare la dimensione dell'immagine, immagine troppo piccola.

                  #Elenca tutte le offerte Ubuntu disponibili
                  echo "Offerte Ubuntu disponibili:" az vm image list-offers --location westeurope --publisher Canonical -o table








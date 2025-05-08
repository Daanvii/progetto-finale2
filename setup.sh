#!/bin/bash


# Installazione pacchetti essenziali
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Crea directory per chiave GPG
sudo mkdir -p /etc/apt/keyrings

# Aggiungi la chiave GPG
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Aggiungi il repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Aggiorna APT e installa Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Avvia e abilita il servizio Docker
sudo systemctl enable --now docker

# Installa K3s
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Attendi che K3s sia completamente avviato
sleep 30

# Avvio servizio K3s
sudo systemctl enable k3s && sudo systemctl start k3s

# K3s già crea un symlink per kubectl, ma verifichiamo se esiste
sudo ln -s /usr/local/bin/k3s /usr/local/bin/kubectl

# Modifica i permessi del file kubeconfig
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Salva la versione di Kubernetes
export KUBEVERSION=$(kubectl version)

# Creazione struttura del progetto Node.js
mkdir -p hello-docker
cd hello-docker

# Crea il file app.js
cat <<EOF > app.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello, World!');
});

app.listen(port, '0.0.0.0', () => {
    console.log(\`App listening at http://0.0.0.0:\${port}\`);
});
EOF

# Crea il file package.json
cat <<EOF > package.json
{
  "name": "hello-docker",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF

# Installa npm e dipendenze
sudo apt install -y npm
sudo npm install

# Crea il Dockerfile
cat <<EOF > Dockerfile
FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# Costruisci l'immagine Docker
sudo docker build -t hello-docker:latest .

# Salva l'immagine come file tar per importarla in K3s
sudo docker save hello-docker:latest -o hello-docker.tar

# Importa l'immagine nel registro interno di K3s
sudo k3s ctr --namespace=k8s.io images import hello-docker.tar

# Torna alla directory principale
cd ..

# Creazione del file YAML per il Deployment dei pod
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
  labels:
    app: nodejs_app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs_app
  template:
    metadata:
      labels:
        app: nodejs_app
    spec:
      containers:
      - name: nodejs-app
        image: docker.io/library/hello-docker:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
EOF

# Creazione del file YAML per il Service
cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app-service
spec:
  selector:
    app: nodejs_app
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30080
  type: NodePort
EOF

# Applicazione file YAML per il deployment
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
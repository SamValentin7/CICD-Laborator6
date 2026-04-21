# Docker Hub Setup Guide - Laborator6

## Imagini Docker Hub

Proiectul include două imagini publice pe Docker Hub:

- **Web App:** [samvalentin/laborator6-web](https://hub.docker.com/repository/docker/samvalentin/laborator6-web)
- **MySQL DB:** [samvalentin/laborator6-mysql](https://hub.docker.com/repository/docker/samvalentin/laborator6-mysql)

---

## Opțiunea 1: Docker Compose (Recomandat)

1. **Clonare repository:**
```bash
git clone https://github.com/SamValentin7/CICD-Laborator6.git
cd CICD-Laborator6
```

2. **Configurare mediu:**
```bash
cp .env.example .env
```

3. **Construire și pornire servicii:**
```bash
docker-compose up --build -d
```

4. **Verificare:**
```bash
docker-compose ps
```

5. **Accesare aplicație:**
- **URL:** http://localhost:3000
- **API:** http://localhost:3000/api/items

6. **Oprire servicii:**
```bash
docker-compose down
```

---

## Opțiunea 2: Imagini Docker Individuale (cu rețea)

### Build imagini:
```bash
docker build -t samvalentin/laborator6-web -f Dockerfile .
docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .
```

### Creare rețea:
```bash
docker network create laborator6-network
```

### Pornire database:
```bash
docker run -d \
  --name laborator6-mysql \
  --network laborator6-network \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=laborator6 \
  -v mysql_data:/var/lib/mysql \
  samvalentin/laborator6-mysql:latest
```

### Așteptare 15 secunde pentru inițializarea bazei de date

### Pornire aplicație:
```bash
docker run -d \
  --name laborator6-web \
  --network laborator6-network \
  -p 3000:3000 \
  -e DB_HOST=laborator6-mysql \
  -e DB_NAME=laborator6 \
  -e DB_USER=root \
  -e DB_PASSWORD=password \
  samvalentin/laborator6-web:latest
```

### Accesare aplicație: http://localhost:3000

### Oprire:
```bash
docker stop laborator6-web laborator6-mysql
docker rm laborator6-web laborator6-mysql
docker network rm laborator6-network
docker volume rm mysql_data
```

---

## Utilizare imagini din Docker Hub (pe altă mașină)

### 1. Pull imagini:
```bash
docker pull samvalentin/laborator6-web:latest
docker pull samvalentin/laborator6-mysql:latest
```

### 2. Creare rețea:
```bash
docker network create laborator6-network
```

### 3. Pornire database:
```bash
docker run -d \
  --name laborator6-mysql \
  --network laborator6-network \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=laborator6 \
  -v mysql_data:/var/lib/mysql \
  samvalentin/laborator6-mysql:latest
```

### 4. Așteptare 15 secunde

### 5. Pornire aplicație:
```bash
docker run -d \
  --name laborator6-web \
  --network laborator6-network \
  -p 3000:3000 \
  -e DB_HOST=laborator6-mysql \
  -e DB_NAME=laborator6 \
  -e DB_USER=root \
  -e DB_PASSWORD=password \
  samvalentin/laborator6-web:latest
```

### 6. Testare:
```bash
curl http://localhost:3000/health
```

---

## Comenzi Docker Utile

### Construire imagini:
```bash
docker build -t samvalentin/laborator6-web -f Dockerfile .
docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .
```

### Rulare cu rețea:
```bash
docker network create laborator6-network

docker run -d --name laborator6-mysql --network laborator6-network -p 3306:3306 -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=laborator6 samvalentin/laborator6-mysql:latest

sleep 15

docker run -d --name laborator6-web --network laborator6-network -p 3000:3000 -e DB_HOST=laborator6-mysql -e DB_NAME=laborator6 -e DB_USER=root -e DB_PASSWORD=password samvalentin/laborator6-web:latest
```

### Oprire:
```bash
docker stop laborator6-web laborator6-mysql
docker rm laborator6-web laborator6-mysql
docker network rm laborator6-network
docker volume rm mysql_data
```

### Push pe Docker Hub:
```bash
docker login
docker push samvalentin/laborator6-web:latest
docker push samvalentin/laborator6-mysql:latest
```

### Pull de pe Docker Hub:
```bash
docker pull samvalentin/laborator6-web:latest
docker pull samvalentin/laborator6-mysql:latest
```

---

## GitHub Actions

Workflow-ul `.github/workflows/deploy.yml` build-ează automat ambele imagini și le push pe Docker Hub la fiecare push pe branch-ul main.

---

## Note

- **2 imagini separate:** Web app + MySQL database
- **Rețea:** Containerele comunică prin rețeaua Docker `laborator6-network`
- **Persistență:** Datele MySQL sunt păstrate în volume `mysql_data`
- **Porturi:** Web=3000, MySQL=3306
- **DB_HOST:** Trebuie să fie `laborator6-mysql` când se folosește rețeaua custom

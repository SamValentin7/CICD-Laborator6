# Laborator6 - CI/CD cu Docker, Docker Compose și GitHub Actions

## Lucrare de Laborator - Automatizarea procesului de livrare a aplicațiilor

### Obiective
Realizarea unui proces complet de dezvoltare, containerizare, publicare și deploy automatizat al unei aplicații web simple utilizând Docker, Docker Compose și GitHub Actions.

---

## Sarcini de realizat

### 1. Aplicația web cu MySQL

**Fișiere create:**
- `server.js` - Aplicația Express.js cu REST API
- `public/index.html` - Interfața web frontend
- `init.sql` - Script de inițializare bază de date
- `package.json` - Dependențe Node.js

**Endpoint-uri API:**
- `GET /api/items` - Obține toate elementele
- `POST /api/items` - Adaugă un element nou
- `DELETE /api/items/:id` - Șterge un element
- `GET /health` - Verificare stare aplicație

---

### 2. Dockerfile pentru aplicația web

**Fișier:** `Dockerfile`

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY . .

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --only=production; else npm install --only=production; fi
COPY --from=builder /app .
RUN mkdir -p public
EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if(r.statusCode!==200) throw new Error(r.statusCode)})"
CMD ["node", "server.js"]
```

---

### 3. Dockerfile pentru baza de date MySQL

**Fișier:** `Dockerfile.db`

```dockerfile
FROM mysql:8.0
ENV MYSQL_ROOT_PASSWORD=password
ENV MYSQL_DATABASE=laborator6
COPY init.sql /docker-entrypoint-initdb.d/
EXPOSE 3306
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" || exit 1
```

---

### 4. docker-compose.yml

**Fișier:** `docker-compose.yml`

```yaml
version: '3.8'

services:
  mysql:
    build:
      context: .
      dockerfile: Dockerfile.db
    container_name: laborator6-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD:-password}
      MYSQL_DATABASE: ${DB_NAME:-laborator6}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - myapp-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: laborator6-web
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: ${NODE_ENV:-production}
      PORT: 3000
      DB_HOST: mysql
      DB_USER: root
      DB_PASSWORD: ${DB_PASSWORD:-password}
      DB_NAME: ${DB_NAME:-laborator6}
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - myapp-network
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/health', (r) => {if(r.statusCode!==200) throw new Error(r.statusCode)})"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s

volumes:
  mysql_data:

networks:
  myapp-network:
    driver: bridge
```

---

## Rularea proiectului

### Opțiunea 1: Docker Compose (Recomandat)

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

### Opțiunea 2: Imagini Docker Individuale (cu rețea)

1. **Build imagini:**
```bash
docker build -t samvalentin/laborator6-web -f Dockerfile .
docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .
```

2. **Creare rețea:**
```bash
docker network create laborator6-network
```

3. **Pornire database:**
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

4. **Așteptare 15 secunde** pentru inițializarea bazei de date

5. **Pornire aplicație:**
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

6. **Accesare aplicație:** http://localhost:3000

7. **Oprire:**
```bash
docker stop laborator6-web laborator6-mysql
docker rm laborator6-web laborator6-mysql
docker network rm laborator6-network
docker volume rm mysql_data
```

---

## Imagini Docker Hub

Proiectul include două imagini publice pe Docker Hub:

- **Web App:** [samvalentin/laborator6-web](https://hub.docker.com/repository/docker/samvalentin/laborator6-web)
- **MySQL DB:** [samvalentin/laborator6-mysql](https://hub.docker.com/repository/docker/samvalentin/laborator6-mysql)

### Utilizare imagini din Docker Hub:

```bash
# Database
docker run -d \
  --name laborator6-mysql \
  --network laborator6-network \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=laborator6 \
  -v mysql_data:/var/lib/mysql \
  samvalentin/laborator6-mysql:latest

# Flask app (wait 15 seconds)
sleep 15

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

---

## Comenzi Docker Utile

### Construire Imagini
```bash
docker build -t samvalentin/laborator6-web -f Dockerfile .
docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .
```

### Rulare Containere cu Rețea
```bash
docker network create laborator6-network

docker run -d --name laborator6-mysql --network laborator6-network -p 3306:3306 -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=laborator6 samvalentin/laborator6-mysql:latest

sleep 15

docker run -d --name laborator6-web --network laborator6-network -p 3000:3000 -e DB_HOST=laborator6-mysql -e DB_NAME=laborator6 -e DB_USER=root -e DB_PASSWORD=password samvalentin/laborator6-web:latest
```

### Oprire
```bash
docker stop laborator6-web laborator6-mysql
docker rm laborator6-web laborator6-mysql
docker network rm laborator6-network
docker volume rm mysql_data
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

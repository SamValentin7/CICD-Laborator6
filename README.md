# Laborator6 - CI/CD cu Docker, Docker Compose și GitHub Actions

## Lucrare de Laborator - Automatizarea procesului de livrare a aplicațiilor

### Obiective
Realizarea unui proces complet de dezvoltare, containerizare, publicare și deploy automatizat al unei aplicații web simple utilizând Docker, Docker Compose și GitHub Actions.

---

## Sarcini de realizat

### 1. Creați o aplicație web legată cu o bază de date MySQL

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

### 2. Creați un fișier Dockerfile pentru containerizarea aplicației

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

**Explicație:**
- `FROM node:18-alpine` - Imagine de bază ușoară Node.js
- `WORKDIR /app` - Setează directorul de lucru
- `COPY package*.json ./` - Copiază fișierele de dependențe
- `RUN npm ci` - Instalează dependențele
- Multi-stage build pentru optimizare
- `HEALTHCHECK` - Verificare automată a stării
- `EXPOSE 3000` - Expune portul 3000

---

### 3. Creați un fișier docker-compose.yml pentru gestionarea serviciilor

**Fișier:** `docker-compose.yml`

---

### 4. Construiți și rulați containerul local folosind Docker Compose

**Pas 1:** Verificăți instalarea Docker și Docker Compose

```bash
# Verifică Docker
docker --version
docker-compose --version
```

**Pas 2:** Creare fișier `.env` din template

```bash
cp .env.example .env
# Editați .env dacă este necesar (opțional)
```

**Pas 3:** Pornire servicii în mod detached (background)

```bash
docker-compose up -d
```
or
```bash
docker-compose up --build
```

**Pas 4:** Verificare status containere

```bash
docker-compose ps
```

**Pas 5:** Vizualizare loguri

```bash
# Loguri ambele servicii
docker-compose logs -f

# Loguri doar pentru aplicație
docker-compose logs -f web

# Loguri doar pentru MySQL
docker-compose logs -f mysql
```

**Pas 6:** Testare aplicație

```bash
# Verificare health endpoint
curl http://localhost:3000/health

# Expected: {"status":"OK","timestamp":"..."}
```

**Pas 7:** Accesare interfață web

Deschideți browserul la: `http://localhost:3000`

**Pas 8:** Oprire servicii

```bash
# Oprire containere (păstrează volumele cu date)
docker-compose down

# Oprire containere + ștergere volume (toate datele se pierd)
docker-compose down -v
```

---

### 5. Construiți imaginea aplicației folosind Docker

**Pas 1:** Construire imagine cu Docker direct (fără Docker Compose)

```bash
# Build cu tag specific
docker build -t laborator6:latest .

```

**Pas 2:** Listare imagini Docker

```bash
docker images
```

**Pas 3:** Rulare container din imagine

```bash
# Rulare simplă
docker run -p 3000:3000 laborator6

# Rulare cu variabile de mediu
docker run -p 3000:3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_NAME=laborator6 \
  -e DB_USER=root \
  -e DB_PASSWORD=password \
  laborator6

# Rulare în background
docker run -d -p 3000:3000 --name myapp laborator6
```

**Pas 4:** Verificare container rulare

```bash
# Listare containere active
docker ps

# Verificare loguri
docker logs laborator6-web

# Testare endpoint
curl http://localhost:3000/health
```

**Pas 5:** Oprire container

```bash
docker stop laborator6-web
docker rm laborator6-web
```

---

### 6. Încărcați imaginea Docker creată în contul personal Docker Hub

**Pas 1:** Autentificare Docker Hub si Image Build

```bash
docker login

docker build -t cicd-laborator6-web:latest .
```

**Pas 2:** Tagging imagine pentru Docker Hub

```bash
# Format: dockerhub-username/image-name:tag
docker tag cicd-laborator6-web:latest samvalentin/cicd-laborator6-web:latest

```

**Verificare tag-uri:**
```bash
docker images
```

**Pas 3:** Push către Docker Hub

```bash
# Push tag latest
docker push samvalentin/cicd-laborator6-web:latest

```

**Pas 4:** Verificare pe Docker Hub

1. Accesați https://hub.docker.com
2. Logați-vă
3. Vizualizați repository-ul: `samvalentin/laborator6`
4. Ar trebui să vedeți imaginea `latest` (și eventual alte tag-uri)

---

### 7. Inițializați un repozitoriu Git și urcați proiectul pe GitHub (Laborator6)

**Pas 1:** Inițializare repository Git

```bash
# Inițializare Git
git init

# Adăugare fișiere
git add .

# Commit inițial
git commit -m "Initial commit - Laborator6 CI/CD application"
```

**Pas 2:** Creare repository pe GitHub

1. Accesați https://github.com
2. Click "New repository"
3. Nume repository: `Laborator6`
4. Descriere: `CI/CD project with Docker and GitHub Actions`
5. Selectați **Public** sau **Private**
6. **NU** selectați "Initialize this repository with a README"
7. Click "Create repository"

**Pas 3:** Conectare remote GitHub

```bash
# Adăugare remote (înlocuiți cu username-ul vostru)
git remote add origin https://github.com/YOUR_USERNAME/Laborator6.git

# Verificare remote
git remote -v
```

**Pas 4:** Push primul commit

```bash
# Push pe branch-ul main
git branch -M main
git push -u origin main
```

**Pas 5:** Verificare GitHub

1. Refresh pagina GitHub
2. Ar trebui să vedeți toate fișierele proiectului

---

### 8. Creați un fișier workflow GitHub Actions în `.github/workflows/deploy.yml` pentru automatizarea deploy-ului

**Fișier deja creat:** `.github/workflows/deploy.yml`

**Structura directoarelor:**
```
.github/
└── workflows/
    └── deploy.yml    # Workflow GitHub Actions
```

---

### 9. Adăugați secretele de autentificare în Docker Hub

**Pas 1:** Creare Docker Hub Access Token

1. Logați-vă pe https://hub.docker.com
2. Click pe avatar → **Account Settings**
3. Secțiunea **Security**
4. Click **New Access Token**
5. Completați:
   - **Description**: `laborator6`
   - **Access**: **Read & Write**
6. Click **Create**
7. **IMPORTANT**: Copiați token-ul imediat (se afișează o singură dată!)

**Pas 2:** Adăugare secrete în GitHub

1. Accesați repository-ul GitHub: `https://github.com/YOUR_USERNAME/Laborator6`
2. Click **Settings** (roata dinților)
3. Stânga: **Secrets and variables** → **Actions**
4. Click **New repository secret**

**Secret 1 - Docker Hub Username:**
```
Name: DOCKERHUB_USERNAME
Value: your-dockerhub-username
```

**Secret 2 - Docker Hub Token:**
```
Name: DOCKERHUB_TOKEN
Value: token-ul-copiat-de-la-Docker-Hub
```

**Pas 3:** Verificare secrete

În pagina GitHub Secrets, ar trebui să vedeți:
- ✅ DOCKERHUB_USERNAME
- ✅ DOCKERHUB_TOKEN

---

### 10. Declanșați execuția workflow-ului GitHub Actions printr-un push în branch-ul main

**Pas 1:** Adăugare fișierele workflow la Git

```bash
# Verificare status
git status

# Adăugare fișiere noi
git add .github/workflows/deploy.yml
git add DOCKER_HUB_SETUP.md

# Commit
git commit -m "Add GitHub Actions deploy workflow and Docker Hub setup guide"
```

**Pas 2:** Push către GitHub

```bash
git push origin main
```

**Pas 3:** Monitorizare execuție workflow

1. Accesați repository-ul GitHub
2. Click tab **Actions**
3. Ar trebui să vedeți workflow-ul "Deploy to Production" în execuție
4. Click pe workflow pentru detalii

**Stări posibile:**
- 🟡 **In progress** - În curs de execuție
- ✅ **Success** - Finalizat cu succes
- ❌ **Failed** - Eroare (verificați logurile)

**Pas 4:** Verificare etape

În pagina workflow, verificați:
- ✅ **build-and-push** job:
  - Checkout code
  - Set up Docker Buildx
  - Log in to Docker Hub (ar trebui să fie ✅)
  - Extract metadata
  - Build and push Docker image (✅)

- ✅ **deploy** job (dacă a fost configurat):
  - Checkout deployment scripts
  - Deploy to server via SSH (sau mesaj de placeholder)

**Pas 5:** View job logs

Click pe fiecare job → **Jobs** → Click pe numele step-ului pentru a vedea logurile detaliate.

---

### 11. Verificați dacă imaginea a fost încărcată corect pe Docker Hub

**Pas 1:** Accesare Docker Hub

1. Logați-vă pe https://hub.docker.com
2. Click pe profil → **Dashboard**
3. Căutați repository-ul: `samvalentin/laborator6`

**Pas 2:** Verificare imagini/tag-uri

În pagina repository-ului ar trebui să vedeți:
- **Tags** tab
- Tag-uri disponibile:
  - `latest` (dacă ați făcut push pe main)

**Pas 3:** Verificare detaliile imaginii

Click pe tag-ul `latest`:
- **Layers** - Straturi imagine
- **Size** - Dimensiune (ar trebui ~180MB)
- **Created** - Data creării
- **Digest** - SHA256 hash

**Pas 4:** Testare pull din Docker Hub

```bash
# Pull imagine de pe Docker Hub
docker pull samvalentin/laborator6:latest

```

**Pas 5:** Rulare test container

```bash
# Rulare container din imaginea din Docker Hub
docker run -d -p 3000:3000 --name test-laborator6 samvalentin/laborator6:latest

# Verificare
docker ps | grep laborator6

# Testare health
curl http://localhost:3000/health

# Oprire
docker stop test-laborator6
docker rm test-laborator6
```

---

### 12. Realizați rularea imaginii din Docker Hub pe un server extern utilizând comenzi Docker

**Pas 2:** Verificare Docker

```bash
# Verificare instalare Docker
docker --version
docker-compose --version  # dacă folosiți docker-compose

```

**Pas 3:** Autentificare Docker Hub 

```bash
# Login pe server (va cere username/parola sau token)
docker login

# Sau folosiți token (recomandat)
docker login -u yourusername -p your-token
```

**Pas 4:** Pull imagine de pe Docker Hub

```bash
# Pull imaginea latest
docker pull samvalentin/cicd-laborator6-web:latest

# Verificare
docker images
```

**Pas 5:** Rulare container pe server

**Opțiune A - Docker run simplu:**
```bash
docker run -d \
  --name laborator6-app \
  -p 3000:3000 \
  --restart unless-stopped \
  -e DB_HOST=localhost \
  -e DB_NAME=laborator6 \
  -e DB_USER=root \
  -e DB_PASSWORD=your-secure-password \
  samvalentin/laborator6:latest
```

**Opțiune B - Docker Compose (dacă aveți docker-compose.yml):**

Pe server, creați `docker-compose.yml`:

Apoi:
```bash
docker-compose up -d
```

---

## Comenzi Rapide - Rezumat


### Docker Compose
```bash
# Pornire
docker-compose up -d

# Oprire
docker-compose down

# Loguri
docker-compose logs -f

# Rebuild
docker-compose build --no-cache
docker-compose up -d
```

### Git & GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/USERNAME/Laborator6.git
git push -u origin main
```

---

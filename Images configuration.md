# CICD6 Docker Configuration

## Opțiunea 1: Docker Compose

1. **Clonare repository:**
   ```bash
   git clone https://github.com/SamValentin7/CICD-Laborator6.git
   cd CICD-Laborator6
   ```

2. **Configurare env:**
   ```bash
   cp .env.example .env
   ```

3. **Construire și pornire servicii:**
   ```bash
   docker-compose up --build -d
   ```

4. **Accesare aplicație:**
   - **URL:** http://localhost:3000

5. **Oprire servicii:**
   ```bash
   docker-compose down
   ```

6. **Remove local image and containers:**
   ```bash
   docker stop laborator6-web laborator6-mysql
   docker rm laborator6-web laborator6-mysql
   docker rmi samvalentin/laborator6-web samvalentin/laborator6-mysql
   docker rmi cicd-laborator6-web cicd-laborator6-mysql

   ```


---

## Step 2: Build BOTH Docker Images

1. **Build the web app image:**
   ```bash
   docker build -t samvalentin/laborator6-web -f Dockerfile .
   ```

2. **Build the database image:**
   ```bash
   docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .
   ```

3. **Verify both images exist:**
   ```bash
   docker images
   ```
   You should see both images:
   - `samvalentin/laborator6-web`
   - `samvalentin/laborator6-mysql`

---

## Step 3: Test BOTH Images Locally

1. **Create Docker network:**
   ```bash
   docker network create laborator6-network
   ```

2. **Run the database container:**
   ```bash
   docker run -d --name laborator6-mysql --network laborator6-network -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=laborator6 -v mysql_data:/var/lib/mysql samvalentin/laborator6-mysql:latest
   ```

3. **Wait for database to be ready (15 seconds):**
   ```bash
   sleep 15
   ```
   Wait until the database is ready to accept connections

4. **Run the web app container:**
   ```bash
   docker run -d --name laborator6-web --network laborator6-network -p 3000:3000 -e DB_HOST=laborator6-mysql -e DB_NAME=laborator6 -e DB_USER=root -e DB_PASSWORD=password samvalentin/laborator6-web:latest
   ```

5. **Test the application:**
   - Open browser: http://localhost:3000
   - Verify it works

6. **Stop both containers:**
   ```bash
   docker stop laborator6-web laborator6-mysql
   docker rm laborator6-web laborator6-mysql
   ```

---

## Step 4: Push BOTH Images to Docker Hub

1. **Login to Docker Hub:**
   ```bash
   docker login
   ```
   Enter your Docker Hub username and password

2. **Push the web app image:**
   ```bash
   docker push samvalentin/laborator6-web:latest
   ```

3. **Push the database image:**
   ```bash
   docker push samvalentin/laborator6-mysql:latest
   ```

4. **Verify on Docker Hub:**
   - Go to https://hub.docker.com
   - Check your repositories
   - Verify both images appear

---

## Step 5: Test Docker Hub Images

1. **Remove local images and containers:**
   ```bash
   docker stop laborator6-web laborator6-mysql
   docker rm laborator6-web laborator6-mysql
   docker rmi samvalentin/laborator6-web samvalentin/laborator6-mysql
   ```

2. **Pull both images from Docker Hub:**
   ```bash
   docker pull samvalentin/laborator6-web:latest
   docker pull samvalentin/laborator6-mysql:latest
   ```

3. **Run from Docker Hub:**
   ```bash
   docker network create laborator6-network

   docker run -d --name laborator6-mysql --network laborator6-network -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=laborator6 -v mysql_data:/var/lib/mysql samvalentin/laborator6-mysql:latest

   sleep 15

   docker run -d --name laborator6-web --network laborator6-network -p 3000:3000 -e DB_HOST=laborator6-mysql -e DB_NAME=laborator6 -e DB_USER=root -e DB_PASSWORD=password samvalentin/laborator6-web:latest
   ```

4. **Test the application:**
   - Open browser: http://localhost:3000
   - Verify it works

5. **Cleanup:**
   ```bash
   docker stop laborator6-web laborator6-mysql
   docker rm laborator6-web laborator6-mysql
   ```

---

## Step 6: Test with Docker Compose (Alternative)

1. **Test with docker-compose:**
   ```bash
   docker-compose up --build -d
   ```
   - Test at: http://localhost:3000
   - Stop: `docker-compose down`

---

## Commands Summary

```bash
# Build both images
docker build -t samvalentin/laborator6-web -f Dockerfile .
docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .

# Create network
docker network create laborator6-network

# Run both containers
docker run -d --name laborator6-mysql --network laborator6-network -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=laborator6 -v mysql_data:/var/lib/mysql samvalentin/laborator6-mysql:latest
docker run -d --name laborator6-web --network laborator6-network -p 3000:3000 -e DB_HOST=laborator6-mysql -e DB_NAME=laborator6 -e DB_USER=root -e DB_PASSWORD=password samvalentin/laborator6-web:latest

# Push to Docker Hub
docker push samvalentin/laborator6-web:latest
docker push samvalentin/laborator6-mysql:latest

# Cleanup
docker stop laborator6-web laborator6-mysql
docker rm laborator6-web laborator6-mysql
docker network rm laborator6-network
docker volume rm mysql_data

docker rmi samvalentin/laborator6-web samvalentin/laborator6-mysql
```
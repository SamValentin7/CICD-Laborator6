# Comenzi Rapide - Laborator6

## Pornire local (Docker Compose)
```bash
cp .env.example .env
docker-compose up --build -d
```

## Oprire
```bash
docker-compose down
```

## Build imagini
```bash
docker build -t samvalentin/laborator6-web -f Dockerfile .
docker build -t samvalentin/laborator6-mysql -f Dockerfile.db .
```

## Push pe Docker Hub
```bash
docker login
docker push samvalentin/laborator6-web:latest
docker push samvalentin/laborator6-mysql:latest
```

## Pull pe altă mașină
```bash
docker login
docker pull samvalentin/laborator6-web:latest
docker pull samvalentin/laborator6-mysql:latest
```

## Rulare cu rețea (pe altă mașină)
```bash
docker network create laborator6-network

docker run -d --name laborator6-mysql --network laborator6-network -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=laborator6 -v mysql_data:/var/lib/mysql samvalentin/laborator6-mysql:latest

sleep 15

docker run -d --name laborator6-web --network laborator6-network -p 3000:3000 -e DB_HOST=laborator6-mysql -e DB_NAME=laborator6 -e DB_USER=root -e DB_PASSWORD=password samvalentin/laborator6-web:latest
```

## Oprire containere și rețea
```bash
docker stop laborator6-web laborator6-mysql
docker rm laborator6-web laborator6-mysql
docker network rm laborator6-network
docker volume rm mysql_data
```

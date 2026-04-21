# Comenzi Ștergere Docker - Laborator6

## Oprire containere (păstrează datele)
```bash
docker-compose down
```

## Oprire + ștergere volume (toate datele se pierd)
```bash
docker-compose down -v
```

## Ștergere completă TOATE resursele

### Opțiunea 1: Docker Compose
```bash
docker-compose down --rmi all -v
```

### Opțiune 2: Ștergere manuală

**Oprire containere:**
```bash
docker stop laborator6-mysql laborator6-web
```

**Ștergere containere:**
```bash
docker rm laborator6-mysql laborator6-web
# SAU forțare
docker rm -f laborator6-mysql laborator6-web
```

**Ștergere imagini:**
```bash
docker rmi samvalentin/laborator6-web:latest
docker rmi samvalentin/laborator6-mysql:latest
```

**Ștergere volume (PIERDERE DATE!):**
```bash
docker volume rm mysql_data
# SAU
docker volume rm laborator6_mysql_data
```

**Ștergere rețea:**
```bash
docker network rm laborator6-network
```

## Curățare completă toate resursele laborator6
```bash
docker-compose down --rmi all -v && docker system prune -f
```

## Verificare ștergere
```bash
docker ps -a | grep laborator6
docker images | grep laborator6
docker volume ls | grep laborator6
docker network ls | grep laborator6
```

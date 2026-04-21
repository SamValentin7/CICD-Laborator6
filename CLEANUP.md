# Comenzi Ștergere Docker - Laborator6

## Oprire containere
```bash
docker-compose down
```

## Ștergere containere + imagini + volume + rețea (COMPLET)
```bash
docker-compose down --rmi all -v
```

## Ștergere manuală (alternativă)

### Oprire containere
```bash
docker stop laborator6-mysql laborator6-web
```

### Ștergere containere
```bash
docker rm laborator6-mysql laborator6-web
# SAU forțare
docker rm -f laborator6-mysql laborator6-web
```

### Ștergere imagini
```bash
docker rmi cicd-laborator6-web:latest
docker rmi mysql:8.0  

docker rmi samvalentin/cicd-laborator6-web:latest

```

### Ștergere volume (PIERDERE DATE!)
```bash
docker volume rm laborator6_mysql_data
```

### Ștergere rețea
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

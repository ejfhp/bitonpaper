# Local build

To compile and run BOP on a local machine you need to have docker installed.

From the root of the project:

1 - Build the Docker image from scratch (this can take a while).
```
docker build --tag=bop --build-arg ver='local' -f ./go/k8s/bitnonpaper/main/Dockerfile .
```

2 - Run the generated Docker image on port 8080.
```
docker run  -p8080:8080 bop:latest
```

3 - Open your browser and go to 'localhost:8080'.
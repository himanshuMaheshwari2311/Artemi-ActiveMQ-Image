# Artemi-ActiveMQ-Image
This repository contains Dockerfile to create an Artemis ActiveMQ along with some performance tuning

### Getting or Building the broker instance
If you want to customize the build of the instance, then you should clone the repo and build it locally or you can pull the image from the docker hub:
 ```
 docker pull stark9190/artemis-activemq
 ```
 This will fetch the latest build to your local image registry
 To build the broker image, clone and run docker build:
```
https://github.com/himanshuMaheshwari2311/Artemis-ActiveMQ-Image.git

cd Artemis-ActiveMQ-Image

docker build -t stark9190/artemis-activemq .
```

### Running the broker instance
To run the broker image in your docker environment simply run:
```
docker run -it -p 8161:8161 -p 61616:61616 stark/artemis-activemq
```
After this command runs you can see the Artemis Active MQ console at ``` http://127.0.0.1:8161/console/ ```
Note: If you are not using a native docker installation, i.e running through a VM like docker quickstart terminal for windows run the following command to get ip of your docker machine:
```docker-machine ip default```
You can see the console at ``` http://<docker-machine-ip>:8161/console/ ```

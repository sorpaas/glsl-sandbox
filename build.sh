#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONGO_DIR="$DIR/.mongo"
CLOUDINARY_URL=your cloudinary url
GLSL_PORT=4567

docker start glsl-mongo > /dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "Glsl Mongo does not exist, creating one ..."
    docker run -v $MONGO_DIR:/data/db --name glsl-mongo -d mongo
fi
sleep 10

if [ ! -f $DIR/.docker-built ]
then
    echo "Building Glsl Web Application ..."
    docker build --tag=sorpaas/glsl $DIR
    touch $DIR/.docker-built
fi

docker start glsl-web > /dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "Glsl Web does not exist, creating one ..."
    docker run -e MONGOHQ_URL="mongodb://mongo/glsl" -e CLOUDINARY_URL=$CLOUDINARY_URL -v $DIR:/app --publish=127.0.0.1:4567:$GLSL_PORT -d --link=glsl-mongo:mongo --name=glsl-web sorpaas/glsl
fi

echo
echo "Glsl started successfully. Now you can go to http://localhost:$GLSL_PORT and start reading."

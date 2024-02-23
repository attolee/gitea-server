CONTAINER_ID=$(docker ps -qf "name=^gitea$")
docker exec -u git -it -w '/tmp' $CONTAINER_ID bash -c 'rm *.zip'
docker exec -u git -it -w '/tmp' $CONTAINER_ID bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini'
docker cp $CONTAINER_ID:/tmp/ .
if [ -d "./backup" ]; then
    mkdir -p ./backup
fi
mv ./tmp/*.zip ./backup
rm -rdf ./tmp
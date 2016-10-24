REPO="c2corg/discourse"

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Not building docker images out of Pull Requests"
  exit 0
fi

if [ "$TRAVIS_BRANCH" = "master" ]; then
  TAG=latest
elif [ ! -z "$TRAVIS_TAG" ]; then
  TAG=${TRAVIS_TAG}
elif [ ! -z "$TRAVIS_BRANCH" ]; then
  TAG=${TRAVIS_BRANCH}
else
  echo "Don't know how to build image"
  exit 1
fi


#echo "Preparing PostgreSQL"
#echo "create user \"discourse\" superuser with password 'discourse;'" | psql -U postgres
#sudo -u postgres createuser --superuser discourse
#cat "host all all 0.0.0.0/0 trust" >> /var/lib/postgresql/9.4/main/pg_hba.conf
#sudo service postgresql restart


echo "Starting PostgreSQL and redis"
docker-compose -f docker-stuff/compositions/travis/docker-compose.yml up --build -d
docker-compose -f docker-stuff/compositions/travis/docker-compose.yml run wait


echo "Building image '${REPO}:${TAG}'"

sudo mkdir /var/discourse
sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse

sudo cp ./samples/c2corgv6.yml /var/discourse/containers/

cd /var/discourse
sudo ./launcher bootstrap c2corgv6

sudo docker tag local_discourse/c2corgv6 ${REPO}:${TAG}

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

echo "Starting PostgreSQL and redis"
docker-compose -f docker-stuff/compositions/travis/docker-compose.yml up --build -d
docker-compose -f docker-stuff/compositions/travis/docker-compose.yml run wait

echo "Bootstraping discourse"
sudo mkdir /var/discourse
sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse
sudo cp ./containers/c2corg_discourse.yml /var/discourse/containers/
cd /var/discourse
sudo ./launcher bootstrap c2corg_discourse

echo "Building image '${REPO}:${TAG}'"
docker build -t "${REPO}:${TRAVIS_BRANCH}" .

exit 0


/usr/bin/docker run -d \
--restart=always \
-e LANG=en_US.UTF-8 \
-e RAILS_ENV=production \
-e UNICORN_WORKERS=2 \
-e UNICORN_SIDEKIQS=1 \
-e RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
-e RUBY_GC_HEAP_GROWTH_MAX_SLOTS=40000 \
-e RUBY_GC_HEAP_INIT_SLOTS=400000 \
-e RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=1.5 \
-e DISCOURSE_DB_SOCKET= \
-e DISCOURSE_DB_HOST=159.100.248.204 \
-e DISCOURSE_DB_PORT= \
-e DISCOURSE_DEVELOPER_EMAILS=marc.fournier@camptocamp.com,alexandre.saunier@camptocamp.com,tobias.sauerwein@camptocamp.com,guillaume.beraudo@camptocamp.com,arnaud.morvan@camptocamp.com \
-e DISCOURSE_HOSTNAME=forum.camptocamp.org \
-e DISCOURSE_SMTP_ADDRESS=smtp.sparkpostmail.com \
-e DISCOURSE_SMTP_PORT=587 \
-e DISCOURSE_SMTP_USER_NAME=SMTP_Injection \
-e DISCOURSE_SMTP_PASSWORD=3fb2516f3ea0499add2dcdfbecc4ad44da34ea3d \
-e DISCOURSE_REDIS_HOST=159.100.250.102 \
-e PGHOST=159.100.248.204 \
-e PGUSER=discourse \
-e PGPASSWORD=yeEbQZbzj4K9s6je \
-e PGDATABASE=discourse \
-h docker-discourse-prod-0e95f293-0-c2corg-discourse \
-e DOCKER_HOST_IP=172.17.0.1 \
--name c2corg_discourse \
-t \
-p 1234:80 \
-v /var/discourse/shared/standalone:/shared \
-v /var/discourse/shared/standalone/log/var-log:/var/log \
--mac-address 02:07:ec:2c:4b:3f \
local_discourse/c2corg_discourse \
/sbin/boot

# otrs-docker
OTRS5 based on Debian Stretch

To install OTRS, create a mysql or postgresql database with credentials, then for the install procedure, run
```bash
docker run --it --rm -v $(pwd)/data:/data -p 8080:80 \
  -e DATABASE_TYPE=postgres \
  -e DATABASE_HOST=postgres \
  -e DATABASE_NAME=otrs \
  -e DATABASE_USER=otrs \
  -e DATABASE_PASSWORD=otrs \
  rkojedzinszky/otrs-docker
```

Alternatively you can use the docker-compose sample script.

Open http://localhost:8080/otrs/install.pl, and follow the install procedure. When at the DB settings, you should choose install in existing DB, and fill in DB
credentials again. After the install is done, just restart the container to let the OTRS daemon start up right.

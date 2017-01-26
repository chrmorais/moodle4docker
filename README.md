# Introduction
Docker compose to setup a full Moodle 3.2 local environment.

# Installation
Clone or download the repo:

 
```bash
$ wget https://github.com/pauloamgomes/moodle4docker/archive/v0.1.zip
$ unzip v0.1.zip
$ cd moodle4docker-0.1/docker-compose
```

Start the [docker-sync](http://docker-sync.io) container:


```bash
$ docker-sync start
```

Start docker compose:

```bash
$ docker-compose up
```

On first run it will install Moodle 3.2 using the command line tools (it may
take a while). When installation is complete go to http://localhost and login
using admin:admin123 as username/password.

The following endpoints are available: 

- Moodle - [http://localhost](http://localhost )

- PhpMyAdmin -  [http://localhost:8001](http://localhost:8001 )

- Mailhog -  [http://localhost:8002](http://localhost:8002 )

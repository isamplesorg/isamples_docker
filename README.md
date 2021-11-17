# isamples_docker
Location to store resources needed to build iSamples Docker containers

## Prerequisites
* Install docker
    https://docs.docker.com/engine/install/
* Configure a docker group and add your user to it
    https://docs.docker.com/engine/install/linux-postinstall/
* Install docker compose
    https://docs.docker.com/compose/install/
* Install git-lfs
    https://git-lfs.github.com
    
## How to build container
First initialize the submodules so you have iSamples in a box pulled in correctly:
`git submodule init`
`git submodule update`

You'll then want to check out the develop branch:
`cd isb/isamples_inabox`
`git checkout develop`

Then cd up to the isb docker directory and initialize git lfs:
`cd ..`
`git lfs install`
`git lfs pull`

Then cd back to the root:
`cd ..`
and run the docker build: `docker-compose up --build`

This should have brought up the containers

## How to ping it to see if it's working
At this point, you should have a running iSamples in a Box container.  You can manually open the docs and use the interactive UI by pinging: http://localhost:8000/docs.  From there, you should be able to interactively hit the various API methods.

The Solr schema should have also been created -- check it at http://localhost:8983/solr/ and look for a collection called `isb_core_records`.

### Manually run an import
* Find the iSB Docker container like this:
    `docker ps`
* Run bash in the iSB container like this:
    `docker exec -it 8743be6ee2f1 bash`
* Once inside bash, export PYTHONPATH to our container install directory (not quite sure why this is required)
    `export PYTHONPATH=/app`
* Run a db import:
    `python scripts/opencontext_things.py --config ./isb.cfg load -m 1000`
* Run a solr import once the db is done:
    `python scripts/opencontext_things.py --config ./isb.cfg populate_isb_core_solr -m 1000`
    
### Import SQL dump into the db
* Dump the data from an existing source:
    pg_dump -U isb_writer -h localhost -d isb_1 > isamples.sql
* Copy the file into the container:
    `docker ps` -- get the name of the postgres container
    `docker cp isamples.sql isamples_docker_db_1:/isamples.sql` -- copy it into the container where `isamples_docker_db_1` is the container name obtained from `docker ps`
* Run the import in the container:
    `docker exec -it isamples_docker_db_1 bash` -- open a shell
    `psql --username=isb_writer --dbname=isb_1 -f ./isamples.sql`

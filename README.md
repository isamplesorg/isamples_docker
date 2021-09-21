# isamples_docker
Location to store resources needed to build iSamples Docker containers
## How to build
First initialize the submodules so you have iSamples in a box pulled in correctly:
`git submodule init`
`git submodule update`

Then run the docker build: `docker-compose up --build`

This should have brought up the containers

Next, you need to manually create the solr collection -- it's bound to port 8983, so open the admin UI and do it by hand on http://localhost:8983

Then once that is done, you want to manually create the schema by running the python script in the iSB container.

Find iSB container like this:
`docker ps`
Run bash in iSB container like this:
`docker exec -it 8743be6ee2f1 bash`
Manually create solr schema like this:
`python solr_schema_init/create_isb_core_schema.py`

#### TODO:
1. Figure out jinja templating issue
2. Figure out python config file issue
3. Get the fasttext model file artifact and copy it into the iSB container via a Dockerfile
4. Manually test import scripts in the containers
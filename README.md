# isamples_docker
Location to store resources needed to build iSamples Docker containers

## Prerequisites
* Install docker
    https://docs.docker.com/engine/install/
* Install git-lfs
    https://git-lfs.github.com
    
## How to build container
First initialize the submodules so you have iSamples in a box pulled in correctly:
`git submodule init`
`git submodule update`

Then run the docker build: `docker-compose up --build`

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


## Setting up nginx

[`nginx`](https://www.nginx.com/) can be configured as the front-end web server for the web serverice offered by the docker instance. These commands all require sudo.

### Installation

Install nginx with:

```
apt update
apt dist-upgrade
apt install nginx
ufw allow "Nginx Full"
```

Install [`LetsEncrypt`](https://letsencrypt.org/) for certificate management:

```
apt install python3-certbot-nginx
```

### Configure

Running `certbot` first puts in place some `nginx` configuration to support SSL:

```
certbot --nginx -d henry.cyverse.org -d isb.isample.xyz
```

The complete config for nginx is provided. The specific `/location/` entries associate a path with the port advertised by the corresponding docker instance.

`/etc/nginx/sites-enabled/default `: 

```
server {
    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/henry.cyverse.org/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/henry.cyverse.org/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    root /var/www/html;
    location / {
            try_files $uri $uri/ =404;
    }

    location /opencontext/ {
        rewrite /opencontext/(.*)  /$1  break;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Scheme $scheme;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_redirect off;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_pass http://localhost:9000;
    }

    location /geome/ {
        rewrite /geome/(.*)  /$1  break;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Scheme $scheme;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_redirect off;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_pass http://localhost:10000;
    }
}
server {
    if ($host = isb.isample.xyz) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    if ($host = henry.cyverse.org) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

        listen 80 ;
        listen [::]:80 ;
    server_name henry.cyverse.org isb.isample.xyz;
    return 404; # managed by Certbot
}
```

### Miscellanea

Start / stop nginx:

```
sudo systemctl stop nginx

sudo systemctl start nginx

sudo systemctl restart nginx
```

Is something listening?

```
sudo netstat -tulpn
```

Is the firewall open?

```
sudo ufw status numbered
```

Renew a certificate (this should be automatic):

```
# test renewal with a dry run
sudo certbot renew --dry-run

# actual renewal
sudo certbot renew
```

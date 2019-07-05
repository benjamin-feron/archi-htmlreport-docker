# archi-htmlreport-docker

Generates and exposes an HTML web site from a ArchiMateTool model.

We uses it internally at [Abes](http://abes.fr) to generate our "urbanization web site" helping us to know how is organized our IT system.

# Parameters

- `GIT_REPOSITORY` : git url of the archimatetool model (mandatory)
- `GIT_CHECK_EACH_NBMINUTES` : time to wait before checking again git repository change (default: 5 minutes)

## GIT_REPOSITORY structure

This git repository will be cloned at `/archi-model-git-repo/` location. It sould have somes data at a specific location:
- `model/` containing the multi xml files generated by ArchiMateTool IDE (mandatory)
- `create-htmlreport.postscript.sh` will be executed each time the HTML report is generated juste after the generation (optional). 

# Internal structure

- `/archi-model-git-repo/` contains the result of `git clone $GIT_REPOSITORY`
- `/archi-model-git-repo/model.archimate` is the onefile model autogenerated by this script (source is `model/`)

# For production

```
mkdir archi-htmlreport/ && cd archi-htmlreport/
echo 'GIT_CHECK_EACH_NBMINUTES=5' > .env
echo 'GIT_REPOSITORY="git@git.abes.fr:supi/Archi.git"' >> .env
wget https://raw.githubusercontent.com/abes-esr/archi-htmlreport-docker/master/docker-compose.yml
docker-compose up -d
```

# For developers

To test it locally
```
docker build -t abes-esr/archi-htmlreport-docker:1.0.3 .
docker run --rm -p 8080:80 \
  -v $(pwd)/id_rsa_archi:/root/.ssh/id_rsa.orig \
  -v $(pwd)/id_rsa_archi.pub:/root/.ssh/id_rsa.pub.orig \
  -e GIT_CHECK_EACH_NBMINUTES=5 \
  -e GIT_REPOSITORY="git@git.abes.fr:supi/Archi.git" \
  abes-esr/archi-htmlreport-docker:1.0.3
```

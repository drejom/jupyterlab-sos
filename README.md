
# JupyterLab-SOS


1. Execute `sh {path_to_your_project}/run.sh`
2. Open `localhost:8888` from a browser

https://towardsdatascience.com/how-to-setup-your-jupyterlab-project-environment-74909dade29b

https://hub.docker.com/r/rocker/binder/dockerfile

------------
# Jupyterlab SOS
[![Docker](https://github.com/drejom/jupyterhub/actions/workflows/build_publish_docker_image.yaml/badge.svg)](https://github.com/drejom/jupyterhub/actions/workflvows/build_publish_docker_image.yaml)

## Features

- SOS jupyterlab
    - R 4.3.1
    - Python 3.10
    - Jupyterscript
    - SAS (via OnDemand)
    - markdown

    - jupyter_ai

- RStudio
- Starship


## Run locally

### Manual build

```sh
docker buildx build --load --platform linux/amd64 -t ghcr.io/drejom/jupyterlab-sos:latest --progress=plain . 2>&1 | tee build.log
```

```
docker run -it --rm -p 8888:8888 \
    -v $PWD/notebooks:/home/rstudio \
    ghcr.io/drejom/jupyterlab-sos:latest 
```

### repo2docker

```
```

## Roadmap

- fix native authenticator
- traefik proxy
- ssh spawner
- Slurm spawner
- dashboards
- launch other services via hub (eg llm apps)
  - jupyter-server-proxy
    - H2O LLM Studio
    - Memgraph (https://medium.com/memgraph/memgraph-lab-2-5-0-is-out-232228bb6187)
    - code https://github.com/seblum/jupyterhub-server-image/tree/main
    - code, pluto, docserver, bookserver
           https://github.com/Rahuketu86/RemoteConnect
    - OpenVINO for Intel GPU
    - vLLM https://vllm.readthedocs.io/

## Further reading and inspo

[Setup on a RPi](https://towardsdatascience.com/setup-your-home-jupyterhub-on-a-raspberry-pi-7ad32e20eed)

[Setup NGNIX proxy](https://hands-on.cloud/nginx-jupyter-proxy-example/)

[Medium-scale JupyterHub deployments](https://opendreamkit.org/2018/10/17/jupyterhub-docker/) (with Traefik)
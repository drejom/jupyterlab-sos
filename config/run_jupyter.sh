#!/bin/bash

cd ~
mkdir -p .jupyter

# copy the jupyter configuration into home-directory
cp -r ${CONFIG_PATH}/jupyter_notebook_config.py ~/.jupyter/

cd ${MAIN_PATH}

mkdir -p notebooks

for script in /etc/profile.d/*.sh; do [ -r "$script" ] && . "$script"; done

jupyter lab --no-browser
#bash
FROM --platform=linux/amd64 rocker/tidyverse:4.3.1 AS base

ENV MAIN_PATH=/usr/local/bin/jpl_config
ENV LIBS_PATH=${MAIN_PATH}/libs
ENV CONFIG_PATH=${MAIN_PATH}/config
ENV NOTEBOOK_PATH=${MAIN_PATH}/notebooks

ARG DEBIAN_FRONTEND=noninteractive

ENV R_LIBS_USER=~/R/%p-library/%v
ENV NB_USER rstudio
ENV NB_UID 1000
ENV VENV_DIR /srv/venv
ENV SHELL /usr/bin/bash
ENV STARSHIP_CONFIG ${VENV_DIR}/starship.toml

# Set ENV for all programs...
ENV PATH ${VENV_DIR}/bin:$PATH
# And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron
RUN echo "export PATH=${PATH}" >> ${HOME}/.profile

# The `rsession` binary that is called by nbrsessionproxy to start R doesn't seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

RUN apt-get update && apt-get install -y \
    # system
    curl \
    nano \
    less \
    telnet \
    gnupg2 \
    nodejs \
    npm \
    # python
    python3-venv python3-dev python3-wheel \
    # Java packages
    openjdk-17-jdk \
    openjdk-17-jre && \
    # cleanup
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN latest_url=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep "browser_download_url" | grep "FiraCode.zip" | cut -d '"' -f 4) && \
    curl -L -o FiraCode.zip $latest_url && \
    unzip FiraCode.zip -d /usr/share/fonts && \
    fc-cache -fv && \
    rm FiraCode.zip && \
    curl -sS https://starship.rs/install.sh | sh -s -- --yes && \
    echo 'eval "$(starship init bash)"' >> /etc/profile


RUN Rscript -e "install.packages(c('pak'), lib = '/usr/local/lib/R/site-library')"

# Install R packages
RUN Rscript -e "pak::pak(c('Microsoft365R', 'IRkernel', 'rio', 'plyr', 'TriMatch', 'MatchIt', 'ggbeeswarm', 'ggsignif', 'ggpubr', 'cowplot', 'ggthemes', 'reshape2', 'ggmosaic', 'randomcoloR'))"

RUN mkdir -p ${VENV_DIR} && chown -R ${NB_USER} ${VENV_DIR}
USER ${NB_USER}

# Install Python packages
RUN python3 -m venv ${VENV_DIR} && \
    pip install --upgrade --no-cache-dir pip==23.0 wheel && \
    ${VENV_DIR}/bin/pip install --upgrade --no-cache-dir \
    # JupyterLab SoS support
    python-lsp-server \
    jedi-language-server \
    notebook \
    nbgitpuller \
    jupyterlab-sos \
    sos-javascript \
    jupyter_ai \
    transient-display-data \
    graphviz \
    imageio \
    pillow \
    # R support
    sos-r \
    jupyter-rsession-proxy \
    feather-format \
    # Python support
    sos-python \
    # Bash support
    sos-bash \
    bash_kernel \
    # makrdown support
    markdown-kernel \
    # SAS support
    saspy==5.3.0 \
    sos-sas \
    sas_kernel==2.4.13
    # # NLP
    # openai \
    # beautifulsoup4 \
    # requests \
    # transformers \
    # argilla \
    # scikit-learn

# Copy confguration
USER root
ADD config/plugin.jupyterlab-settings ${HOME}/.jupyter/lab/user-settings/@jupyterlab/terminal-extension/plugin.jupyterlab-settings
ADD config/starship.toml ${VENV_DIR}/starship.toml
ADD config/bash_aliases.sh /etc/profile.d/bash_aliases.sh
ADD config/sascfg_personal.py /tmp/sascfg_personal.py
#RUN mv /tmp/sascfg_personal.py $(python -c 'import site; print(site.getsitepackages()[0])')/saspy/

# Install jupyter kernels
RUN npm install -g --unsafe-perm ijavascript && \
    ijsinstall --install=global --spec-path=full && \
    python3 -m bash_kernel.install --prefix ${VENV_DIR} && \
    python3 -m markdown_kernel.install --prefix ${VENV_DIR} && \
    python3 -m sas_kernel.install --prefix ${VENV_DIR} && \
    python3 -m sos_notebook.install --prefix ${VENV_DIR} && \
    R --quiet -e "IRkernel::installspec(prefix='${VENV_DIR}')" && \
    chown -R ${NB_USER}:${NB_USER} ${VENV_DIR} ${HOME}

USER ${NB_USER}

CMD cd ${MAIN_PATH} && sh config/run_jupyter.sh

#CMD jupyter lab --ip 0.0.0.0

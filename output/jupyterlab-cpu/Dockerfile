
###############################
###  .tmp/cpu.Dockerfile
###############################


###############################
###  docker-bits/0_cpu.Dockerfile
###############################

# Docker-stacks version tags (eg: `r-4.0.3`) are LIVE images that are frequently updated.  To avoid unexpected
# image updates, pin to the docker-stacks git commit SHA tag.
# It can be obtained by running `docker inspect repo/imagename:tag@digest` or from 
# https://github.com/jupyter/docker-stacks/wiki

ARG BASE_VERSION=512afd49b925
FROM jupyter/datascience-notebook:$BASE_VERSION

USER root

ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

###############################
###  docker-bits/3_Kubeflow.Dockerfile
###############################

USER root

RUN pip3 --no-cache-dir install --quiet \
      'git+https://github.com/statcan/kubeflow-pipelines@b47c8de7f2915722c5c91bf3b1c7d54b946ef2a6#subdirectory=sdk/python/' \
      'kfp-server-api==1.3.0' \      
      'kubeflow-fairing==1.0.2' \
      'ml-metadata==0.27.0' \
      'kubeflow-metadata==0.2.0' \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==5.0.10' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

# kfp-azure-databricks needs to be run after kfp
RUN pip3 --no-cache-dir install --quiet \
      'fire==0.3.1' \
      'git+https://github.com/kubeflow/pipelines@1d86111d8f152d3ed7506ea59cee1bfbc28abbf9#egg=kfp-azure-databricks&subdirectory=samples/contrib/azure-samples/kfp-azure-databricks' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

###############################
###  docker-bits/4_CLI.Dockerfile
###############################

USER root

# Dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
      'byobu' \
      'htop' \
      'jq' \
      'less' \
      'openssl' \
      'ranger' \
      'tig' \
      'tmux' \
      'tree' \
      'vim' \
      'zip' \
      'zsh' \
      'wget' \
      'curl' \
  && \
    rm -rf /var/lib/apt/lists/*

ARG KUBECTL_VERSION=v1.15.10
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=38a0f73464f1c39ca383fd43196f84bdbe6e553fe3e677b6e7012ef7ad5eaf2b

ARG MC_VERSION=mc.RELEASE.2021-01-05T05-03-58Z
ARG MC_URL=https://dl.min.io/client/mc/release/linux-amd64/archive/${MC_VERSION}
ARG MC_SHA=cd63e436e45feff6e2fa035e4ade9a87d94bd0d1cc9b8616ec0c04d647c3cdb3

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb
# ARG AZCLI_SHA=53184ff0e5f73a153dddc2cc7a13897022e7d700153f075724b108a04dcec078

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh
ARG OH_MY_ZSH_SHA=22811faf34455a5aeaba6f6b36f2c79a0a454a74c8b4ea9c0760d1b2d7022b03

# Add helpers for shell initialization
COPY shell_helpers.sh /tmp/shell_helpers.sh

# kubectl, mc, and az
RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    wget --quiet -O mc "${MC_URL}" \
    && echo "${MC_SHA} mc" | sha256sum -c - \
    && chmod +x mc \
    && mv mc /usr/local/bin/mc-original \
  && \
    curl -sLO https://aka.ms/InstallAzureCLIDeb \
    && bash InstallAzureCLIDeb \
    && rm InstallAzureCLIDeb \
    && echo "azcli: ok" \
  && \
    wget -q "${OH_MY_ZSH_URL}" -O /tmp/oh-my-zsh-install.sh \
    && echo "${OH_MY_ZSH_SHA} /tmp/oh-my-zsh-install.sh" | sha256sum -c \
    && echo "oh-my-zsh: ok"

###############################
###  docker-bits/5_DB-Drivers.Dockerfile
###############################

# ODBC drivers
RUN apt-get update && \
    apt-get install -y alien unixodbc unixodbc-dev && \
    pip install --no-cache-dir --quiet 'pyodbc==4.0.30' && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

###############################
###  docker-bits/6_jupyterlab.Dockerfile
###############################

# installs vscode server, python & conda packages and jupyter lab extensions.

# Using JupyterLab 3.0 inherited docker-stacks base image. A few extensions we used to install do not yet support
# this version of Jupyterlab and/or are not OL-compliant so they have been removed until new compatible versions are available:
    # jupyterlab-kale
    # jupyterlab-variableinspector
    # jupyterlab-archive
    # jupyterlab-spellchecker
    # jupyterlab-spreadsheet
# JupyterLab 3.0 introduced i18n and i10n which now allows us to have a fully official languages compliant image.
# TODO: use official package jupyterlab-language-pack-fr-FR when released by Jupyterlab instead of the StatCan/jupyterlab-language-pack-fr_FR repo.

# Install vscode
ARG VSCODE_VERSION=3.10.2-nodownload
ARG VSCODE_SHA=8d5a7cef22ef0bafef635518721efd348cfecd40e65c076908e17b33fe1cc62c
ARG VSCODE_URL=https://github.com/StatCan/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root
RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && dpkg -i ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && mkdir -p /etc/share/code-server/extensions

# Fix for VSCode extensions and CORS
ENV XDG_DATA_HOME=/etc/share
ENV SERVICE_URL=https://extensions.coder.com/api
COPY vscode-overrides.json $XDG_DATA_HOME/code-server/User/settings.json
ARG SHA256py=d32d8737858661451705faa9f176f8a1a03485b2d9984de40d45cc0403a3bcf4
# Languagepacks.json needs to exist for code-server to recognize the languagepack
COPY languagepacks.json $XDG_DATA_HOME/code-server/

RUN VS_PYTHON_VERSION="2021.5.829140558" && \
    wget --quiet --no-check-certificate https://github.com/microsoft/vscode-python/releases/download/$VS_PYTHON_VERSION/ms-python-release.vsix && \
    echo "${SHA256py} ms-python-release.vsix" | sha256sum -c - && \
    code-server --install-extension ms-python-release.vsix && \
    rm ms-python-release.vsix && \
    code-server --install-extension ikuyadeu.r@1.6.6 && \
    code-server --install-extension MS-CEINTL.vscode-language-pack-fr@1.56.2 && \
    fix-permissions $XDG_DATA_HOME

# Default environment
RUN pip install --quiet \
      'jupyter-lsp==1.2.0' \
      'jupyter-server-proxy==1.6.0' \
      'kubeflow-kale==0.6.1' \
      'jupyterlab_execute_time==2.0.1' \
      'git+https://github.com/betatim/vscode-binder' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets==7.6.3' \
      'ipympl==0.7.0' \
      'jupyter_contrib_nbextensions==0.5.1' \
      'nb_conda_kernels==2.3.1' \
      'nodejs==15.14.0' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash==0.4.0' \
    && \
    pip install \
      'jupyterlab-git==0.30.0' \
      'jupyterlab-lsp==3.6.0' \
      'git+https://github.com/StatCan/jupyterlab-language-pack-fr_FR.git' \
    && \
    conda clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@jupyterlab/translation-extension@3.0.4' \
      '@jupyterlab/server-proxy@2.1.2' \
      'jupyterlab-plotly@4.14.3' \
      'nbdime-jupyterlab' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Install python, R, Julia and other useful language servers
RUN julia -e 'using Pkg; Pkg.add("LanguageServer")' \
    && \
    conda install -c conda-forge \
      'r-languageserver' \
      'python-lsp-server' \
    && \
    jlpm add --dev \
      'bash-language-server' \
      'dockerfile-language-server-nodejs' \
      'javascript-typescript-langserver' \
      'sql-language-server' \
      'unified-language-server' \
      'yaml-language-server@0.18.0' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/statcan/jupyter-notebooks

###############################
###  docker-bits/7_remove_vulnerabilities.Dockerfile
###############################

# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN apt-get update --yes \
    && dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*
USER $NB_USER

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc 

# Add --user to all pip install calls
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]

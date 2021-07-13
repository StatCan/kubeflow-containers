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

FROM nvidia/cuda:10.2-runtime

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH ~/miniconda3/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y sudo wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
	
RUN adduser liang && \
    echo "liang ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/liang && \
    chmod 0440 /etc/sudoers.d/liang
  
USER liang
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p ~/miniconda3 && \
    rm ~/miniconda.sh 

USER root
RUN ln -s /home/liang/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh

USER liang
RUN echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    conda install jupyter jupyterlab conda-build nodejs -y --quiet && \
    ~/miniconda3/bin/jupyter nbextension enable --py widgetsnbextension && \
    ~/miniconda3/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    conda create -n py37 python=3.7 anaconda tensorflow-gpu pytorch --yes && \
    ~/miniconda3/envs/py37/bin/python -m ipykernel install --user --name py37 --display-name "py37" && \
    find ~/miniconda3/ -follow -type f -name '*.a' -delete && \
    find ~/miniconda3/ -follow -type f -name '*.js.map' -delete && \
    conda build purge-all
	
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]

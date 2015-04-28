FROM jupyter/jupyterhub

MAINTAINER Filipe Fernandes <ocefpaf@gmail.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libsm6 libxrender1 libfontconfig1

# Install miniconda.
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
    bash Miniconda-latest-Linux-x86_64.sh -b -p /opt/miniconda && \
    rm Miniconda-latest-Linux-x86_64.sh
ENV PATH /opt/miniconda/bin:$PATH
RUN chmod -R a+rx /opt/miniconda

# Install IOOS modules and IPython dependencies.
RUN conda update --quiet --yes conda
RUN conda config --add channels ioos -f
RUN wget https://raw.githubusercontent.com/ioos/conda-recipes/master/00_env_requirements/ioos/ioos_req.txt
RUN conda install --quiet --yes --file ioos_req.txt python=2.7

# Set up IPython kernel.
RUN pip install file:///srv/ipython && \
    rm -rf /usr/local/share/jupyter/kernels/* && \
    python2 -m IPython kernelspec install-self

# Clean up.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN conda clean -y -t

# Test.
RUN python -c "import iris, pyoos, oceans, utilities"

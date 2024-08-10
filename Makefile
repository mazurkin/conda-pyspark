# Pyspark notebooks makefile
#
# https://swcarpentry.github.io/make-novice/reference.html
# https://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/
# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

SHELL := /bin/bash
ROOT  := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CONDA_ENV_NAME = pyspark

export PYSPARK_DRIVER_PYTHON      = jupyter
export PYSPARK_DRIVER_PYTHON_OPTS = notebook

export SPARK_LOCAL_IP  = 127.0.0.1
export SPARK_CONF_DIR  = $(ROOT)/conf/spark

export PATH            := ${HADOOP_HOME}/bin:${SPARK_HOME}/bin:${PATH}
export LD_LIBRARY_PATH := ${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}


# -----------------------------------------------------------------------------
# notebook
# -----------------------------------------------------------------------------

.DEFAULT_GOAL = notebook

.PHONY: notebook
notebook:
	@conda run --no-capture-output --live-stream --name $(CONDA_ENV_NAME) \
		jupyter notebook \
			--IdentityProvider.token='' \
			--IdentityProvider.password_required='false' \
			--ServerApp.use_redirect_file=True \
			--ip=localhost \
			--port=8888 \
			--notebook-dir=$(ROOT)/notebooks

# -----------------------------------------------------------------------------
# conda environment
# -----------------------------------------------------------------------------

.PHONY: env-init
env-init:
	@conda create --yes --name $(CONDA_ENV_NAME) python=3.10.12 conda-forge::poetry=1.8.3

.PHONY: env-create
env-create:
	@conda run --no-capture-output --live-stream --name $(CONDA_ENV_NAME) poetry install --no-root --no-directory

.PHONY: env-update
env-update:
	@conda run --no-capture-output --live-stream --name $(CONDA_ENV_NAME) poetry update

.PHONY: env-remove
env-remove:
	@conda env remove --yes --name $(CONDA_ENV_NAME)

.PHONY: env-shell
env-shell:
	@conda run --no-capture-output --live-stream --name $(CONDA_ENV_NAME) bash

.PHONY: env-info
env-info:
	@conda run --no-capture-output --live-stream --name $(CONDA_ENV_NAME) conda info

.PHONY: env-list
env-list:
	@conda run --no-capture-output --live-stream --name $(CONDA_ENV_NAME) conda list

# -----------------------------------------------------------------------------
# util
# -----------------------------------------------------------------------------

.PHONY: clean-data
clean-data:
	@find . -name '*.gz' -type f -delete

.PHONY: clean-logs
clean-logs:
	@find . -name '*.log' -type f -delete

.PHONY: clean
clean: clean-logs clean-data

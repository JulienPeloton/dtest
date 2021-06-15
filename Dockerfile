FROM jupyter/pyspark-notebook:spark-3.1.1
LABEL maintainer "peloton@lal.in2p3.fr"
ENV REFRESHED_AT 2021-06-08

# Add repo
WORKDIR /home/jovyan/work
ADD . .
#COPY --chown=jovyan:users . .
# Append Spark specific modules (coverage)
ENV PYTHONPATH=$PYTHONPATH:${SPARK_HOME}/python/test_coverage
ENV PYTHONPATH=$PYTHONPATH:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9-src.zip

ENV COVERAGE_PROCESS_START=/home/jovyan/work/.coveragerc

USER root
RUN apt-get update \
  && apt-get install -y vim curl unzip \
  && rm -rf /var/lib/apt/lists/*

# Spark conf addition
RUN echo "spark.eventLog.enabled true" >> $SPARK_HOME/conf/spark-defaults.conf \
  && echo "spark.eventLog.dir file:///tmp/spark-events" >> $SPARK_HOME/conf/spark-defaults.conf \
  && echo "spark.sql.shuffle.partitions 10" >> $SPARK_HOME/conf/spark-defaults.conf \
  && echo "SPARK_LOG_DIR=/tmp/spark-events" >> $SPARK_HOME/conf/spark-env.sh 
USER jovyan:users

# Add dependencies
RUN pip install -r requirements.txt \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/jovyan"

RUN python config_rise.py \
  && mkdir /tmp/spark-events

WORKDIR /home/jovyan/work

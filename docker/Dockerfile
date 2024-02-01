FROM mambaorg/micromamba

# for building the conda env
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml
# Build the environment based on the yml file
RUN micromamba install -y -n base -f /tmp/environment.yml \
  && micromamba clean --all --yes

# Now add the necessary scripts:

# the scripts which actually run the analysis
ADD run.sh /usr/local/bin/run_normalize.sh
ADD normalize.R /usr/local/bin/normalize.R

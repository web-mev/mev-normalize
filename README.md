# mev-normalize

This repository contains a WebMeV-compatible tool for RNA-seq normalization. We provide a number of commonly used transformations.

The result is a normalized count matrix.

---

### To run external of WebMeV:

Either:
- build the Docker image using the contents of the `docker/` folder (e.g. `docker build -t myuser/normalize:v1 .`) 
- pull the docker image from the GitHub container repository (see https://github.com/web-mev/mev-normalize/pkgs/container/mev-normalize)

To run, execute the following:
```
docker run -d -v $PWD:/work <IMAGE> /usr/local/bin/run.sh /work/<path to raw counts in TSV format> <normalization method> <perform log transform on result?>
```
(here, we mount the current directory to `/work` inside the container- we assume your current working directory has the raw count matrix you are attempting to normalize)

The `<normalization method>` is one of those included in `operation_spec.json`:
- "CSS" (cumulative sum scaling. See https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4010126/)
- "TSS" (total sum scaling)
- "DESeq2" (by DEseq2's median-based method)
- "TMM" (by edgeR's trimmed means of M value)
- "UQ" (upper quartile)

The final argument dicates whether to log-transform the resulting normalized counts. Use 0 (no) or 1 (yes). 

This will create an output file (the normalized counts in TSV format) in your current directory.

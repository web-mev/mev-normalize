#!/bin/bash

# First arg is the path to the input counts matrix
INPUT_COUNTS=$1

OUTPUT_DIR=$(dirname $INPUT_COUNTS)

# how to normalize (the method)
METHOD=$2

# bool- whether to log-transform the result
LOG_TRANFORM=$3

# To prevent R from mangling the column names, we send the counts (without header line)
# to another temp file
COUNTS_WITHOUT_HEADER="raw_counts.tsv"
sed 1d $INPUT_COUNTS > $COUNTS_WITHOUT_HEADER

# Call the R script. This will output a normalized count matrix without a header
FOUT=$OUTPUT_DIR/"nc.tsv"
Rscript /opt/software/normalize.R $COUNTS_WITHOUT_HEADER $METHOD $LOG_TRANFORM $FOUT

# Create the final file by concatenating the original header (from the input matrix)
# and the normalized counts (which did not have a header)
if [ $LOG_TRANFORM = 1 ]
then
    FINAL_OUTPUT=$OUTPUT_DIR/"normalized_counts."$METHOD".log_transformed.tsv"
else
    FINAL_OUTPUT=$OUTPUT_DIR/"normalized_counts."$METHOD".tsv"
fi
head -1 $INPUT_COUNTS >$FINAL_OUTPUT
cat $FOUT >>$FINAL_OUTPUT

# Need to create the outputs.json file for WebMEV compatability
echo "{\"normalized_counts\":\""$FINAL_OUTPUT"\"}" > $OUTPUT_DIR/outputs.json

# cleanup
rm $COUNTS_WITHOUT_HEADER
rm $FOUT

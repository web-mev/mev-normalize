suppressMessages(suppressWarnings(library('metagenomeSeq', character.only=T, warn.conflicts = F, quietly = T)))
suppressMessages(suppressWarnings(library('edgeR', character.only=T, warn.conflicts = F, quietly = T)))
suppressMessages(suppressWarnings(library('DESeq2', character.only=T, warn.conflicts = F, quietly = T)))
suppressMessages(suppressWarnings(library('matrixStats', character.only=T, warn.conflicts = F, quietly = T)))

# args from command line:
args<-commandArgs(TRUE)

# path to the count matrix
COUNTS_FILE <- args[1]

# The method to use for normalization
METHOD <- tolower(args[2])

# whether or not to perform a log-transformation
LOG_TRANSFORM <- as.logical(as.integer(args[3]))

OUTPUT_FILE_PATH <- args[4]

# Note that we assume there is no column header. This keeps R from 'renaming'
# the columns of the matrix.
counts <- read.table(COUNTS_FILE, sep='\t', stringsAsFactors=F, row.names=1)

METHODS <- c('css', 'tss', 'deseq2', 'tmm', 'uq')
method_selection <- pmatch(tolower(METHOD), METHODS)
if(is.na(method_selection)){
    message('Invalid normalization method.')
    quit(status=1)
} else if(method_selection == -1){
    message('Ambiguous transformation method')
    quit(status=1)
}

if(METHOD == 'css'){
    
    obj = newMRexperiment(counts, phenoData=NULL, featureData=NULL)
    
    # gets the scaling factors so we can ultimately use that to set the 'global'
    # expression level to the median of the adjusted counts
    obj = cumNorm(obj)

    # sl gives the scaling factor that is applied to all samples. It's not related
    # the normalization per se, but rather to just adjusting the magnitude of all
    # counts simultaneously
    norm_mtx = MRcounts(obj,log=FALSE,norm=TRUE,sl=median(normFactors(obj)))
}

if(METHOD == 'tss'){
    tss = colSums(counts, na.rm=T)
    norm_mtx = sweep(counts,2,tss,'/')
}

if(METHOD == 'deseq2'){
    deseq_sf = estimateSizeFactorsForMatrix(counts)
    norm_mtx = sweep(counts,2,deseq_sf,'/')
}

if(METHOD == 'tmm'){
    d <- DGEList(counts, lib.size = as.vector(colSums(counts, na.rm=T)))
    d <- calcNormFactors(d,method='TMM')
    norm_mtx = cpm(d, normalized.lib.size=TRUE)
}

if(METHOD == 'uq'){
    y = as.matrix(counts) # otherwise matrixStats issues a warning
    # only care about the expressed features. 
    # This allows us to drop non-expressed when calculating the 75% percentile
    y[y==0] = NA
    scale = 1
    normalizationScale = colQuantiles(y,p=0.75,na.rm=TRUE)
    norm_mtx = sweep(counts,2,normalizationScale/scale,'/')
}

if(LOG_TRANSFORM && exists('norm_mtx')) {
    norm_mtx = log2(norm_mtx+1)
}

# change the working directory to co-locate with the counts file:
#working_dir <- dirname(COUNTS_FILE)
#base_name = paste('normalized_counts', METHOD, 'tsv', sep='.')
#results_file <- paste(working_dir, base_name, sep='/')
# note that we do NOT write the header
write.table(norm_mtx, file=OUTPUT_FILE_PATH, sep='\t', col.names=F, quote=FALSE)

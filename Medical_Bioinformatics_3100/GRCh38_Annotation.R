### R
# installing packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("org.Hs.eg.db")

# loading packages
library(org.Hs.eg.db)
columns(org.Hs.eg.db)

# view example gene IDs
keys(org.Hs.eg.db, keytype="ENTREZID")[1:10]
keys(org.Hs.eg.db, keytype="SYMBOL")[1:10]

# load my data
load("343_local.sam")

# see if the gene IDs exist in our annotation database
my.genes <- c("50916", "110308","122920")
status <- my.genes %in% keys(org.Hs.eg.db, keytype="ENTREZID") 
status
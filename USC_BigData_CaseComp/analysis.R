
rna <- read.csv("/Volumes/GoogleDrive/Mon disque/winter term/capstone/casecompetition/RNAseq.csv", header=T)
rna[,1] <- NULL
# filter to keep bacteria with sum >> 50 in all samples

dim(rna)
row_sums <-rowSums(rna[,-1])
summary(row_sums)
rna.filt <- rna[which(row_sums > 1000000000),-1]
dim(rna.filt)
max_row_sum <- which.max(row_sums, 20)

rna[max_row_sum,1]

# make a CLR transform of the filtered data
rna.clr <- apply(rna.filt, 1, function(x) (x-mean(x))/sd(x))


# 2 means columns
# standard log ratio transform

# generate and SVD of the data
rna.pcx <- prcomp(rna.clr)
# 5 dimensions because 1 fewer than the smallest of the rows and columns (6-1)

# plot a scree plot
plot(rna.pcx)
# the first component stands out a lot (60 > 20 (expected))

str(rna.pcx, cex=c(1,0.5))
# sdev is the square of one divided by the sum of all
# rotation contains the x,y coordinates we see on the plot
# x the location of the samples on that brnalot in each of the components

biplot(rna.pcx)

# preparing coordinates for clustering
rna.scores.eigen <- rna.pcx$x




# clustering with just the first PC
rna.scores.eigen_PC1 <- rna.scores.eigen[,1]

rna.cluster1 <- rna.scores.eigen_PC1[rna.scores.eigen_PC1>0]
rna.cluster2 <- rna.scores.eigen_PC1[rna.scores.eigen_PC1<0]

write(names(rna.cluster1), "cluster1.txt")
write(names(rna.cluster2), "cluster2.txt")

##########################################
# Differential expression



# whichpart <- function(x, n=30) {
#   nx <- length(x)
#   p <- nx-n
#   xp <- sort(x, partial=p)[p]
#   which(x > xp)
# }
# 
# max_row_sum <- whichpart(row_sums, 20)
# 
# 
# write(rna[max_row_sum,1], "DEgenes.txt")
# 
# ######## How to find the most differentially expressed genes:
# 
# # First: make a vector 4000 elements long filled with "group1" and group2" based one whether a sample falls in group1 or group2
#   pseudocode: conds <- "group1" if sample in cluster1, else "group2"
#   
# # Second: find indices of genes where the DIFFERENCE is GREATEST between a. the rowsum among group1, and b. the rowsum among group2
# Third: perhaps do step 2 using percent difference


group1 <- names(rna.cluster1)
group2 <- names(rna.cluster2)

geneIDs <- read.csv("/Volumes/GoogleDrive/Mon disque/winter term/capstone/caseround2/TeamNumberNinjas_geneIDs.csv")
geneIDs <- as.vector(geneIDs)

# filter down to only our 30 genes
rna_subset <- rna[rna$Gene_ID %in% geneIDs[[1]],]

# divide into our clusters
rna_subset1 <- rna_subset[,group1]
rna_subset2 <- rna_subset[,group2]

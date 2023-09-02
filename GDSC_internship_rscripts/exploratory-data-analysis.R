#################~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Exploratory data analysis of RNA-seq data 

# 1. read in data & create DESeq2 object 
# 2. euclidean distance based clustering 
# 3. principal components analysis 
# 4. unsupervised hierarchical clustering 
#
#################~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(dplyr)
library(ggplot2)
library(tximport)
# BiocManager::install("DESeq2")
library(DESeq2)
library(biomaRt)
library(pheatmap)
library(RColorBrewer)
# BiocManager::install("ComplexHeatmap")
library(ComplexHeatmap)
library(circlize)

# set directories 
dir1 <- "files/"
dir2 <- "figures/"
setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")

########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# load data 
########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# read in the matrix we generated using htseq-count
cts <- as.matrix(read.table("files/featurecounts.readcounts.ann.tsv",
                            sep="\t",
                            header = TRUE,
                            row.names=1,
                            stringsAsFactors = F))
cts <- cts[,c(7:16,18)]

gene_names <- rownames(cts)

cts <- apply(cts, 2, as.numeric)

rownames(cts) <- gene_names

# read in the file from the SRA metadata that has sample/experimental labels
# colData <- read.csv("files/metadata.csv", row.names=1)
# head(colData)

# order by sample name 
# colData <- colData[order(colData$sample),]

# create factor variable for tx group 
# colData$tx.group <- factor(colData$tx.group, levels=c("untreated", "treated"))
colData <- data.frame(sample = colnames(cts),
                         tx.group = c(rep("EV",4),
                                      rep("Pdk",4),
                                      rep("Pdp",3)))

# confirm IDs in same order in metadata and counts data 
identical(colData$sample, colnames(cts))

# create DESeq2 object 
dds <- DESeqDataSetFromMatrix(countData = cts,
                                  colData = colData,
                                  design = ~ tx.group)

# run deseq framework
dds <- DESeq(dds)

# drop genes with low counts 
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

# rlog transformation 
rld <- rlog(dds, blind = FALSE)

# save DESeq2 object 
saveRDS(dds, file = "files/DESeq2.rds")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# euclidean distance-based unsupervised clustering 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

###### sample distance (euclidean) plot ###### 
sampleDists <- dist(t(assay(rld)))
sampleDistMatrix <- as.matrix( sampleDists )
rownames(sampleDistMatrix) <- paste( colnames(rld))
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)

# produce plot
ppi = 1000
png(paste0(dir2, "euclidean_distance_matix.png"), width=7*ppi, height=6*ppi, res=ppi)
pheatmap(sampleDistMatrix,
         clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         col = colors, main = "Euclidean distance")
dev.off()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# principal components analysis 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# calculate gene expression level variance between samples 
var <- rev(rowVars(assay(rld))[order(rowVars(assay(rld)))])

# plot variance for genes accross samples
png(paste0(dir2, "per_gene_variance.png"), width=5*ppi, height=5*ppi, res=ppi)
plot(var, las = 1, main="Sample gene expression variance", xlab = "Gene", ylab = "Variance")
abline(v=400, col="red") 
dev.off()

# select number of genes and run PCA 
var_genes <- 400
rv <- rowVars(assay(rld))
select <- order(rv, decreasing = TRUE)[seq_len(min(var_genes, length(rv)))]
pca <- prcomp(t(assay(rld)[select, ]))
percentVar <- pca$sdev^2/sum(pca$sdev^2)
names(percentVar)[1:10] <- c("PC1", "PC2", "PC3", "PC4", "PC5", 
                             "PC6", "PC7", "PC8", "PC19", "PC10")

# plot variance for top 10 PCs 
png(paste0(dir2, "PCA_variance-top", var_genes, "-genes.png"), width=5*ppi, height=5*ppi, res=ppi)
barplot(percentVar[1:10], col = "indianred", las = 1, ylab = "Percent Variance explained", cex.lab = 1.2)
dev.off()

# group into data frame and add sample labels 
pca_df <- as.data.frame(pca$x)
pca_df$group <- as.factor(colData$tx.group)
pca_df$sample_ids <- colnames(dds)

# add colors for plotting to df 
pca_df$col <- NA
for(i in 1:length(levels(pca_df$group))){
  ind1 <- which(pca_df$group == levels(pca_df$group)[i])
  pca_df$col[ind1] <- i
}

# plot PCs
png(paste0(dir2, "pca_top-", var_genes, "-genes_PC1vsPC2.png"), width=6*ppi, height=6*ppi, res=ppi)
plot(pca_df[, 1], pca_df[, 2], 
     xlab = paste0("PC1 (", (round(percentVar[1], digits=3)*100), "% variance)"), 
     ylab = paste0("PC2 (", (round(percentVar[2], digits=3)*100), "% variance)"),
     main=(paste0("PC1 vs PC2 for ", var_genes, " most variable genes")),
     pch=16, cex=2, cex.lab=1.3, cex.axis = 1.15, las=1, panel.first = grid(),
     col=pca_df$col,
     xlim=c(-20,30))
#ylim=c(-40, 60))
text((pca_df[, 2])~(pca_df[, 1]), 
     labels = pca_df$sample_ids, cex=1.1, font=2, pos=4)
# add color labels for cell lines 
dev.off()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# unsupervised hiereachical clustering 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# select top X no. of variable genes 
topVarGenes <- head(order(rowVars(assay(rld)), decreasing=TRUE), var_genes)

# set up gene expression matrix 
mat1 <- assay(rld)[topVarGenes,]

# scale matrix by each col. values 
mat_scaled = t(apply(mat1, 1, scale))

# set up colors for heatmap 
col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(12, "Paired")
cols2 <- brewer.pal(9, "Greens")
cols3 <- brewer.pal(9, "Reds")

ha1 = HeatmapAnnotation(Tx_group = colData$tx.group, 
                        col = list(Tx_group = c("EV" = cols1[7], "Pdk" = cols1[8], "Pdp" = cols1[9]), 
                          show_legend = TRUE)
)

# se up column annotation labels (samples)
ha = columnAnnotation(x = anno_text(colnames(dds), 
                                    which="column", rot = 45, 
                                    gp = gpar(fontsize = 10)))

# generate heatmap object 
ht1 = Heatmap(mat_scaled,name = "Expression", 
              col = col, 
              bottom_annotation = c(ha),
              top_annotation = c(ha1),
              show_row_names = FALSE)

# plot the heatmap 
png(paste0(dir2, "heatmap_top-", var_genes, "-genes.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = paste0(var_genes, " most variable genes"))
dev.off()

#################~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Differential expression analysis w/ DESeq2

# 1. extract DE results for significant genes and contrast of interest 
# 2. generate volcanomplot 
# 3. unsupervised hierarchical clustering of DEGs 
# 4. MA plots 
# 5. annotate results set & write results to file 

#################~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BiocManager::install("tximport")
# BiocManager::install("vsn")
# BiocManager::install("EnhancedVolcano")
# BiocManager::install("apeglm")
library(tximport)
library(DESeq2)
library(biomaRt)
library(vsn)
library(dplyr)
library(pheatmap)
library(gplots)
library(RColorBrewer)
library(ComplexHeatmap)
library(readr)
library(circlize)
library(EnhancedVolcano)
library(apeglm)

# set directories 
dir1 <- "files/"
dir2 <- "figures/"
dir3 <- ""
setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")

########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# extract DE results 
########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# set comparison name 
comparison <- "Pdp.v.Pdk"

# read in DEseq object 
dds <- readRDS(paste0(dir1, "DESeq2.rds"))

# get results for DEG analysis (and order by Pval)  
res <- results(dds, alpha = 0.05, contrast = c("tx.group",'Pdp','Pdk'), altHypothesis = "greaterAbs")

res <- res[!is.na(res$padj),]
#
# # order by P-value
# res_ord <- res[order(res$pvalue),]

anno <- read.delim(paste0(dir1, "GRCm38.p6_ensembl-97.txt"), stringsAsFactors = T, header = T)

# use match() to find corresponding indices (rows) for each ENSG ID
mat1 <- match(rownames(res), anno$Gene.stable.ID)

# check if any NAs exist
table(is.na(mat1))

# add gene names to results as a new column
res$gene <- as.character(anno$Gene.name[mat1])
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# dispersions plot
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ppi=300
# plot disperson estimates 
png(paste0(dir1, "", comparison, "dispersion-estimates.png"), width=5*ppi, height=5*ppi, res=ppi)
plotDispEsts(dds, main=paste0(comparison, ""))
dev.off()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# generate volcano plot
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# read in custom volcano plotting function 
# source(paste0("/dartfs-hpc/rc/lab/G/GMBSR_bioinfo/misc/plotting-ultilities/volcano.R"))
source(paste0("/Volumes/rc/lab/G/GMBSR_bioinfo/misc/plotting-ultilities/volcano.R"))

# res$gene <- rownames(res)
# make volcano plot 
volcano_plot(dat = res, 
             out_dir = paste0(dir1, ""), 
             out_name = paste0(comparison, "_volcano.png"), 
             title = paste0(comparison, " Differential gene expression"), 
             fc_line = 2,
             alpha = 0.05, 
             fc_label = 3, 
             alpha_label_no = 10
             )


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# unsupervised hierarchical clustering of DEGs 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# subset transformed expressed counts to only significant DEGs
mat1 <- assay(rld)[rownames(res),]

# scale matrix by each col. values 
mat_scaled = t(apply(mat1, 1, scale))

# set up colors for heatmap 
col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(12, "Paired")
cols2 <- brewer.pal(9, "Greens")

# set up colors for heatmap 
ha1 = HeatmapAnnotation(Tx_group = colData$tx.group, 
                        col = list(Tx_group = c("EV" = cols1[7], "Pdk" = cols1[8], "Pdp" = cols1[9]), 
                                   show_legend = TRUE)
)

# se up column annotation labels (samples)
ha = columnAnnotation(x = anno_text(colnames(dds), 
                                    which="column", rot = 45, 
                                    gp = gpar(fontsize = 10)))
# generate heatmap object 
ht1 = Heatmap(mat_scaled, name = "Expression", col = col, bottom_annotation = c(ha),
              top_annotation = c(ha1),
              show_row_names = FALSE)

# plot the heatmap 
ppi=300
png(paste0(dir2, "DEG-heatmap-Ev.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = paste0("DE genes, FDR<0.05 - ", comparison))
dev.off()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# calculate shrunken fold changes and generate MA plots 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source(paste0("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg/scripts/ma-plot.R"))

# calculate shrunk estimates
# res_shrunk <- lfcShrink(dds, coef=paste0(res), 
#                           type="apeglm", 
#                           lfcThreshold=0, 
#                           svalue = FALSE)

res_shrunk <- lfcShrink(dds, contrast = c("tx.group",'Pdp','Pdk'),
                        type="ashr", 
                        lfcThreshold=0, 
                        svalue = FALSE)

res_shrunk <- res_shrunk[rownames(res_shrunk) %in% rownames(res),]
# res <- res[!is.na(res$padj),]

# add shrunk fold change to results  
res$lfc_shrunk <- res_shrunk$log2FoldChange

png(paste0(dir1, comparison, "ma.png"), width=14*ppi, height=8.75*ppi*2, res=ppi)

# generate MA plot with raw FCs 
p1 <- ma_plot(res_df = res, 
             lfc_type = "raw", 
             out_dir = paste0(dir1), 
             out_name = paste0(comparison, "raw_ma.png"), 
             title = paste0(comparison, " raw Differential gene expression"), 
             alpha = 0.05, 
             fc_label = 3,
             abs_xlab_thres = 2
             )

# generate MA plot with shrunk FCs 
p2 <- ma_plot(res_df = res, 
             lfc_type = "shrunk", 
             out_dir = paste0(dir1), 
             out_name = paste0(comparison, "shrunk_ma.png"), 
             title = paste0(comparison, " shrunk Differential gene expression"), 
             alpha = 0.05, 
             fc_label = 3,
             abs_xlab_thres = 2
             )

library(gridExtra)
grid.arrange(p1, p2, ncol=1, nrow = 2)

dev.off()




# # remove results subject to independent filtering 
# res <- res[!is.na(res$padj),]
# 
# # order by P-value 
res_ord <- res[order(res$pvalue),]

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# read in annotation results  & write to file 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# read uin annotation data 
# anno <- read.delim(paste0(dir3, "GRCm38.p6_ensembl-97.txt"), stringsAsFactors = T, header = T)

# use match() to find corresponding indices (rows) for each ENSG ID
# mat1 <- match(rownames(res_ord), anno$Gene.stable.ID)

# check if any NAs exist
# table(is.na(mat1))

# add gene names to results as a new column
res_ord$gene <- as.character(anno$Gene.name[mat1])

# add additonal variables of interest 
res_ord$chr <- as.character(anno$Chromosome.scaffold.name[mat1])
res_ord$start <- as.character(anno$Gene.start..bp.[mat1])
res_ord$end <- as.character(anno$Gene.end..bp.[mat1])
res_ord$strand <- as.character(anno$Strand[mat1])

# subset @ 5% adjusted pval sig. level
res_order_FDR_05 <- res_ord[res_ord$padj<0.05,]
nrow(res_order_FDR_05)

# write csv file for complete results
write.csv(as.data.frame(res_ord), file= paste0("DE_results-", comparison, ".csv"))

# write csv for significant results
write.csv(as.data.frame(res_order_FDR_05), file= paste0("DE_results.FDR.0.05-", comparison, ".csv"))



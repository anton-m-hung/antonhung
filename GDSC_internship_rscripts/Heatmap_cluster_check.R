library(stringr)

setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~
Pdk <- read.csv("Files/DE_results.FDR.0.05-Pdk.v.EV.csv", row.names = 1)

Pdp <- read.csv("Files/DE_results.FDR.0.05-Pdp.v.EV.csv", row.names = 1)

Pdp.V.Pdk <- read.csv("Files/DE_results.FDR.0.05-Pdp.v.Pdk.csv", stringsAsFactors=F)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~
# For Pdk.v.EV
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
dds <- readRDS(paste0("files/", "DESeq2.rds"))

# take the regularized log
rld <- rlog(dds, blind = FALSE)

#isolate samples from groups of interest
ind_to_keep <- c(which(colData(rld)$tx.group=="Pdk"), which(colData(rld)$tx.group=="EV"))

# set up gene expression matrix
mat1 <- assay(rld)[rownames(Pdk), ind_to_keep]

# scale matrix by each col. values
mat_scaled = t(apply(mat1, 1, scale))

# set up colors for heatmap
col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(11, "Paired")

# subset coldata for samples in untx and ex groups
colData_sub <- colData(dds)[ind_to_keep, ]

# set up annotation bar for samples
ha1 = HeatmapAnnotation(Group = colData_sub$tx.group,
                        col = list(Group = c("Pdk" = cols1[1], "EV" = cols1[2])),
                        show_legend = TRUE)

# se up column annotation labels (samples)
ha = columnAnnotation(x = anno_text(rownames(colData_sub),
                                    which="column", rot = 45,
                                    gp = gpar(fontsize = 10)))

# generate heatmap object
ht1 = Heatmap(mat_scaled, name = "Expression", col = col,
              top_annotation = c(ha1),
              bottom_annotation = c(ha),
              show_row_names = FALSE,
              show_column_names = FALSE)

ppi=300
png(paste0("files/heatmap_Pdk.v.Ev.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = "Pdk vs EV - Hierachical clustering of DEGs (padj<0.05)")
dev.off()


# ~~~~~~~~~~~~~~~~~~~~~~~~~~
# For Pdp.v.EV
# ~~~~~~~~~~~~~~~~~~~~~~~~~~

#isolate samples from groups of interest
ind_to_keep <- c(which(colData(rld)$tx.group=="Pdp"), which(colData(rld)$tx.group=="EV"))

# set up gene expression matrix
mat1 <- assay(rld)[rownames(Pdp), ind_to_keep]

# scale matrix by each col. values
mat_scaled = t(apply(mat1, 1, scale))

# set up colors for heatmap
col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(11, "Paired")

# subset coldata for samples in untx and ex groups
colData_sub <- colData(dds)[ind_to_keep, ]

# set up annotation bar for samples
ha1 = HeatmapAnnotation(Group = colData_sub$tx.group,
                        col = list(Group = c("Pdp" = cols1[1], "EV" = cols1[2])),
                        show_legend = TRUE)

# se up column annotation labels (samples)
ha = columnAnnotation(x = anno_text(rownames(colData_sub),
                                    which="column", rot = 45,
                                    gp = gpar(fontsize = 10)))

# generate heatmap object
ht1 = Heatmap(mat_scaled, name = "Expression", col = col,
              top_annotation = c(ha1),
              bottom_annotation = c(ha),
              show_row_names = FALSE,
              show_column_names = FALSE)

ppi=300
png(paste0("files/heatmap_Pdp.v.Ev.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = "Pdp vs EV - Hierachical clustering of DEGs (padj<0.05)")
dev.off()


# ~~~~~~~~~~~~~~~~~~~~~~~~~~
# For Pdp.v.Pdk
# ~~~~~~~~~~~~~~~~~~~~~~~~~~

#isolate samples from groups of interest
ind_to_keep <- c(which(colData(rld)$tx.group=="Pdp"), which(colData(rld)$tx.group=="Pdk"))

# set up gene expression matrix
mat1 <- assay(rld)[Pdp.V.Pdk$X, ind_to_keep]

# scale matrix by each col. values
mat_scaled = t(apply(mat1, 1, scale))
rownames(mat_scaled) <- Pdp.V.Pdk$gene

# set up colors for heatmap
col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(11, "Paired")

# subset coldata for samples in untx and ex groups
colData_sub <- colData(dds)[ind_to_keep, ]

# set up annotation bar for samples
ha1 = HeatmapAnnotation(Group = colData_sub$tx.group,
                        col = list(Group = c("Pdp" = cols1[1], "Pdk" = cols1[2])),
                        show_legend = TRUE)

# se up column annotation labels (samples)
ha = columnAnnotation(x = anno_text(rownames(colData_sub),
                                    which="column", rot = 45,
                                    gp = gpar(fontsize = 10)))

# generate heatmap object
ht1 = Heatmap(mat_scaled, name = "Expression", col = col,
              top_annotation = c(ha1),
              bottom_annotation = c(ha),
              show_row_names = TRUE,
              show_column_names = FALSE)

ppi=300
png(paste0("files/heatmap_Pdp.v.Pdk.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = "Pdp vs Pdk - Hierachical clustering of DEGs (padj<0.05)")
dev.off()



################ Combine all DE genes

all_genes <- union(rownames(Pdk), rownames(Pdp))
mat1 <- assay(rld)[all_genes,]
mat_scaled = t(apply(mat1, 1, scale))
colData <- colData(dds)

col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(11, "Paired")

ha1 = HeatmapAnnotation(Group = colData$tx.group,
                        col = list(Group = c("Pdp"=cols1[1], "EV"=cols1[2], "Pdk"=cols1[3])),
                        show_legend = TRUE)

ha = columnAnnotation(x = anno_text(rownames(colData),
                                    which="column", rot = 45,
                                    gp = gpar(fontsize = 10)))

# generate heatmap object
ht1 = Heatmap(mat_scaled, name = "Expression", col = col,
              top_annotation = c(ha1),
              bottom_annotation = c(ha),
              show_row_names = FALSE,
              show_column_names = FALSE,
              )

ppi=300
png(paste0("additional_plots/","heatmap_all_genes.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = str_wrap("Pdp and Pdk vs EV - Hierachical clustering of all genes that were differentially expressed against EV (padj<0.05)"))
dev.off()


################ Combine all DE genes but subset by fold change > 2

pdk_fc_1 <- Pdk[which(abs(Pdk$log2FoldChange) > 2),]
pdp_fc_1 <- Pdk[which(abs(Pdp$log2FoldChange) > 2),]

all_genes <- union(rownames(pdk_fc_1), rownames(pdp_fc_1))
mat1 <- assay(rld)[all_genes,]
mat_scaled = t(apply(mat1, 1, scale))
colData <- colData(dds)

col = colorRamp2(c(-3, 0, 3), c("blue", "white", "red"))
cols1 <- brewer.pal(11, "Paired")

ha1 = HeatmapAnnotation(Group = colData$tx.group,
                        col = list(Group = c("Pdp"=cols1[1], "EV"=cols1[2], "Pdk"=cols1[3])),
                        show_legend = TRUE)

ha = columnAnnotation(x = anno_text(rownames(colData),
                                    which="column", rot = 45,
                                    gp = gpar(fontsize = 10)))

# generate heatmap object
ht1 = Heatmap(mat_scaled, name = "Expression", col = col,
              top_annotation = c(ha1),
              bottom_annotation = c(ha),
              show_row_names = FALSE,
              show_column_names = FALSE,
              )

ppi=300
png(paste0("additional_plots/","heatmap_fc2_genes.png"), width=7.5*ppi, height=5*ppi, res=ppi)
draw(ht1, row_title = "Genes", column_title = str_wrap("Pdp and Pdk vs EV - Hierachical clustering of DE genes with a log2 fold change greater than 2"))
dev.off()

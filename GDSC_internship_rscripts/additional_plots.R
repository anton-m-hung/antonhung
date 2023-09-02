
source(paste0("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg/additional_plots/volcano.R"))

dir1 <- "additional_plots/"

setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")

########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# extract DE results 
########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~ PDK
comparison <- "Pdk.v.EV"
# dds <- readRDS(paste0("files/", "DESeq2.rds"))
res <- results(dds, alpha = 0.05, contrast = c("tx.group",'Pdk','EV'), altHypothesis = "greaterAbs")
res <- res[!is.na(res$padj),]

anno <- read.delim(paste0("files/", "GRCm38.p6_ensembl-97.txt"), stringsAsFactors = T, header = T)
mat1 <- match(rownames(res), anno$Gene.stable.ID)
table(is.na(mat1))
res$gene <- as.character(anno$Gene.name[mat1])
ppi=300

volcano_plot(dat = res, 
             out_dir = paste0(dir1), 
             out_name = paste0(comparison, "_volcano.png"), 
             title = paste0(comparison, " Differential gene expression"), 
             fc_line = 2,
             alpha = 0.05, 
             fc_label = 2, 
             alpha_label_no = 10
)



# ~~~~~~~~~ PDP
comparison <- "Pdp.v.EV"
# dds <- readRDS(paste0("files/", "DESeq2.rds"))
res <- results(dds, alpha = 0.05, contrast = c("tx.group",'Pdp','EV'), altHypothesis = "greaterAbs")
res <- res[!is.na(res$padj),]

anno <- read.delim(paste0("files/", "GRCm38.p6_ensembl-97.txt"), stringsAsFactors = T, header = T)
mat1 <- match(rownames(res), anno$Gene.stable.ID)
table(is.na(mat1))
res$gene <- as.character(anno$Gene.name[mat1])
ppi=300

volcano_plot(dat = res, 
             out_dir = paste0(dir1), 
             out_name = paste0(comparison, "_volcano.png"), 
             title = paste0(comparison, " Differential gene expression"), 
             fc_line = 2,
             alpha = 0.05, 
             fc_label = 2, 
             alpha_label_no = 10
)


######################### Pdp vs Pdk

comparison <- "Pdp.v.Pdk"
# dds <- readRDS(paste0("files/", "DESeq2.rds"))
res <- results(dds, alpha = 0.05, contrast = c("tx.group",'Pdp','Pdk'), altHypothesis = "greaterAbs")
res <- res[!is.na(res$padj),]

anno <- read.delim(paste0("files/", "GRCm38.p6_ensembl-97.txt"), stringsAsFactors = T, header = T)
mat1 <- match(rownames(res), anno$Gene.stable.ID)
table(is.na(mat1))
res$gene <- as.character(anno$Gene.name[mat1])
ppi=300

volcano_plot(dat = res, 
             out_dir = paste0(dir1), 
             out_name = paste0(comparison, "_volcano.png"), 
             title = paste0(comparison, " Differential gene expression"), 
             fc_line = 2,
             alpha = 0.05, 
             fc_label = 2, 
             alpha_label_no = 10
)

############### Normalized dds

norm_dds <- counts(dds, normalized=T)

weird_gene <- "ENSMUSG00000082969"

subset_dds <- norm_dds[weird_gene,]
subset_dds <- data.frame(sample = names(subset_dds),
                         counts = unname(subset_dds),
                         tx.group = c(rep("EV",4),rep("Pdk", 4),rep("Pdp",3)))
subset_dds <- subset_dds[c(1:7),]

png(paste0(dir1, "gene_Gm12630.png"), width=6*ppi, height=4*ppi, res=ppi)
ggplot(subset_dds, aes(x=tx.group, y=counts, col=tx.group)) +
  geom_jitter(size = 3, width = 0.1) +
  ggtitle("Expression pattern of gene Gm12630 in EV vs Pdk") +
  theme_light()
dev.off()

setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~
Pdk <- read.csv("Files/DE_results.FDR.0.05-Pdk.v.EV.csv")

Pdp <- read.csv("Files/DE_results.FDR.0.05-Pdp.v.EV.csv")

Pdp.V.Pdk <- read.csv("Files/DE_results.FDR.0.05-Pdp.v.Pdk.csv", stringsAsFactors=F)


# Counts at each log FC interval

interval_counts <- function(df) {
  up <- df[which(df$log2FoldChange > 0),]
  down <- df[which(df$log2FoldChange < 0),]
  
  print(paste0("upregulated, FC < 1: ", nrow(up[which(up$log2FoldChange < 1),])))
  print(paste0("upregulated, FC < 2: ", nrow(up[which(up$log2FoldChange > 1 & up$log2FoldChange < 2),])))
  print(paste0("upregulated, FC > 2: ", nrow(up[which(up$log2FoldChange > 2),])))
  
  print(paste0("downregulated, FC < 1: ", nrow(down[which(abs(down$log2FoldChange) < 1),])))
  print(paste0("downregulated, FC < 2: ", nrow(down[which(abs(down$log2FoldChange) > 1 & abs(down$log2FoldChange) < 2),])))
  print(paste0("downregulated, FC > 2: ", nrow(down[which(abs(down$log2FoldChange) > 2),])))
  
}

interval_counts(Pdk)
interval_counts(Pdp)



#####################
## Creating spreadsheets of overlapping and unique genes
#####################

pdk_up <- Pdk[Pdk$log2FoldChange>0,]
pdp_up <- Pdp[Pdp$log2FoldChange>0,]

pdk_down <- Pdk[Pdk$log2FoldChange<0,]
pdp_down <- Pdp[Pdp$log2FoldChange<0,]


my_merge <- function(df1, df2, all, up_or_down, intersection_or_unique) {
  res <- merge(df1, df2, by = c("X","gene","chr","start","end","strand"), suffixes = c(".PDK_V_EV", ".PDP_V_EV"), all = all)
  print(dim(res))
  print(names(res))
  write.csv(res, file = paste0("intersecting_and_unique_genes/res_", up_or_down, "_", intersection_or_unique, ".csv"), row.names = F)
}

my_merge(Pdk, Pdp, TRUE, "all", "union")
my_merge(pdk_up, pdp_up, TRUE, "up", "union")
my_merge(pdk_down, pdp_down, TRUE, "down", "union")

my_merge(Pdk, Pdp, FALSE, "all", "inter")
my_merge(pdk_up, pdp_up, FALSE, "up", "inter")
my_merge(pdk_down, pdp_down, FALSE, "down", "inter")

######### UNIQUE
shared_genes <- intersect(Pdk$X, Pdp$X)
res <- Pdk[-which(Pdk$X %in% shared_genes), ]
write.csv(res, file = paste0("intersecting_and_unique_genes/res_pdk_all_unique.csv"), row.names = F)

res <- Pdp[-which(Pdp$X %in% shared_genes), ]
write.csv(res, file = paste0("intersecting_and_unique_genes/res_pdp_all_unique.csv"), row.names = F)

shared_genes <- intersect(pdk_up$X, pdp_up$X)
res <- pdk_up[-which(pdk_up$X %in% shared_genes), ]
write.csv(res, file = paste0("intersecting_and_unique_genes/res_pdk_up_unique.csv"), row.names = F)

res <- pdp_up[-which(pdp_up$X %in% shared_genes), ]
write.csv(res, file = paste0("intersecting_and_unique_genes/res_pdp_up_unique.csv"), row.names = F)

shared_genes <- intersect(pdk_down$X, pdp_down$X)
res <- pdk_down[-which(pdk_down$X %in% shared_genes), ]
write.csv(res, file = paste0("intersecting_and_unique_genes/res_pdk_down_unique.csv"), row.names = F)

res <- pdp_down[-which(pdp_down$X %in% shared_genes), ]
write.csv(res, file = paste0("intersecting_and_unique_genes/res_pdp_down_unique.csv"), row.names = F)


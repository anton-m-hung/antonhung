
# install.packages("VennDiagram")
library(VennDiagram)
dir1 <- "files/"
dir2 <- "figures/"
setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")

pdk <- read.csv(paste0(dir1, "DE_results.FDR.0.05-Pdk.v.EV.csv"), stringsAsFactors=F)
pdp <- read.csv(paste0(dir1, "DE_results.FDR.0.05-Pdp.v.EV.csv"), stringsAsFactors=F)

pdk_up <- pdk[pdk$log2FoldChange>0,]
pdp_up <- pdp[pdp$log2FoldChange>0,]

pdk_down <- pdk[pdk$log2FoldChange<0,]
pdp_down <- pdp[pdp$log2FoldChange<0,]

library(RColorBrewer)
myCol <- brewer.pal(3, "Pastel2")

venn.diagram(
  x = list(pdk_down$X, pdp_down$X),
  category.names = c("Pdk_vs_EV" , "Pdp_vs_EV"),
  filename = 'venn_diagram_downreg_genes.png',
  output=TRUE,
  margin=0.075,
  cex = 2.5,
  cat.cex = 2,

  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol[1:2])

venn.diagram(
  x = list(pdk_up$X, pdp_up$X),
  category.names = c("Pdk_vs_EV" , "Pdp_vs_EV"),
  filename = 'venn_diagram_upreg_genes.png',
  output=TRUE,
  margin=0.075,
  cex = 2.5,
  cat.cex = 2,
  
  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol[1:2])

venn.diagram(
  x = list(pdk$X, pdp$X),
  category.names = c("Pdk_vs_EV" , "Pdp_vs_EV"),
  filename = 'venn_diagram_all_genes.png',
  output=TRUE,
  margin=0.075,
  cex = 2.5,
  cat.cex = 2,
  
  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol[1:2])


############ Three-way venn diagram
Pdp.V.Pdk <- read.csv(paste0(dir1, "DE_results.FDR.0.05-Pdp.v.Pdk.csv"), stringsAsFactors=F)
both_up <- Pdp.V.Pdk[Pdp.V.Pdk$log2FoldChange>0,]
both_down <- Pdp.V.Pdk[Pdp.V.Pdk$log2FoldChange<0,]

venn.diagram(
  x = list(pdk$X, pdp$X, Pdp.V.Pdk$X),
  category.names = c("EV_vs_Pdk" , "EV_vs_Pdp", "Pdp_vs_Pdk"),
  filename = 'venn_diagram_three_way_all.png',
  output=TRUE,
  margin=0.075,
  cex = 2.5,
  cat.cex = 2,
  cat.pos = c(-40, 40, 0),
  
  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol[1:3])  

venn.diagram(
  x = list(pdk_up$X, pdp_up$X, both_up$X),
  category.names = c("EV_vs_Pdk" , "EV_vs_Pdp", "Pdp_vs_Pdk"),
  filename = 'venn_diagram_three_way_up.png',
  output=TRUE,
  margin=0.075,
  cex = 2.5,
  cat.cex = 2,
  
  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol[1:3])  

venn.diagram(
  x = list(pdk_down$X, pdp_down$X, both_down$X),
  category.names = c("EV_vs_Pdk" , "EV_vs_Pdp", "Pdp_vs_Pdk"),
  filename = 'venn_diagram_three_way_down.png',
  output=TRUE,
  margin=0.075,
  cex = 2.5,
  cat.cex = 2,
  
  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol[1:3])  
# install.packages("scales")
library(scales)
library(ggplot2)


setwd("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/deg")


############### Normalized dds

data <- read.csv("/Volumes/rc/lab/G/GMBSR_bioinfo/Labs/Usherwood/rnaseq-7-20-23/analysis_re/featurecounts/featurecounts.readcounts_tpm.ann.tsv", sep="\t")
data <- data[,c(2, 8:17, 19)]

tx.group <- c(rep("EV", 4), rep("PDK", 4), rep("PDP", 3))
ppi = 300



plot_gene <- function(gene_name, tx_groups) {

  output_filename <- paste0(gene_name, "_", tx_groups[1], "_v_", tx_groups[2])
  which_samples <- which(tx.group %in% tx_groups)
  subset_data <- data[which(data$Gene.Name == gene_name), 
                      which_samples+1]
  
  subset_dds <- data.frame(sample = names(subset_data),
                           counts = as.numeric(unlist(subset_data)),
                           tx.group = tx.group[which_samples])
  if (gene_name == "Gm12630"){
    subset_dds$counts = subset_dds$counts + 0.5
  }
  
  p <- ggplot(subset_dds, aes(x=tx.group, y=counts, col=tx.group)) +
    geom_jitter(size = 3, width = 0.1, height=0) +
    ggtitle(gene_name) +
    
    # geom_text(vjust=1.7, size=3,aes(label = ifelse(
    #   sample %in% c("Pdp1.4"), sample, ''))) +
    scale_y_continuous(trans = "log2") +
    theme_light() +
    theme(legend.position="none")

  ggsave(filename = paste0("additional_plots/", output_filename, "_plot.png"),
         plot = p, width = 3, height = 4, units = "in", dpi = ppi)
}


######## Gene Gm12630 
# did this one separately because I wanted to label some points
which_samples <- which(tx.group %in% c("EV", "PDK"))
subset_data <- data[which(data$Gene.Name == "Gm12630"), 
                    which_samples+1]

subset_dds <- data.frame(sample = names(subset_data),
                         counts = as.numeric(unlist(subset_data)),
                         tx.group = tx.group[which_samples])

png(paste0("additional_plots/Gm12630_plot.png"), width=3*ppi, height=4*ppi, res=ppi)
ggplot(subset_dds, aes(x=tx.group, y=counts, col=tx.group)) +
  geom_jitter(size = 3, width = 0.1) +
  ggtitle("Gm12630") +
  geom_text(vjust=1.7, size=3,aes(label = ifelse(
    sample %in% c("EV3","EV4"), sample, ''))) +
  scale_y_continuous(trans = "log2") +
  theme_light() +
  theme(legend.position="none")
dev.off()

subset_dds$sample[which(subset_dds$counts > 100)]
# [1] "EV3"    "EV4"
# added these labels to the plot above



plot_gene("Bax", c("EV", "PDK"))
plot_gene("Metrn", c("EV", "PDK"))

plot_gene("Pdp1", c("EV", "PDP"))
plot_gene("Gm17383", c("EV", "PDP"))

plot_gene("Pdp1", c("PDP", "PDK"))
plot_gene("Gm12630", c("PDP", "PDK"))

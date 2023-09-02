
ma_plot <- function(res_df, lfc_type, out_dir, out_name, title, alpha, fc_label, abs_xlab_thres){
  ####

  #Description: Generates a MA plot from standard results table output from DESeq2

  # Variables:
    # dat: (data frame) table output by results() from DESeq2
    # lfc_type: (chara) type of fold change value being supplied, either "shrunk" or "raw"
    # out_dir: (chara) path to output file name 
    # out_name: (chara) output file name
    # title: (chara) title to be shown on plot
    # aplha: (numeric) significance level to use for highlighting indvidual points/genes in red
    # abs_xlab_thres: (numeric) minimum absolute fold change value at which to begin labelling gene names

  # Output: .png file of volcano plot 
  ###

  res_df <- as.data.frame(res_df)  

  # replace logfc values if shrunk optopn for lfc_type specified 
  if(lfc_type=="shrunk"){
    res_df$log2FoldChange <- res_df$lfc_shrunk
  } else {
    res_df$log2FoldChange <- res_df$log2FoldChange
  }
  
  # set colors of points to plot 
  res_df$col <- NA
  res_df$col[res_df$padj<alpha & abs(res_df$log2FoldChange)>abs_xlab_thres] <- "red"
  res_df$col[is.na(res_df$col)] <- "black"
  
  # calculate limits to set for y axis   
  cap_pos_yvalue <- max(abs(res_df$log2FoldChange))+0.4
  cap_neg_yvalue <- cap_pos_yvalue/-1

  ppi=300
  # png(paste0(out_dir, out_name), width=14*ppi, height=8.75*ppi, res=ppi)
  p = ggplot(res_df, aes(x = baseMean, y = log2FoldChange, fill=col, size = -log10(padj))) +
    geom_point(alpha = 0.5, shape = 21)  + 
    scale_x_continuous(trans='log2') + 
    ylab("(shrunk) Log2 fold change") + xlab("Mean normalized counts (Log2, SCT)") +
    geom_hline(yintercept = 0, color = "blue", linetype = "dashed", size = 0.4) + 
    labs(size = expression("-log"[10]*" adj. P-value)"), fill = "sig") +
    scale_size(range = c(1, 12)) +
    scale_fill_manual(name = " ",
      values = c("black", "indianred"), 
      labels = c("Not. sig.", paste0("Adj. P<0.05 & LFC > ", abs_xlab_thres))) +
    ggtitle(title) + 
    scale_size(name = "-log10 P-value", range = c(0.5, 12)) + 
    ylim(cap_neg_yvalue, cap_pos_yvalue) +
    geom_label_repel(data = subset(res_df, log2FoldChange > abs_xlab_thres & padj < alpha), aes(label = gene), 
                     box.padding   = 0.35,
                     nudge_x = 0.05,
                     nudge_y = 0.04,
                     point.padding = 0.5,
                     label.size = 0.15,
                     segment.size = 0.3, fill = "grey90", 
                     segment.color = 'grey50', size = 3.5) +
    geom_label_repel(data = subset(res_df, log2FoldChange < -abs_xlab_thres & padj < alpha), aes(label = gene), 
                     box.padding   = 0.35,
                     nudge_x = 0.05,
                     nudge_y = -0.04,
                     point.padding = 0.5,
                     label.size = 0.15,
                     segment.size = 0.3, fill = "grey90",
                     segment.color = 'grey50', size = 3.5) +     
    geom_vline(xintercept = fc_label, colour = "black", linetype="dotted") + 
    geom_vline(xintercept = -fc_label, colour = "black", linetype="dotted") + 
    theme(legend.key.size = unit(1, "cm"),
      legend.background=element_blank(),
      panel.border = element_rect(fill = NA, colour = "black", size = 0.6, linetype = "solid"), 
      panel.background = element_rect(fill = "#F0ECEA"),
      title = element_text(colour="black", size = 20),
      axis.text.x=element_text(colour="black", size = 14, hjust = 1), 
      axis.text.y=element_text(colour="black", size = 14), 
      axis.title.x=element_text(colour="black", size = 16), 
      axis.title.y=element_text(colour="black", size = 16), 
      legend.text = element_text(colour="black", size = 20), 
      legend.title = element_text(colour="black", size = 20)) +
    guides(size=guide_legend(override.aes = list(fill="black", alpha=1)))
  return(p)
  # dev.off()  
}
  
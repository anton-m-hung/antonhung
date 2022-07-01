
##########################################################################

# MODIFIED BEER DATAFRAME
setwd("/Users/anton/Desktop/McCord_MermutLab/Patient_results")
modified.path <- "./intralipid_modifiedbeer/results"

modified.files <- list.files(path=modified.path, pattern="*.csv", full.names=FALSE, recursive=FALSE)
modified.files.filenames <- tools::file_path_sans_ext(modified.files)
modified.files.filenames <- gsub('results_', '', modified.files.filenames)

modified.data <- data.frame()
for (i in seq_along(modified.files)) {
  filename = modified.files[i]
  # Read data
  temp <- read.csv(file.path(modified.path,filename))
  modified.data <- rbind(modified.data,temp)
}
row.names(modified.data) <- modified.files.filenames

modified.data <- as.data.frame(cbind(modified.data$attenuation_coefficient,c('1%','1%','1%','1%','1%',
                                                                             '4%','4%','4%','4%','4%',
                                                                             '13%','13%','13%','13%','13%',
                                           '20%','20%','20%','20%','20%')))
modified.data <- as.data.frame(cbind(modified.data,as.numeric(c(1,1,1,1,1,
                                                            4,4,4,4,4,
                                                            13,13,13,13,13,
                                                            20,20,20,20,20))))

colnames(modified.data) <- c('attenuation.coefficient','intralipid.concentration','concentration.num')
modified.data$intralipid.concentration <- as.factor(modified.data$intralipid.concentration)
modified.data$attenuation.coefficient <- as.numeric(modified.data$attenuation.coefficient)

# SIMPLE BEER DATAFRAME
simple.path <- "./intralipid_simplebeer/results"

simple.files <- list.files(path=simple.path, pattern="*.csv", full.names=FALSE, recursive=FALSE)
simple.files.filenames <- tools::file_path_sans_ext(simple.files)
simple.files.filenames <- gsub('results_', '', simple.files.filenames)

simple.data <- data.frame()
for (i in seq_along(simple.files)) {
  filename = simple.files[i]
  # Read data
  temp <- read.csv(file.path(simple.path,filename))
  simple.data <- rbind(simple.data,temp)
}
row.names(simple.data) <- simple.files.filenames

simple.data <- as.data.frame(cbind(simple.data$attenuation_coefficient,c('1%','1%','1%','1%','1%',
                                                                         '4%','4%','4%','4%','4%',
                                                                             '13%','13%','13%','13%','13%',
                                                                             '20%','20%','20%','20%','20%')))

simple.data <- as.data.frame(cbind(simple.data,as.numeric(c(1,1,1,1,1,
                                                                         4,4,4,4,4,
                                                                         13,13,13,13,13,
                                                                         20,20,20,20,20))))
colnames(simple.data) <- c('attenuation.coefficient','intralipid.concentration','concentration.num')
simple.data$intralipid.concentration <- as.factor(simple.data$intralipid.concentration)
simple.data$attenuation.coefficient <- as.numeric(simple.data$attenuation.coefficient)

simple.data$attenuation.coefficient <- simple.data$attenuation.coefficient*2
modified.data$attenuation.coefficient <- modified.data$attenuation.coefficient*2

### PLOTTING
library(RColorBrewer)
library(tidyverse)

# my.plot <- ggplot(data=modified.data,  aes(x=fct_inorder(modified.data[,2]), y=modified.data[,1], colour=intralipid.concentration)) +
#   labs(title="Attenuation coefficients for varying intralipid concentrations") +
#   xlab("Intralipid concentration (%)") +
#   ylab(expression(paste("Attenuation coefficient (mm"^"-1",")"))) +
#   geom_jitter(show.legend=FALSE, size = 2, width=0.1) +
#   geom_jitter(data=simple.data, show.legend=FALSE, size = 2, width=0.1) +
#   scale_colour_manual(values = c("#fecc5c", "#f03b20", "#bd0026", "#fd8d3c")) +
#   ylim(0.1,3) +
#   theme_light()
# my.plot

my.plot <- ggplot(data=modified.data,  aes(x=(concentration.num), y=attenuation.coefficient)) +
  labs(title="Attenuation coefficients for varying intralipid concentrations") +
  xlab("Intralipid concentration (% w/v)") +
  ylab(expression(paste("Attenuation coefficient (mm"^"-1",")"))) +
  geom_jitter(size = 2, width=0.1, aes(colour="Modified Beer")) +
  geom_jitter(data=simple.data, size = 2, width=0.5, aes(colour="Simple Beer")) +
  # scale_colour_manual(values = c("#fecc5c", "#f03b20", "#bd0026", "#fd8d3c")) +
  ylim(0.3,5.5) +
  theme_light() +
  labs(color="Computational Model")
my.plot




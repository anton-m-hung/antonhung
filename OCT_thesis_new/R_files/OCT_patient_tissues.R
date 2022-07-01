### SIMPLE BEER
# HYPERKERATOSIS DATAFRAME
setwd("/Users/anton/Desktop/McCord_MermutLab/Patient_results")
sim.hyper.path <- "./hyperkeratosis_simplebeer_20220401/results"
sim.hyper.files <- list.files(path=sim.hyper.path, pattern="*.csv", full.names=TRUE, recursive=FALSE)
sim.hyper.files.filenames <- tools::file_path_sans_ext(sim.hyper.files)
sim.hyper.files.filenames <- gsub('results_', '', sim.hyper.files.filenames)

sim.hyper.data <- data.frame()
for (i in seq_along(sim.hyper.files)) {
  filename = sim.hyper.files[i]
  # Read data
  temp <- read.csv(filename)
  sim.hyper.data <- rbind(sim.hyper.data,temp)
}

row.names(sim.hyper.data) <- basename(sim.hyper.files.filenames)


# CANCER DATAFRAME
sim.cancer.path <- "./SCC_simplebeer_20220401/results"
sim.cancer.files <- list.files(path=sim.cancer.path, pattern="*.csv", full.names=TRUE, recursive=FALSE)
sim.cancer.files.filenames <- tools::file_path_sans_ext(sim.cancer.files)
sim.cancer.files.filenames <- gsub('results_', '', sim.cancer.files.filenames)

sim.cancer.data <- data.frame()
for (i in seq_along(sim.cancer.files)) {
  filename = sim.cancer.files[i]
  # Read data
  temp <- read.csv(filename)
  sim.cancer.data <- rbind(sim.cancer.data,temp)
}

row.names(sim.cancer.data) <- basename(sim.cancer.files.filenames)

### MODIFIED BEER
# HYPERKERATOSIS
library(R.matlab)
hyper.mat.path <- "./03_25_modifiedbeer/hyperkeratosis_modifiedbeer_20220325/matrices"
hyper.mat.files <- list.files(path=hyper.mat.path, pattern="*.mat", full.names=TRUE, recursive=FALSE)
hyper.mat.files.filenames <- list.files(path=hyper.mat.path, pattern="*.mat", full.names=FALSE, recursive=FALSE)
hyper.mat.files.filenames <- tools::file_path_sans_ext(hyper.mat.files.filenames)

# Putting all mu matrices into a list (a list of matrices)
mod.hyper.data <- list()
for (i in seq_along(hyper.mat.files)) {
  filename = hyper.mat.files[i]
  # Read data in
  temp <- readMat(filename)
  mod.hyper.data[i] <- temp
}
names(mod.hyper.data) <- hyper.mat.files.filenames

# using coordinates file to get an average attenuation coefficient
mod.hyper.averages <- vector()
for (i in (names(mod.hyper.data))) {
  x.range <- round(sim.hyper.data[i,]$x1/5):round(sim.hyper.data[i,]$x2/5)
  y.range <- round(sim.hyper.data[i,]$y1/5):round(sim.hyper.data[i,]$y2/5)
  
  temp.mean <- mean(mod.hyper.data[[i]][y.range,x.range], na.rm=TRUE)
  mod.hyper.averages[i] = temp.mean
}

mod.hyper.df <- as.data.frame(mod.hyper.averages,
                                   row.names=names(mod.hyper.averages))
colnames(mod.hyper.df) <- "attenuation_coefficient"

# CANCER
cancer.mat.path <- "./03_25_modifiedbeer/SCC_modifiedbeer_20220325/matrices"
cancer.mat.files <- list.files(path=cancer.mat.path, pattern="*.mat", full.names=TRUE, recursive=FALSE)
cancer.mat.files.filenames <- list.files(path=cancer.mat.path, pattern="*.mat", full.names=FALSE, recursive=FALSE)
cancer.mat.files.filenames <- tools::file_path_sans_ext(cancer.mat.files.filenames)

# Putting all mu matrices into a list (a list of matrices)
mod.cancer.data <- list()
for (i in seq_along(cancer.mat.files)) {
  filename = cancer.mat.files[i]
  # Read data in
  temp <- readMat(filename)
  mod.cancer.data[i] <- temp
}
names(mod.cancer.data) <- cancer.mat.files.filenames

# using coordinates file to get an average attenuation coefficient
mod.cancer.averages <- vector()
for (i in (names(mod.cancer.data))) {
  x.range <- round(sim.cancer.data[i,]$x1/5):round(sim.cancer.data[i,]$x2/5)
  y.range <- round(sim.cancer.data[i,]$y1/5):round(sim.cancer.data[i,]$y2/5)
  
  temp.mean <- mean(mod.cancer.data[[i]][y.range,x.range], na.rm=TRUE)
  mod.cancer.averages[i] = temp.mean
}

mod.cancer.df <- as.data.frame(mod.cancer.averages,
                              row.names=names(mod.cancer.averages))
colnames(mod.cancer.df) <- "attenuation_coefficient"

### Multiply attenuation coefficients by 2
mod.cancer.df$attenuation_coefficient <- mod.cancer.df$attenuation_coefficient*2
mod.hyper.df$attenuation_coefficient <- mod.hyper.df$attenuation_coefficient*2

rows.to.remove <- c('P116_7','P116_8','P116_9')
sim.cancer.data.remove <- sim.cancer.data[!(row.names(sim.cancer.data) %in% rows.to.remove), ]

rows.to.remove <- c('P047S_1','P047S_2','P047S_3')
sim.hyper.data.remove <- sim.hyper.data[!(row.names(sim.hyper.data) %in% rows.to.remove), ]


shapiro.test(sim.cancer.data$attenuation_coefficient)
shapiro.test(sim.hyper.data$attenuation_coefficient)
t.test(sim.cancer.data$attenuation_coefficient, sim.hyper.data$attenuation_coefficient)

shapiro.test(sim.cancer.data.remove$attenuation_coefficient)
shapiro.test(sim.hyper.data.remove$attenuation_coefficient)
t.test(sim.cancer.data.remove$attenuation_coefficient, sim.hyper.data.remove$attenuation_coefficient)

### PLOTTING
# scale_colour_manual(values = c("#fecc5c", "#f03b20", "#bd0026", "#fd8d3c")) +
  
# SIMPLE - cancer vs non-cancer
library(ggplot2)
density.overlay <-  ggplot() + 
  geom_density(aes(x=attenuation_coefficient, fill="Cancer"), data=sim.cancer.data["attenuation_coefficient"], size=0,alpha=.4) +
  geom_density(aes(x=attenuation_coefficient, fill="Hyperkeratosis"), data=sim.hyper.data["attenuation_coefficient"],size=0,alpha=.4) +
  scale_x_continuous(breaks = seq(0, 7.5, 1), limits=c(1,7)) +
  ggtitle("Simple beer: attenuation coefficient values for cancer vs hyperkeratosis") + 
  labs(y="Frequency",   x = (expression(paste("Attenuation coefficient (mm"^"-1",")")))) +
  labs(fill="Patient Diagnosis") +
  theme_light()
density.overlay

library(ggplot2)
density.overlay <-  ggplot() + 
  geom_density(aes(x=attenuation_coefficient, fill="Cancer"), data=sim.cancer.data.remove["attenuation_coefficient"], size=0,alpha=.4) +
  geom_density(aes(x=attenuation_coefficient, fill="Hyperkeratosis"), data=sim.hyper.data.remove["attenuation_coefficient"],size=0,alpha=.4) +
  scale_x_continuous(breaks = seq(0, 7.5, 1), limits=c(1,7)) +
  ggtitle("Simple beer: attenuation coefficient values for cancer vs hyperkeratosis") + 
  labs(y="Frequency",   x = (expression(paste("Attenuation coefficient (mm"^"-1",")")))) +
  labs(fill="Patient Diagnosis") +
  theme_light()
density.overlay

# MODIFIED - cancer vs non-cancer
density.overlay <-  ggplot() + 
  geom_density(aes(x=attenuation_coefficient, fill="Cancer"), data=mod.cancer.df["attenuation_coefficient"], size=0,alpha=.4) +
  geom_density(aes(x=attenuation_coefficient, fill="Hyperkeratosis"), data=mod.hyper.df["attenuation_coefficient"],size=0,alpha=.4) +
  scale_x_continuous(breaks = seq(0, 7.5, 1), limits=c(1,7)) +
  ggtitle("Modified beer: attenuation coefficient values for cancer vs hyperkeratosis") + 
  labs(y="Frequency",   x = (expression(paste("Attenuation coefficient (mm"^"-1",")")))) +
  labs(fill="Patient Diagnosis") +
  theme_light()
density.overlay

# HYPERKERATOSIS - simple vs modified
density.overlay <-  ggplot() + 
  geom_density(aes(x=attenuation_coefficient, fill="Simple Beer"), data=sim.hyper.data["attenuation_coefficient"], size=0,alpha=1) +
  geom_density(aes(x=attenuation_coefficient, fill="Modified Beer"), data=mod.hyper.df["attenuation_coefficient"],size=0,alpha=0.6) +
  scale_x_continuous(breaks = seq(0, 7.5, 1), limits=c(1,7)) +
  ggtitle("Simple vs Modified Beer for hyperkeratosis") + 
  labs(y="Frequency",   x = (expression(paste("Attenuation coefficient (mm"^"-1",")")))) +  
  theme_classic() +
  labs(fill="Computational Model")
density.overlay

# CANCER - simple vs modified
density.overlay <-  ggplot() + 
  geom_density(aes(x=attenuation_coefficient, fill="Simple Beer"), data=sim.cancer.data["attenuation_coefficient"], size=0,alpha=1) +
  geom_density(aes(x=attenuation_coefficient, fill="Modified Beer"), data=mod.cancer.df["attenuation_coefficient"],size=0,alpha=0.6) +
  scale_x_continuous(breaks = seq(0, 7.5, 1), limits=c(1,7)) +
  ggtitle("Simple vs Modified Beer for cancer") + 
  labs(y="Frequency",   x = (expression(paste("Attenuation coefficient (mm"^"-1",")")))) +  
  theme_classic() +
  labs(fill="Computational Model")
density.overlay











### The following lines are just test code that didn't work

# histogram of SCC attenuation coefficients
library(tidyverse)
Q2.hist <- ggplot(data=SCC.data, aes(x=attenuation_coefficient)) + 
  geom_histogram(binwidth = 0.1, fill="blue") +
  scale_x_continuous(breaks = seq(0, 3, 0.25), limits=c(1,3)) +
  ggtitle("Attenuation coefficients for cancerous tissues") +
  labs(y="Frequency", x="Attenuation coefficient (mm^-1)") +
  theme_light()
Q2.hist

Q2.hist <- ggplot(data=hyperkeratosis.data, aes(x=attenuation_coefficient)) + 
  geom_histogram(binwidth = 0.1, fill="red") +
  scale_x_continuous(breaks = seq(0, 3, 0.25), limits=c(1,3)) +
  ggtitle("Attenuation coefficients for hyperkeratosis tissues") +
  labs(y="Frequency", x="Attenuation coefficient (mm^-1)") +
  theme_light()
Q2.hist

SCC.tmpvec <- SCC.data$attenuation_coefficient
SCC.tmpvec[53] <- NA
my.df <- as.data.frame(cbind(hyperkeratosis.data$attenuation_coefficient, SCC.tmpvec))
colnames(my.df) <- c("hyperkeratosis",'cancer')

density.overlay <- ggplot(my.df) +
  geom_density(aes(x=hyperkeratosis), colour="red") +
  geom_density(aes(x=cancer), colour = "blue") +
  scale_x_continuous(breaks = seq(0, 3, 0.25)) +
  labs(y="Frequency",   x = (expression(paste("Attenuation coefficient (mm"^"-1",")")))) +
  theme_classic()
density.overlay

colnames(my.df) <- c("hyperkeratosis",'cancer')
# t-test
shapiro.test(my.df$hyperkeratosis)
shapiro.test(my.df$cancer)
t.test(my.df$hyperkeratosis, my.df$cancer)

############
# Lygodium_spore_analysis.R
# Jessie Pelosi
# Last modified Jan 4, 2024 
############

library(readxl)
library(ggplot2)
library(dplyr)
library(geiger)
library(ape)
library(ggtree)
library(ggstance)
library(phytools)
library(PairedData)
library(ggpubr)

spore_data <- read_excel("../spores/spore_measurements.xlsx", na = "Unknown")

# Generate df for spore area only 
spore_area <- spore_data %>% 
  filter(Metric == "Area") %>% 
  select(Sample, ResolvedID, Measurement, Metric, Spore, `Ploidy from Chrm`, `Inferred Ploidy`)

ggplot(data = spore_area, mapping = aes(x=reorder(ResolvedID, Measurement), y = Measurement)) + 
  geom_boxplot() + theme_classic() + theme(axis.text.x = element_text(angle=45, hjust = 1))

ggsave("Lygodium_spore_area.pdf", width = 10, height = 7)

ggplot(data = spore_area, mapping = aes(x=reorder(ResolvedID, Measurement), y = Measurement, fill = `Inferred Ploidy`)) + 
  geom_boxplot() + theme_classic() + theme(axis.text.x = element_text(angle=45, hjust = 1))

spore_area_sum <- spore_area %>% 
  group_by(ResolvedID) %>% 
  summarize(avg = mean(Measurement), min = min(Measurement), max = max(Measurement), ResolvedID) %>% 
  distinct()

# Generate df for spore length  
spore_length <- spore_data %>% 
  filter(Metric == "A" | Metric == "B" | Metric == "C") %>% 
  group_by(Sample, Spore) %>% 
  summarize(avg_length = mean(Measurement), ResolvedID) %>% 
  distinct()

ggplot(data = spore_length, mapping = aes(x = reorder(ResolvedID, avg_length), y = avg_length)) + geom_boxplot() + 
  theme_classic() + xlab("Species") + ylab(expression(paste("Length (",mu,"m)"))) +
  theme(axis.text.x = element_text(angle=45, hjust = 1))
  
spore_length_sum <- spore_length %>% 
  group_by(ResolvedID) %>% 
  summarize(avg = mean(avg_length), min = min(avg_length), max = max(avg_length), ResolvedID) %>% 
  distinct()

ggsave("Lygodium_spore_length.pdf", width = 10, height = 7)

# Generate df for spore width 
spore_width <- spore_data %>% 
  filter(Metric == "AA" | Metric == "BB" | Metric == "CC") %>% 
  group_by(Sample, Spore) %>% 
  summarize(avg_width = mean(Measurement), ResolvedID) %>% 
  distinct()

ggplot(data = spore_width, mapping = aes(x = reorder(ResolvedID, avg_width), y = avg_width)) + geom_boxplot() + theme_classic() +
  xlab("Species") + ylab(expression(paste("Length (",mu,"m)"))) + theme(axis.text.x = element_text(angle=45, hjust = 1))

ggsave("Lygodium_spore_width.pdf", width = 10, height = 7)

spore_width_sum <- spore_width %>% 
  group_by(ResolvedID) %>% 
  summarize(avg = mean(avg_width), min = min(avg_width), max = max(avg_width), ResolvedID) %>% 
  distinct()

#### Plot spore measures on phylogeny 

sp_tree <- read.tree("../GoFlag/PATE/trimmed_tree_rooted.tre")
plot(sp_tree, cex = 0.5)
plot(ladderize(sp_tree, right = F), cex=0.5)

data <- read.csv("SporeGenomeSize.csv")
data$SporeLength <- as.numeric(data$SporeLength)

rm_tips <- c("Lygodium_sp", "Lygodium_semihastatum")
trimmed_tree<-drop.tip(sp_tree,rm_tips)
plot(trimmed_tree)

p <- ggtree(trimmed_tree, ladderize = T, aes(color = SporeLength)) %<+% data
d<- p + geom_tiplab(offset = 6, hjust = 1)
d + scale_color_continuous(low='darkgreen', high='red') +
  theme(legend.position="right")


##### Compare ploidy and spore sizes 

## -- Get average point estimate for each taxa -- do t-test on this (four points)
## -- Or do bunch of replicates where you randomly just pick one

### Compare flexuosum to salicifolium 
spore_len_flex <- spore_length %>% 
  filter(ResolvedID == "Lygodium_flexuosum" | ResolvedID == "Lygodium_salicifolium")
t.test(avg_length ~ ResolvedID, data = spore_len_flex, alternative = "greater")
#t = 6.6111, df = 4.3686, p-value = 0.0009886

spore_area_flex <- spore_area %>% 
  filter(ResolvedID == "Lygodium_flexuosum" | ResolvedID == "Lygodium_salicifolium")
t.test(Measurement ~ ResolvedID, data = spore_area_flex, alternative = "greater")
#t = 6.7757, df = 3.5631, p-value = 0.001861

spore_wid_flex <- spore_width %>% 
  filter(ResolvedID == "Lygodium_flexuosum" | ResolvedID == "Lygodium_salicifolium")
t.test(avg_width ~ ResolvedID, data = spore_wid_flex, alternative = "greater")
#t = 5.2866, df = 4.57, p-value = 0.002102


## Compare palmatum and articulatum 
spore_len_art <- spore_length%>% 
  filter(ResolvedID == "Lygodium_articulatum" | ResolvedID == "ygodium_palmatum")
t.test(avg_length ~ ResolvedID, data = spore_len_art, alternative = "greater")
#t = 12.41, df = 11.288, p-value = 3.157e-08

spore_area_art <- spore_area%>% 
  filter(ResolvedID == "Lygodium_articulatum" | ResolvedID == "Lygodium_palmatum")
t.test(Measurement ~ ResolvedID, data = spore_area_art, alternative = "greater")
#t = 14.126, df = 18.331, p-value = 1.341e-11

spore_wid_art <- spore_width%>% 
  filter(ResolvedID == "Lygodium_articulatum" | ResolvedID == "ygodium_palmatum")
t.test(avg_width ~ ResolvedID, data = spore_wid_art, alternative = "greater")
#t = 18.425, df = 21.963, p-value = 3.804e-15


## Compare longifolium and auriculatum
spore_len_long <- spore_length %>% 
  filter(ResolvedID == "Lygodium_longifolium" | ResolvedID == "Lygodium_auriculatum")
t.test(avg_length ~ ResolvedID, data = spore_len_long, alternative = "less")
#t = -9.4731, df = 16.327, p-value = 2.431e-08

spore_area_long <- spore_area %>% 
  filter(ResolvedID == "Lygodium_longifolium" | ResolvedID == "Lygodium_auriculatum")
t.test(Measurement ~ ResolvedID, data = spore_area_long, alternative = "less")
#t = -4.6648, df = 11.901, p-value = 0.0002793

spore_wid_long <- spore_width %>% 
  filter(ResolvedID == "Lygodium_longifolium" | ResolvedID == "Lygodium_auriculatum")
t.test(avg_width ~ ResolvedID, data = spore_wid_long, alternative = "less")
#t = -4.3716, df = 19.998, p-value = 0.0001476

## Compare oligostachyum and venustum
spore_len_oligo <- spore_length %>% 
  filter(ResolvedID == "Lygodium_oligostachyum" | ResolvedID == "Lygodium_venustum")
t.test(avg_length ~ ResolvedID, data = spore_len_oligo, alternative = "greater")
#t = 4.7817, df = 14.992, p-value = 0.0001214

spore_area_oligo <- spore_area %>% 
  filter(ResolvedID == "Lygodium_oligostachyum" | ResolvedID == "Lygodium_venustum")
t.test(Measurement ~ ResolvedID, data = spore_area_oligo, alternative = "greater")
#t = 3.9179, df = 14.486, p-value = 0.0007281

spore_wid_oligo <- spore_width %>% 
  filter(ResolvedID == "Lygodium_oligostachyum" | ResolvedID == "Lygodium_venustum")
t.test(avg_width ~ ResolvedID, data = spore_wid_oligo, alternative = "greater")
#t = 4.6252, df = 16.509, p-value = 0.0001299

## Paired T-Test with spore sizes

# Length 
diploid_len <- c(49.5, 56.95, 73.65, 64.64)
polyploid_len <- c(66.91, 98, 94.68, 87.15)
len_t.test <- t.test(diploid_len, polyploid_len, paired = T, alternative = "less")
len_t.test
pd <- paired(diploid_len, polyploid_len)
plot(pd, type = "profile") + theme_bw()

ggpaired(data = pd, cond1 = "diploid_len", cond2 = "polyploid_len", width = 0, color = "white")

# Width
diploid_wid <- c(52, 78.95, 49.45, 62.29)
polyploid_wid <- c(71.59, 91.6, 103.08, 93.38)
wid_t.test <- t.test(diploid_wid, polyploid_wid, paired = T, alternative = "less")
wid_t.test
pd <- paired(diploid_wid, polyploid_wid)
ggpaired(data = pd, cond1 = "diploid_wid", cond2 = "polyploid_wid", width = 0, color = "white")

# Area 
diploid_area <- c(2305.85, 5113.58, 2212.97, 3358.47)
polyploid_area <- c(3783.14, 6798.79, 9005.54, 7080.94)
area_t.test <- t.test(diploid_area, polyploid_area, paired = T, alternative = "less")
area_t.test
pd <- paired(diploid_area, polyploid_area)
ggpaired(data = pd, cond1 = "diploid_area", cond2 = "polyploid_area", width = 0, color = "white")

# Genome Size 



# Read in averages for spore and genome size data 

Sizes <- read.csv("SporeGenomeSize.csv", na.strings = "",row.names = 1)

#sp_tree <- read.newick("../GoFlag/PATE/trimmed_tree_rooted.tre")
ML_tree <- read.newick("ML_trimmed_tree_edit.tre")
plot(sp_tree)
rm_tips <- c("Actinostachys_pennula",  "Anemia_adiantifolia", "Anemia_tomentosa", "Anemia_phyllitidis",
             "Lygodium_sp", "Lygodium_semihastatum", "Lygodium_subareolatum","Lygodium_borneense",
             "Lygodium_conforme", "Lygodium_cubense","Lygodium_heterodoxum","Lygodium_hians",
             "Lygodium_kerstenii","Lygodium_lanceolatum","Lygodium_merrillii","Lygodium_polystachyum",
             "Lygodium_radiatum","Lygodium_smithianum","Lygodium_subareolatum",
             "Lygodium_venustum","Lygodium_versteegii", "Lygodium_yunnanense","Lygodium_xfayae")
trimmed_tree2<-drop.tip(sp_tree,rm_tips)
plot(trimmed_tree2)

ChrmPloidy <- as.factor(as.matrix(read.csv("SporeGenomeSize.csv", row.names = 1), na.strings = "")[,2])
GenomeSize <- as.matrix(read.csv("SporeGenomeSize.csv", row.names = 1), na.strings = "")[,4]
SporeLength <- as.matrix(read.csv("SporeGenomeSize.csv", row.names = 1), na.strings = "")[,5]
SporeWidth <- as.matrix(read.csv("SporeGenomeSize.csv", row.names = 1, na.strings = "", sep = ","))[,6]
SporeArea <- as.matrix(read.csv("SporeGenomeSize.csv", row.names = 1))[,7]

obj <- contMap(trimmed_tree2, ChrmPloidy[!is.na(ChrmPloidy)])
PloidyNoMiss <- ChrmPloidy[!is.na(ChrmPloidy)]
LengthNoMiss <- SporeLength[!is.na(SporeLength)]

phyl.pairedttest(trimmed_tree2, x1=PloidyNoMiss, x2=LengthNoMiss)

phylANOVA(trimmed_tree2, PloidyNoMiss, LengthNoMiss)
aov.phylo(SporeArea~PloidyNoMiss, phy = trimmed_tree2)

lambda_GL_ML<-fitContinuous(phy = sp_tree, dat = SporeWidth, model = "lambda")

ggplot(data = subset(Sizes, !is.na(ChrmPloidy)), mapping = aes(x=ChrmPloidy, y = GenomeSize, fill = ChrmPloidy)) + 
  geom_bar(stat= "summary", fun.y= "mean") + theme_classic()

ggplot(data = subset(Sizes, !is.na(ChrmPloidy)), mapping = aes(x=ChrmPloidy, y = SporeLength)) + 
  geom_bar(stat= "summary", fun.y= "mean") + theme_classic()

ggplot(data = subset(Sizes, !is.na(ChrmPloidy)), mapping = aes(x=ChrmPloidy, y = SporeWidth)) + 
  geom_bar(stat= "summary", fun.y= "mean") + theme_classic()

ggplot(data = subset(Sizes, !is.na(ChrmPloidy)), mapping = aes(x=ChrmPloidy, y = SporeArea)) + 
  geom_bar(stat= "summary", fun.y= "mean") + theme_classic()

t.test(SporeLength ~ ChrmPloidy, data = Sizes)

# 

tree <- read.newick("../GoFlag/2023_Run3/Part.Lygodium.FullFiles.NoDups.GeneBoundaries.txt.treefile")
plot(tree)
keep <- read.delim("../Cytology:GenomeSize/tips_to_keep.txt", row.names = 1)
name_list<-name.check(tree,keep)
#make list of names not in data file
checked_names<-name_list$tree_not_data
#convert to a vector
names_to_drop<-as.vector(checked_names)
#trim tree to just taxa represented in list
trimmed_tree<-drop.tip(tree,names_to_drop)

#visualize trimmed tree
plot(trimmed_tree, cex=1)

#check trimmed tree against species list
name.check(trimmed_tree, keep)

write.tree(phy = trimmed_tree, file = "ML_trimmed_tree.tre")

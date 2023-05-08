############################################################
# 
#     Mechanistic neutral models & early tetrapods
# __________________________________________________________
#   
# Script purpose:     Cleaning fossil occurrence data
# Date last modified: 08-05-2023
# Author:             EM Dunne (dunne.emma.m@gmail.com)
#
############################################################


## Load package(s):
library(tidyverse)




# Clean occurrence data ---------------------------------------------------

## read in data download and add column to identify group later
## See Dunne et al. (2023) Table 1 for more information on the groupings below

# Amphibians
# (i.e. Non-amniote tetrapod species including early Tetrapodpodomorpha, Non-amniote tetrapodomorph species including Lepospondyli and Temnospondyli)
pbdb_data_amph <- read.csv("./data/pbdb_amphibians_April10.csv", header = TRUE, skip = 20, stringsAsFactors=FALSE)
pbdb_data_amph$group <- "amphibian"

# Amniotes
# (i.e. Tetrapod species belonging to the clade Reptiliomorpha, which includes the crown group Amniota and those species more closely related to them than to modern amphibians)
pbdb_data_amni <- read.csv("./data/pbdb_amniotes_April10.csv", header = TRUE, skip = 20, stringsAsFactors=FALSE)
pbdb_data_amni$group <- "amniote"


## Combine
pbdb_data <- rbind(pbdb_data_amph, pbdb_data_amni)
head(pbdb_data)


## Filter data
pbdb_data <- filter(pbdb_data, flags != "R") # filter reidentified taxa
pbdb_data <- pbdb_data[pbdb_data$pres_mode != "trace", ] # filter trace taxa
pbdb_data <- pbdb_data[!grepl("soft",pbdb_data$pres_mode), ] # filter 'soft preservation' taxa


## Use lists of terms stored in text files to remove those occurrences
trace.terms <- scan("./data/input_data/trace-terms.txt", what = "character"); trace.terms <- trace.terms[trace.terms != ""]
mesosaurs <- scan("./data/input_data/mesosaurs.txt", what = "character"); mesosaurs <- mesosaurs[mesosaurs != ""]
exclude.terms <- c(mesosaurs,
                   "Chelichnus", # turtle genus
                   "Cincosaurus" #ichnotaxa
)
exclude.terms <- exclude.terms[exclude.terms != ""] #remove any blank entries that may have crept in

## Strip out everything that needs to be excluded from various columns:
pbdb_data <- pbdb_data[!(pbdb_data$order %in% exclude.terms), ]
pbdb_data <- pbdb_data[!(pbdb_data$family %in% exclude.terms), ]
pbdb_data <- pbdb_data[!(pbdb_data$genus %in% exclude.terms), ]

pbdb_data_cleaned <- pbdb_data

# export as csv
write_csv(pbdb_data_cleaned, file = "./data/pbdb_occs_cleaned.csv")





# Organise dataset --------------------------------------------------------


## Truncate occurrence data to only necessary columns
tet_collections <- select(pbdb_data_cleaned, 
                          group, collection_name, collection_no, cc, state, 
                          early_interval, min_ma, max_ma, 
                          paleolng, paleolat) %>% distinct(collection_no, .keep_all = TRUE)

## Calculate number of occurrences per collection:
occs_per_coll <- pbdb_data_cleaned %>% 
  group_by(collection_no) %>% 
  summarise(n_occs = length(unique(occurrence_no)))
View(occs_per_coll) # check

## Join both tibbles
tet_occs <- left_join(tet_collections, occs_per_coll, by = "collection_no")

## Save .csv
write_csv(tet_occs, file = "./data/tetrapod_occurrences.csv")


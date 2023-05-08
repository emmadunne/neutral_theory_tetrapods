#########################################################
# 
#     Mechanistic neutral models & early tetrapods
# ______________________________________________________
#   
# Script purpose: Cleaning fossil occurrence data
# Date last modified: 08-05-2023
# Author: EM Dunne (dunne.emma.m@gmail.com)
#
#########################################################


## Load package(s):
library(tidyverse)



#===== Clean occurrence data ============================================================================================================================================================================================================================================================================


## read in data download
pbdb_data_amph <- read.csv("./datasets/pbdb_early_tetrapods_April10.csv", header = TRUE, skip = 20, stringsAsFactors=FALSE)
pbdb_data_amni <- read.csv("./datasets/pbdb_early_amniotes_April10.csv", header = TRUE, skip = 20, stringsAsFactors=FALSE)

## Combine



## Filter data
pbdb_data <- filter(pbdb_data, flags != "R") #Filter out reidentified taxa
pbdb_data <- pbdb_data[pbdb_data$pres_mode != "trace", ]
pbdb_data <- pbdb_data[!grepl("soft",pbdb_data$pres_mode), ]


## Then use lists of terms stored in text files to remove those occurrences
trace.terms <- scan("./input-data/trace-terms.txt", what = "character"); trace.terms <- trace.terms[trace.terms != ""]
mesosaurs <- scan("./input-data/mesosaurs.txt", what = "character"); mesosaurs <- mesosaurs[mesosaurs != ""]
exclude.terms <- c(mesosaurs, 
                   "Chelichnus", #turtle genus
                   "Cincosaurus" #ichnotaxa
)
exclude.terms <- exclude.terms[exclude.terms != ""] #remove any blank entries that may have crept in

## Strip out everything that needs to be excluded
#pbdb_data <- pbdb_data[!(pbdb_data$order %in% exclude.terms | pbdb_data$family %in% exclude.terms | pbdb_data$genus %in% exclude.terms), ]
pbdb_data <- pbdb_data[!(pbdb_data$order %in% exclude.terms), ]
pbdb_data <- pbdb_data[!(pbdb_data$family %in% exclude.terms), ]
pbdb_data <- pbdb_data[!(pbdb_data$genus %in% exclude.terms), ]



tetrapod_data <- pbdb_data
amniote_data <- pbdb_data


# export as csv
write.csv(tetrapod_data, file = "./datasets/early_tetrapod_occs_cleaned.csv")
write.csv(amniote_data, file = "./datasets/early_amniote_occs_cleaned.csv")






#===== Divide amniotes and amphibians ============================================================================================================================================================================================================================================================================


#Extract list of amniotes species names to filter out Amphibians from original PBDB download
amniote_list <- unique(amniote_data$accepted_name)
amniote_list <- amniote_list[amniote_list != ""]

amphibian_data <- tetrapod_data[!(tetrapod_data$accepted_name %in% amniote_list), ]


write.csv(amphibian_data, file = "./datasets/early_amphibian_occs_cleaned.csv")




#===== Organise the data ============================================================================================================================================================================================================================================================================


# amniotes
amniote_collections <- select(amniote_data, collection_name, collection_no, cc, state, early_interval, min_ma, max_ma, paleolng, paleolat) %>% distinct(collection_no, .keep_all = TRUE)

amniote_occs <- amniote_data %>% group_by(collection_no) %>% summarise(n_occs = length(unique(occurrence_no)))
amniote_final_dataset <- left_join(amniote_collections, amniote_occs, by = "collection_no")

write.csv(amniote_final_dataset, file = "./datasets/amniote_final_dataset.csv")



## amphibians
amphibian_collections <- select(amphibian_data, collection_name, collection_no, cc, state, early_interval, min_ma, max_ma, paleolng, paleolat) %>% distinct(collection_no, .keep_all = TRUE)

amphibian_occs <- amphibian_data %>% group_by(collection_no) %>% summarise(n_occs = length(unique(occurrence_no)))
amphibian_final_dataset <- left_join(amphibian_collections, amphibian_occs, by = "collection_no")

write.csv(amphibian_final_dataset, file = "./datasets/amphibian_final_dataset.csv")



## In Excel:
## Combine both datasets and add column indicating whether the line is from the amniote or amphibian dataset





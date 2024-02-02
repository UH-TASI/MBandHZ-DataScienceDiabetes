#Libraries
library(readr)
library(dplyr)

#Folder
folder_name = "diabetes+130-us+hospitals+for+years+1999-2008/"
file_name = c("diabetic_data.csv", "IDS_mapping.csv")

#Dataset
diabetic_data = read_csv(paste(folder_name, file_name[1], sep = ''))
IDS_mapping = read_csv(paste(folder_name, file_name[2], sep = ''))
#Reform IDS Mapping
##Split the IDS Mapping
split_indices <- c(0, which(is.na(IDS_mapping$admission_type_id)), nrow(IDS_mapping) + 1)
split_data <- lapply(seq_along(split_indices[-1]), function(i) {
  start_index <- split_indices[i] + 1
  end_index <- split_indices[i + 1] - 1
  IDS_mapping[start_index:end_index, , drop = FALSE]
})
split_data <- lapply(split_data, as.data.frame)
rm(split_indices)

##Remove the first row because it was the column name
for (i in seq_along(split_data)[-1]) {
  colnames(split_data[[i]])[1] <- split_data[[i]][1, 1]
  split_data[[i]] <- dplyr::slice(split_data[[i]], -1)
}

##Make the first column a numeric type
split_data <- lapply(split_data, function(df) {
  df[[1]] <- as.numeric(df[[1]])
  return(df)
})

##Split the list into separate dataframes
names(split_data) <- c("admission_type_id", "discharge_disposition_id", "admission_source_id")
list2env(split_data, envir = .GlobalEnv)

#Reform Diabetic Data 
##Merge IDS Mapping to diabetic data
for (i in c("admission_type_id", "discharge_disposition_id", "admission_source_id")) {
  diabetic_data = merge(diabetic_data, split_data[[i]], by.x = i, by.y = i, all.x =TRUE)
  names(diabetic_data)[names(diabetic_data) == "description"] = paste(substr(i, start = 1, stop = nchar(i) - 3), "description", sep="_") 
  diabetic_data = diabetic_data[, -which(names(diabetic_data) == i), drop = FALSE]
}

##Remove Redundant Data
rm(IDS_mapping)
rm(split_data)

##Replace "?" values to NA
diabetic_data[diabetic_data == "?"] <- NA

### Create Columns
if(!"DRG_1" %in% colnames(diabetic_data))
{
  diabetic_data <- diabetic_data %>% add_column(DRG_1 = NA, .after = "diag_1")
}
if(!"DRG_2" %in% colnames(diabetic_data))
{
  diabetic_data <- diabetic_data %>% add_column(DRG_2 = NA, .after = "diag_2")
}
if(!"DRG_3" %in% colnames(diabetic_data))
{
  diabetic_data <- diabetic_data %>% add_column(DRG_3 = NA, .after = "diag_3")
}

### Turn into Numeric Values
diabetic_data$diag_1 <- as.numeric(diabetic_data$diag_1)
diabetic_data$diag_2 <- as.numeric(diabetic_data$diag_2)
diabetic_data$diag_3 <- as.numeric(diabetic_data$diag_3)


### Infectious and Parasitic Diseases (001-139)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 1) & (diabetic_data$diag_1 < 140), "Infectious and Parasitic Diseases",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 1) & (diabetic_data$diag_2 < 140), "Infectious and Parasitic Diseases",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 1) & (diabetic_data$diag_3 < 140), "Infectious and Parasitic Diseases",diabetic_data$DRG_3)

### Neoplasms (140-239)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 140) & (diabetic_data$diag_1 < 240), "Neoplasms",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 140) & (diabetic_data$diag_2 < 240), "Neoplasms",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 140) & (diabetic_data$diag_3 < 240), "Neoplasms",diabetic_data$DRG_3)

### Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders (240-279)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 240) & (diabetic_data$diag_1 < 250), "Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 240) & (diabetic_data$diag_2 < 250), "Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 240) & (diabetic_data$diag_3 < 250), "Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders",diabetic_data$DRG_3)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 251) & (diabetic_data$diag_1 < 280), "Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 251) & (diabetic_data$diag_2 < 280), "Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 251) & (diabetic_data$diag_3 < 280), "Endocrine, Nutritional, and Metabolic Diseases and Immunity Disorders",diabetic_data$DRG_3)

### Diabetes Mellitus (250)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 250) & (diabetic_data$diag_1 < 251), "Diabetes Mellitus",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 250) & (diabetic_data$diag_2 < 251), "Diabetes Mellitus",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 250) & (diabetic_data$diag_3 < 251), "Diabetes Mellitus",diabetic_data$DRG_3)

### Diseases of Blood and Blood Forming Organs (280-289)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 280) & (diabetic_data$diag_1 < 290), "Diseases of Blood and Blood Forming Organs",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 280) & (diabetic_data$diag_2 < 290), "Diseases of Blood and Blood Forming Organs",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 280) & (diabetic_data$diag_3 < 290), "Diseases of Blood and Blood Forming Organs",diabetic_data$DRG_3)

### Mental Disorders (290-319)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 290) & (diabetic_data$diag_1 < 320), "Mental Disorders",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 290) & (diabetic_data$diag_2 < 320), "Mental Disorders",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 290) & (diabetic_data$diag_3 < 320), "Mental Disorders",diabetic_data$DRG_3)

### Diseases of Nervous System and Sense Organ (320-389)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 320) & (diabetic_data$diag_1 < 390), "Diseases of Nervous System and Sense Organ",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 320) & (diabetic_data$diag_2 < 390), "Diseases of Nervous System and Sense Organ",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 320) & (diabetic_data$diag_3 < 390), "Diseases of Nervous System and Sense Organ",diabetic_data$DRG_3)

### Diseases of Circulatory System (390-459)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 390) & (diabetic_data$diag_1 < 460), "Diseases of Circulatory System",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 390) & (diabetic_data$diag_2 < 460), "Diseases of Circulatory System",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 390) & (diabetic_data$diag_3 < 460), "Diseases of Circulatory System",diabetic_data$DRG_3)

### Diseases of Respiratory System (460-519)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 460) & (diabetic_data$diag_1 < 520), "Diseases of Respiratory System",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 460) & (diabetic_data$diag_2 < 520), "Diseases of Respiratory System",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 460) & (diabetic_data$diag_3 < 520), "Diseases of Respiratory System",diabetic_data$DRG_3)

### Diseases of Digestive System (520-579)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 520) & (diabetic_data$diag_1 < 580), "Diseases of Digestive System",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 520) & (diabetic_data$diag_2 < 580), "Diseases of Digestive System",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 520) & (diabetic_data$diag_3 < 580), "Diseases of Digestive System",diabetic_data$DRG_3)

### Diseases of Genitourinary System (580-629)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 580) & (diabetic_data$diag_1 < 630), "Diseases of Genitourinary System",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 580) & (diabetic_data$diag_2 < 630), "Diseases of Genitourinary System",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 580) & (diabetic_data$diag_3 < 630), "Diseases of Genitourinary System",diabetic_data$DRG_3)

### Diseases of Complications of Pregnancy, Childbirth, and the Puerperium (630-679)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 630) & (diabetic_data$diag_1 < 680), "Diseases of Complications of Pregnancy, Childbirth, and the Puerperium",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 630) & (diabetic_data$diag_2 < 680), "Diseases of Complications of Pregnancy, Childbirth, and the Puerperium",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 630) & (diabetic_data$diag_3 < 680), "Diseases of Complications of Pregnancy, Childbirth, and the Puerperium",diabetic_data$DRG_3)

### Diseases of Skin and Subcutaneous Tissue (680-709)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 680) & (diabetic_data$diag_1 < 710), "Diseases of Skin and Subcutaneous Tissue",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 680) & (diabetic_data$diag_2 < 710), "Diseases of Skin and Subcutaneous Tissue",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 680) & (diabetic_data$diag_3 < 710), "Diseases of Skin and Subcutaneous Tissue",diabetic_data$DRG_3)

### Diseases of Musculoskeletal and Connective Tissue (710-739)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 710) & (diabetic_data$diag_1 < 740), "Diseases of Musculoskeletal and Connective Tissue",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 710) & (diabetic_data$diag_2 < 740), "Diseases of Musculoskeletal and Connective Tissue",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 710) & (diabetic_data$diag_3 < 740), "Diseases of Musculoskeletal and Connective Tissue",diabetic_data$DRG_3)

### Congenital Anomalies (740-759)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 740) & (diabetic_data$diag_1 < 760), "Congenital Anomalies",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 740) & (diabetic_data$diag_2 < 760), "Congenital Anomalies",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 740) & (diabetic_data$diag_3 < 760), "Congenital Anomalies",diabetic_data$DRG_3)

### Newborn (Perinatal) Guidelines (760-779)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 760) & (diabetic_data$diag_1 < 780), "Newborn (Perinatal) Guidelines",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 760) & (diabetic_data$diag_2 < 780), "Newborn (Perinatal) Guidelines",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 760) & (diabetic_data$diag_3 < 780), "Newborn (Perinatal) Guidelines",diabetic_data$DRG_3)

### Signs, Sysmptoms and Ill-Defined Conditions (780-799)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 780) & (diabetic_data$diag_1 < 800), "Signs, Sysmptoms and Ill-Defined Conditions",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 780) & (diabetic_data$diag_2 < 800), "Signs, Sysmptoms and Ill-Defined Conditions",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 780) & (diabetic_data$diag_3 < 800), "Signs, Sysmptoms and Ill-Defined Conditions",diabetic_data$DRG_3)

### Injury and Poisoning (800-999)

diabetic_data$DRG_1 <- ifelse((diabetic_data$diag_1 >= 800) & (diabetic_data$diag_1 < 1000), "Injury and Poisoning",diabetic_data$DRG_1)
diabetic_data$DRG_2 <- ifelse((diabetic_data$diag_2 >= 800) & (diabetic_data$diag_2 < 1000), "Injury and Poisoning",diabetic_data$DRG_2)
diabetic_data$DRG_3 <- ifelse((diabetic_data$diag_3 >= 800) & (diabetic_data$diag_3 < 1000), "Injury and Poisoning",diabetic_data$DRG_3)

diabetic_data$DRG_1 <- as.factor(diabetic_data$DRG_1)
diabetic_data$DRG_2 <- as.factor(diabetic_data$DRG_2)
diabetic_data$DRG_3 <- as.factor(diabetic_data$DRG_3)


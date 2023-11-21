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

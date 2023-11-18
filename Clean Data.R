#Libraries
library(readr)
library(dplyr)

#Dataset
diabetic_data <- read_csv("diabetes+130-us+hospitals+for+years+1999-2008/diabetic_data.csv")
IDS_mapping <- read_csv("diabetes+130-us+hospitals+for+years+1999-2008/IDS_mapping.csv")

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
rm(i)
##Make the first column a numeric type
split_data <- lapply(split_data, function(df) {
  df[[1]] <- as.numeric(df[[1]])
  return(df)
})

##Split the list into separate dataframes
names(split_data) <- c("admission_type_id", "discharge_disposition_id", "admission_source_id")
list2env(split_data, envir = .GlobalEnv)

##Remove Redundant Data
rm(split_data)
rm(IDS_mapping)

#Reform Diabetic Data 
##Replace "?" values to NA
diabetic_data[diabetic_data == "?"] <- NA

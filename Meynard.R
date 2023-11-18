#Calculate Missing Data
missing_percentage <- sapply(diabetic_data, function(x) sum(is.na(x)) / length(x) * 100)

missing_data_summary <- data.frame(Column = names(missing_percentage), Percentage = missing_percentage)
missing_data_summary <- missing_data_summary[missing_data_summary$Percentage != "0", ]
print(missing_data_summary)
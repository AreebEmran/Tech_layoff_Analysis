tech_layoff <- read.csv("C:\\Users\\areeb\\OneDrive - Asia Pacific University\\Desktop\\tech_layoffs.csv")
View(tech_layoff)
summary(tech_layoff)
install.packages("ggplot2")
install.packages("dplyr")
library("ggplot2")
library("dplyr")
#Checking Column names
colnames(tech_layoff)

#Unique values
unique(tech_layoff$company)
unique(tech_layoff$total_layoffs)
unique(tech_layoff$impacted_workforce_percentage)
unique(tech_layoff$reported_date)
unique(tech_layoff$industry)
unique(tech_layoff$headquarter_location)
unique(tech_layoff$sources)
unique(tech_layoff$status)
unique(tech_layoff$additional_notes)

#Checking Summary: They were previously character values
summary(tech_layoff$total_layoffs)
summary(tech_layoff$impacted_workforce_percentage)
summary(tech_layoff$reported_date)


#Tranformation to Quantitative Values
tech_layoff$total_layoffs <- as.numeric(gsub("[^0-9.]", "", tech_layoff$total_layoffs))
#Checking class
class(tech_layoff$total_layoffs)
# Check the summary of the total_layoffs column
summary(tech_layoff$total_layoffs)

tech_layoff$impacted_workforce_percentage <- as.numeric(gsub("[^0-9.]", "", tech_layoff$impacted_workforce_percentage))
#Checking class
class(tech_layoff$impacted_workforce_percentage)
# Check the summary of the impacted workforce column
summary(tech_layoff$impacted_workforce_percentage)

#Changing unclear or Null values to NA
tech_layoff <- replace(tech_layoff, tech_layoff == "Unclear", NA)
 
#Find missing values
is.na(tech_layoff)
 
#Count missing values
sum(is.na(tech_layoff))
 
#Omit missing values
na.omit(tech_layoff)
 
 # Replace NA values with the calculated mean
mean_total_layoff<-mean(tech_layoff$total_layoffs,na.rm = TRUE)
tech_layoff$total_layoffs[is.na(tech_layoff$total_layoffs)] <- mean_total_layoff
View(tech_layoff)

mean_impacted_workforce_percentage<-mean(tech_layoff$impacted_workforce_percentage,na.rm = TRUE)
tech_layoff$impacted_workforce_percentage[is.na(tech_layoff$impacted_workforce_percentage)] <- mean_impacted_workforce_percentage
View(tech_layoff)


#Create New column(Total Number of workforce in a company)
tech_layoff$total_workforce <- tech_layoff$total_layoffs / (tech_layoff$impacted_workforce_percentage / 100)


#Analysis to see majority locations

# Frequency table
freq_table <- table(tech_layoff$headquarter_location)
print(freq_table)

# Determine majority categories
majority_categories <- names(freq_table[freq_table > 5])

# Filter out frequencies of majority categories
majority_freq <- freq_table[majority_categories]

# Create pie chart
pie(majority_freq, main = "Pie Chart of Majority Locations", col = rainbow(length(majority_freq)), labels = paste(names(majority_freq), ": ", majority_freq, sep = ""))

# Add legend
legend("topright", legend = names(majority_freq), fill = rainbow(length(majority_freq)))

#Analysis to see majority layoff industries

# Frequency table
freq_table1 <- table(tech_layoff$industry)
print(freq_table1)

# Determine majority categories
majority_categories1 <- names(freq_table1[freq_table1 > 6])

# Filter out frequencies of majority categories
majority_freq1 <- freq_table1[majority_categories1]

# Create pie chart
pie(majority_freq1, main = "Pie Chart of Majority  Employee Layoff Industries", col = rainbow(length(majority_freq1)), labels = paste(names(majority_freq1), ": ", majority_freq1, sep = ""))

# Add legend
legend("topright", legend = names(majority_freq1), fill = rainbow(length(majority_freq1)))


# Load necessary libraries
library(dplyr)
library(ggplot2)
library(lubridate)

# Convert 'reported_date' column to date format
tech_layoff$reported_date <- as.Date(tech_layoff$reported_date)

# Extract year and month from 'reported_date'
tech_layoff$year <- year(tech_layoff$reported_date)
tech_layoff$month <- month(tech_layoff$reported_date)

# Group by year and month and count the number of layoffs
layoffs_by_month <- tech_layoff %>%
  group_by(year, month) %>%
  summarise(total_layoffs = sum(total_layoffs))

# Plot the trend of layoffs over time
ggplot(layoffs_by_month, aes(x = as.Date(paste(year, month, "01", sep = "-")), y = total_layoffs)) +
  geom_line() +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  labs(x = "Date", y = "Number of Layoffs", title = "Trends in Layoffs Over Time")

# Identify seasonal patterns
layoffs_by_month$month <- factor(layoffs_by_month$month, labels = month.abb)
ggplot(layoffs_by_month, aes(x = month, y = total_layoffs, group = year, color = factor(year))) +
  geom_boxplot() +
  labs(x = "Month", y = "Number of Layoffs", title = "Seasonal Patterns in Layoffs")



# Load necessary libraries
library(dplyr)
library(ggplot2)

# Calculate the absolute number of impacted workforce for each company
tech_layoff <- tech_layoff %>%
  mutate(impacted_workforce_absolute = impacted_workforce_percentage/100 * total_workforce)

# Filter industries that are repeated more than 6 times
filtered_industries <- tech_layoff %>%
  group_by(industry) %>%
  summarise(count = n()) %>%
  filter(count > 6) %>%
  select(industry)

# Group by industry and calculate the total number of layoffs and total workforce
industry_summary <- tech_layoff %>%
  filter(industry %in% filtered_industries$industry) %>%
  group_by(industry) %>%
  summarise(total_layoffs = sum(total_layoffs),
            total_workforce = sum(total_workforce),
            total_impacted_workforce = sum(impacted_workforce_absolute))


# Calculate the percentage of impacted workforce for each industry
industry_summary <- industry_summary %>%
  mutate(percentage_impacted_workforce = (total_impacted_workforce / total_workforce) * 100)


# Plot the percentage of impacted workforce by industry
ggplot(industry_summary, aes(x = industry, y = percentage_impacted_workforce)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(x = "Industry", y = "Percentage of Impacted Workforce", title = "Percentage of Impacted Workforce by Industry (Repeated More Than 6 Times)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# Select relevant columns for correlation analysis
selected_columns <- tech_layoff %>%
  select(total_layoffs, impacted_workforce_percentage, total_workforce)

# Perform correlation analysis
correlation_matrix <- cor(selected_columns)

# Print correlation matrix
print(correlation_matrix)

#Necessary library
library(forecast)

# Convert 'reported_date' to a Date object
tech_layoff$reported_date <- as.Date(tech_layoff$reported_date)

# Create a time series object
ts_data <- ts(tech_layoff$total_layoffs, frequency = 12)  # Taking monthly data

# Fit ARIMA model
arima_model <- auto.arima(ts_data)

# Forecast future layoffs
forecast_result <- forecast(arima_model, h = 12)  # Forecasting for the next 12 periods 

# Print forecast results
print(forecast_result)

# Plot forecast
plot(forecast_result, main = "Forecast of Layoffs")




















# Use cleaned data set from "AH Provisional Diabetes.." raw data to do analysis

# Date Created: Nov. 11, 2020

# ------------------------------------------------------------------------------

library(dplyr)
library(readr)
library(magrittr)
library(forcats)
library(ggplot2)
library(RColorBrewer)


# Set current working directory to this file's parent directory
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Clean data file location
clean_data_path <- '../../clean_data/ah_diabetes/'
cond_fn <- 'DIAB_month_age_sex.csv'

# Concatenate base path with cond_fn
diab_path <- file.path(clean_data_path, cond_fn)


diab_data <- read_csv(diab_path, col_types = 'ffffi')


#NEWEWERWNERWER
# Rename C19+MCVD
levels(diab_data$Condition) <- c(levels(diab_data$Condition),
                                       "C19+Major.Cardiovascular.Diseases")

# Remove extraneous condition
diab_data <- diab_data %>%
    filter(Condition != "C19+Hypertensive+MCVD") %>%
    mutate(Condition = replace(Condition, Condition == "C19+MCVD",
                              "C19+Major.Cardiovascular.Diseases")) %>%
    droplevels()
# NWERNWERWNERWN


cond_sex_deaths <- diab_data %>%
    group_by(Condition, Sex) %>%
    summarize(Total.Deaths = sum(Total.Deaths)) %>%
    droplevels()


# Death counts vs Condition by Sex (ordered by death count)
cond_sex_deaths$Condition <- reorder(
    cond_sex_deaths$Condition,
    cond_sex_deaths$Total.Deaths)

# Output final plot data
write_csv(cond_sex_deaths, 'plot_cond_sex_data.csv')


# Make ggplot of Condition vs Deaths by Sex (fill)
gg_cond_sex <- cond_sex_deaths %>%
    ggplot(mapping = aes(x = Condition, y = Total.Deaths, fill = Sex)) +
    geom_col(position = 'dodge', width = 0.7) +
    xlab('') + ylab('') +
    ggtitle('Males have more Total Deaths than Females for all Conditions',
            subtitle = 'Thousands of Deaths by Condition and Sex (Jan - Sep 2020)') +
    scale_y_continuous(labels = function(y) {paste0(y/1000, 'k')}) +
    scale_fill_discrete(breaks = c("Male (M)", "Female (F)"),
                        labels = c("  Male", "  Female")) +
    coord_flip() +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 3.5),
          plot.subtitle = element_text(face = 'italic', size = 9.5, hjust = -1.6),
          panel.grid.major.y = element_blank(),
          legend.position = c(0.75, 0.2),
          legend.title = element_blank())

# pdf("plots/condition_sex.pdf")
# print(gg_cond_sex)

# dev.off()


# ------------------------------------------------------------------------------
# Condition vs Deaths by Age Group
cond_age_deaths <- diab_data %>%
    group_by(Condition, Age.Group) %>%
    summarize(Total.Deaths = sum(Total.Deaths)) %>%
    droplevels()


# Death counts vs Condition by age (ordered by death count)
cond_age_deaths$Condition <- reorder(
    cond_age_deaths$Condition,
    cond_age_deaths$Total.Deaths)


# Output final plot data
write_csv(cond_age_deaths, 'plot_cond_age_data.csv')


# Make ggplot of Condition vs Deaths by age (fill)
gg_cond_age <- cond_age_deaths %>%
    ggplot(mapping = aes(x = Condition, y = Total.Deaths, fill = Age.Group)) +
    geom_col(position = 'dodge') +
    labs(x='', y='',
         title = 'Covid-19 has hit Older Americans the Hardest',
         subtitle = 'Thousands of Deaths by Condition and Age Group (Jan - Sep 2020)') +
         # caption = '*MCVD = Major Cardiovascular Diseases') +
    scale_y_continuous(labels = function(y) {paste0(y/1000, 'k')}) +
    scale_fill_brewer(breaks = rev(unique(cond_age_deaths$Age.Group)),
                      palette = 'OrRd') +
    coord_flip() +
    theme_dark() +
    theme(plot.title = element_text(hjust = -1.0),
          plot.subtitle = element_text(face = 'italic', size = 9.5, hjust = -2.3),
          panel.grid.major.y = element_blank(),
          legend.background = element_rect(fill = 'gray90'),
          legend.position = c(0.85, 0.2),
          legend.title = element_blank(),
          legend.spacing.x = unit(0.25, 'cm'),
          legend.key = element_rect(color = 'white'),
          axis.ticks = element_blank())

# pdf("plots/condition_age.pdf")
# print(gg_cond_age)

# dev.off()



# ------------------------------------------------------------------------------
# Deaths by Age Group for only Covid-19
uc_clean_data_path <- '../../clean_data/underlying_conds/'
under_cond_fn <- 'UC_USA_age_ranges.csv'

# Concatenate base path with cond_fn
uc_path <- file.path(uc_clean_data_path, under_cond_fn)


uc_age_data <- read_csv(uc_path, col_types = 'fffffffi')

age_total_deaths <- uc_age_data %>%
    filter(Condition == 'COVID-19') %>%
    select(Age.Group, Number.of.COVID.19.Deaths) %>%
    group_by(Age.Group) %>%
    summarize(Total.Deaths = sum(Number.of.COVID.19.Deaths)) %>%
    mutate(Total.Deaths = Total.Deaths / 329064917 * 100000) %>%
    droplevels()

# Death counts vs Age group (ordered by death count)
age_total_deaths$Age.Group <- reorder(
    age_total_deaths$Age.Group,
    age_total_deaths$Total.Deaths)


# Output final plot data
write_csv(age_total_deaths, 'plot_age_totals_data.csv')


# Make ggplot of Condition vs Deaths by age (fill)
gg_age_totals <- age_total_deaths %>%
    ggplot(mapping = aes(x = Age.Group, y = Total.Deaths)) +
    geom_col(fill = 'royalblue2', width = 0.75) +
    labs(x='', y='',
         title = 'COVID-19 has Disproportionately Affected Elderly Americans',
         subtitle = 'US Deaths Per 100,000 Persons by Age Group (Jan - Oct 2020)') +
         # caption = '*MCVD = Major Cardiovascular Diseases') +
    # scale_y_continuous(labels = function(y) {paste0(y/1000, 'k')}) +
                       # limits = c(0, 80000)) +
    # scale_fill_brewer(breaks = rev(unique(age_total_deaths$Age.Group)),
    #                   palette = 'OrRd') +
    # coord_flip() +
    # theme_dark() +
    theme(plot.title = element_text(size = 16),
          plot.subtitle = element_text(face = 'italic', size = 11),
          panel.grid.major.x = element_blank(),
          axis.text = element_text(size = 10),
          # legend.background = element_rect(fill = 'gray90'),
          # legend.position = c(0.85, 0.2),
          # legend.title = element_blank(),
          # legend.spacing.x = unit(0.25, 'cm'),
          # legend.key = element_rect(color = 'white'),
          axis.ticks = element_blank())

# pdf("plots/age_totals.pdf", width = 900, height = 600)
# pdf("plots/age_totals.pdf", paper='USr')
pdf("plots/age_totals.pdf")
print(gg_age_totals)

dev.off()

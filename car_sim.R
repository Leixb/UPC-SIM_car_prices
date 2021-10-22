library(tidyverse)
library(corrplot)

df <- read_rds_w_checksum("./data/dataset.rds")

# 1. Determine if the response variable (price) has an acceptably normal distribution. Address test to discard serial correlation.

price_log <- log(df$price)

hist(df$price, 30)
hist(price_log, 30)

#Testing normality of price and log(price) with Shapiro test
shapiro.test(df$price)  
shapiro.test(price_log)

#Testing normality with Kolmogorov-Smirnov test
df$price %>% ks.test("pnorm", mean=mean(.), sd=sd(.)) 
price_log %>% ks.test("pnorm", mean=mean(.), sd=sd(.)) 


# 2. Indicate by exploration of the data which are apparently the variables most associated with the response 
# variable (use only the indicated variables).

df %>%
  select(where(is.numeric)) %>%
  cor(use = "complete.obs") %>%
  corrplot()


# 3. Define a polytomic factor f.age for the covariate car age according to its quartiles and argue if 
# the average price depends on the level of age. Statistically justify the answer.

df %>%
  ggplot(aes(x=age_aux, y=price, color = age_aux)) +
  geom_boxplot()

anova <- aov(price ~ age_aux, data = df)
summary(anova)
TukeyHSD(anova)


# 4. Calculate and interpret the anova model that explains car price according to the age factor and the fuel type.

df %>%
  ggplot(aes(x=age_aux, y=price, color = fuelType)) +
  geom_boxplot()

anova <- aov(price ~ age_aux * fuelType, data = df)
summary(anova)

group_by(df, age_aux, fuelType) %>%
  summarise(
    count = n(),
    mean = mean(price, na.rm = TRUE),
    sd = sd(price, na.rm = TRUE)
)

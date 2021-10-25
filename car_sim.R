library(tidyverse)
library(corrplot)
library(car)
library(olsrr)

df <- read_rds_w_checksum("./data/dataset.rds")


# 1. Determine if the response variable (price) has an acceptably normal distribution. Address test to discard serial correlation.

price_log <- log(df$price)
hist(df$price, 30)
hist(price_log, 30)

# Testing normality of price and log(price) with Shapiro test
shapiro.test(df$price)  
shapiro.test(price_log)

# Testing normality with Kolmogorov-Smirnov test
df$price %>% ks.test("pnorm", mean=mean(.), sd=sd(.)) 
price_log %>% ks.test("pnorm", mean=mean(.), sd=sd(.))

# Serial correlation
dwtest(price~age,data=df)


# 2. Indicate by exploration of the data which are apparently the variables most associated with the response 
# variable (use only the indicated variables).

df %>%
  select(where(is.numeric)) %>%
  cor(use = "complete.obs") %>%
  corrplot()


# 3. Define a polytomic factor f.age for the covariate car age according to its quartiles and argue if 
# the average price depends on the level of age. Statistically justify the answer.

df %>%
  ggplot(aes(x=aux_age, y=price, color = aux_age)) +
  geom_boxplot()

anova <- aov(price ~ aux_age, data = df)
summary(anova)

# Check anova assumptions
# Homogenity of variance
plot(anova, 1)
leveneTest(price ~ aux_age, data = df)
bartlett.test(price ~ aux_age, data = df)

# Normality assumption
plot(anova, 2)
shapiro.test(residuals(anova))


# 4. Calculate and interpret the anova model that explains car price according to the age factor and the fuel type.

df %>%
  ggplot(aes(x=aux_age, y=price, color = fuelType)) +
  geom_boxplot()

group_by(df, aux_age, fuelType) %>%
  summarise(
    count = n(),
    mean = mean(price, na.rm = TRUE),
    sd = sd(price, na.rm = TRUE)
  )

anova <- aov(price ~ aux_age * fuelType, data = df)
summary(anova)

# 5. Do you think that the variability of the price depends on both factors? Does the relation between price and age factor depend on fuel type?
summary(anova)


# 6. Calculate the linear regression model that explains the price from the age: interpret the regression line and assess its quality.

lm = lm(price ~ age, df)
summary(lm)


# 7. What is the percentage of the price variability that is explained by the age of the car?

summary(lm)

  
# 8. Do you think it is necessary to introduce a quadratic term in the equation that relates the price to its age?

lm_mileage = lm(price ~ age+I(age^2), df)
plot(lm)


# 9. Are there any additional explanatory numeric variables needed to the car price? Study collinearity effects.
lm = lm(price ~ ., data = df %>% select(where(is.numeric)))
summary(lm)

# Collinearity
df %>%
  select(where(is.numeric)) %>%
  cor(use = "complete.obs") %>%
  corrplot()

lm_mileage = lm(mileage ~ . - price, df %>% select(where(is.numeric)))
summary(lm_mileage)
lm_tax = lm(tax ~ . - price, df %>% select(where(is.numeric)))
summary(lm_tax)
lm_mpg = lm(mpg ~ . - price, df %>% select(where(is.numeric)))
summary(lm_mpg)
lm_age = lm(age ~ . - price, df %>% select(where(is.numeric)))
summary(lm_age)

# 10. After controlling by numerical variables, indicate whether the additive effect of the available factors on the price are statistically significant.


# 11. Select the best model available so far. Interpret the equations that relate the explanatory variables to the answer (rate).
 

# 12. Study the model that relates the logarithm of the price to the numerical variables.

lm = lm(price_log ~ ., data = df %>% select(where(is.numeric)))
summary(lm) 
plot(lm)


# 13. Once explanatory numerical variables are included in the model, are there any main effects from factors needed?
   

# 14. Graphically assess the best model obtained so far.
 

# 15. Assess the presence of outliers in the studentized residuals at a 99% confidence level. Indicate what those observations are.
 

# 16. Study the presence of a priori influential data observations, indicating their number according to the criteria studied in class.
 

# 17. Study the presence of a posteriori influential values, indicating the criteria studied in class and the actual atypical observations.
 

# 18. Given a 5-year old car, the rest of numerical variables on the mean and factors on the reference
 

# 19. Summarize what you have learned by working with this interesting real dataset.

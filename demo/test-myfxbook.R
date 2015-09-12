library(ggplot2)
library(scales)
library(reshape2)
library(plyr)

library(myfxbook.R)

credentials = as.list(readJSONStream("../myfxbook-login.json"))

fx <- myfxbook$new(email = credentials$username, password = credentials$password, debug = TRUE)

# -> ACCOUNT DETAILS
#
fx$my.accounts()
fx$watched.accounts()

# -> OUTLOOK (ALL PAIRS)
#
outlook = fx$outlook()
dim(outlook)
head(outlook)
#
outlook.percents = melt(outlook, id.vars = "name",
                        measure.vars = paste0(c("short", "long"), "Percentage"))
#
# Normalise (not all percentages sum to 100%)
#
outlook.percents = ddply(outlook.percents, .(name), function(df) {
  df$value = df$value / sum(df$value)
  df
})
#
# Remove entries with missing data
#
outlook.percents = outlook.percents[complete.cases(outlook.percents),]
#
# 1. Neaten up long/short labels
# 2. Sort according to fraction of shorts
#
outlook.percents = transform(outlook.percents,
                             variable = sub("Percentage", "", variable),
                             name = reorder(name, outlook.percents$value, function(x) {x[2]})
                             )
#
png("fig/long-short-proportion-pairs.png", width = 600, height = 800)
ggplot(outlook.percents, aes(x = name, y = value)) +
  geom_bar(aes(fill = variable), stat = "identity") +
  xlab("") + ylab("") +
  coord_flip() +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_brewer(name = "", palette="BuGn") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))
dev.off()

# -> OUTLOOK (SINGLE PAIR, COUNTRY DETAILS)
#
outlook = fx$outlook.country("EURUSD")
dim(outlook)
head(outlook)
#
outlook.positions = melt(outlook, id.vars = "name",
                        measure.vars = paste0(c("short", "long"), "Positions"))
#
# Remove entries with missing data
#
outlook.positions = subset(outlook.positions, value > 0)
#
# 1. Neaten up long/short labels
# 2. Sort according to total positions
#
outlook.positions = transform(outlook.positions,
                             variable = sub("Positions", "", variable),
                             name = reorder(name, outlook.positions$value, function(x) {1 / sum(x)})
)
#
png("fig/long-short-positions-country.png", width = 600, height = 1200)
ggplot(outlook.positions, aes(x = name, y = value)) +
  geom_bar(stat = "identity") +
  xlab("") + ylab("Positions") +
  facet_wrap(~ variable, nrow = 1) +
  coord_flip() +
  scale_y_log10() +
  theme_classic()
dev.off()

# -> OPEN TRADES
#
# The account number here is the one on myfxbook
#
fx$open.trades(893887)
fx$open.orders(893887)
#
fx$gain(893887, "2014-04-01", "2014-04-17")
fx$daily.gain(893887, "2014-04-01", "2014-04-17")
#
fx$history(893887)
#
rm(fx)

# We can force the destructor to be called by activating garbage collection
#
gc()

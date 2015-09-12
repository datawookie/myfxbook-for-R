# Details of API are given at http://www.myfxbook.com/api
#
# Refer to web technologies task view on CRAN (http://cran.r-project.org/web/views/WebTechnologies.html)

# Details of hooking up myfxbook to MetaTrader: http://www.myfxbook.com/help/connect-metatrader-publisher

# ---------------------------------------------------------------------------------------------------------------------

fix.sizing <- function(J) {
  ldply(J, function(L) {
    L$size.type = L$sizing[1]
    L$size.value = L$sizing[2]
    #
    L$sizing = NULL
    #
    as.data.frame(L)
  })
}

myfxbook <- setRefClass(Class = "myfxbook",
                        fields = list(
                          debug = "logical",
                          session = "character"
                        ),
                        methods = list(
                          interact = function(url) {
                            url = URLencode(paste0("https://www.myfxbook.com/api/", url))
                            #
                            if (debug) print(url)
                            #
                            json = RCurl::getURL(url, ssl.verifypeer = FALSE, verbose = FALSE)
                            #
                            if (debug) print(json)
                            #
                            fromJSON(json)
                          },
                          login = function(email, password) {
                            J = interact(sprintf("login.json?email=%s&password=%s", email, password))
                            #
                            session <<- J$session
                          },
                          logout = function() {
                            interact(sprintf("logout.json?session=%s", session))
                          },
                          my.accounts = function() {
                            J = interact(sprintf("get-my-accounts.json?session=%s", session))
                            #
                            do.call(rbind.data.frame, J$accounts)
                          },
                          watched.accounts = function() {
                            J = interact(sprintf("get-watched-accounts.json?session=%s", session))
                            #
                            do.call(rbind.data.frame, J$accounts)
                          },
                          outlook = function() {
                            J = interact(sprintf("get-community-outlook.json?session=%s", session))
                            #
                            do.call(rbind.data.frame, J$symbols)
                          },
                          outlook.country = function(symbol) {
                            J = interact(sprintf("get-community-outlook-by-country.json?session=%s&symbol=%s", session, symbol))
                            #
                            do.call(rbind.data.frame, J$countries)
                          },
                          open.trades = function(account) {
                            J = interact(sprintf("get-open-trades.json?session=%s&id=%d", session, account))
                            #
                            fix.sizing(J$openTrades)
                          },
                          open.orders = function(account) {
                            J = interact(sprintf("get-open-orders.json?session=%s&id=%d", session, account))
                            #
                            fix.sizing(J$openOrders)
                          },
                          gain = function(account, from, to) {
                            J = interact(sprintf("get-gain.json?session=%s&id=%d&start=%s&end=%s", session, account, from, to))
                            #
                            J$value
                          },
                          daily.gain = function(account, from, to) {
                            J = interact(sprintf("get-daily-gain.json?session=%s&id=%d&start=%s&end=%s", session, account, from, to))
                            #
                            do.call(rbind, lapply(J$dailyGain, function(L) {do.call(rbind.data.frame, L)}))
                          },
                          history = function(account) {
                            J = interact(sprintf("get-history.json?session=%s&id=%d", session, account))
                            #
                            fix.sizing(J$history)
                          },
                          initialize = function(email, password, ...) {
                            callSuper(...)
                            #
                            if (length(debug) == 0) debug <<- FALSE
                            #
                            login(email, password)
                            #
                            .self
                          },
                          finalize = function() {
                            logout()
                          }
                        )
)

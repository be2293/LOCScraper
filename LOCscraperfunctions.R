library(rvest)
library(stringr)
library(xml2)
library(dplyr)
library(httr)
library(writexl)
#replace with your own directory
setwd("Your_Directory_Here")



#Function that scrapes a single page of the LOC
#Input: URL link, name of subject
#Output: dataset of 100 entries of Title, Year, Classification (legacy) and Subject
LOCScrape = function(TheLink,SubjectName) {
  
  #This block of code opens, reads, and closes a connection to the URL and searches the HTML output for the lines indicating a title. 
  open(url(TheLink))
  PageHTML = readLines(url(TheLink))
  closeAllConnections()
  TargetPhrase = "list-description-title"
  LinesContainingTarget <- grep(TargetPhrase, PageHTML, value = FALSE)
  
  
  #This block of code collects the line texts containing the year, title, and classification. 
  #The added numbers are the distance between the needed line and the reference line
  Year = c()
  Title = c()
  Classification = c()
  for (x in 1:100) {
    Year = append(Year, PageHTML[LinesContainingTarget[x]+3])
    Title = append(Title, PageHTML[LinesContainingTarget[x]+1])
    Classification = append(Classification, PageHTML[LinesContainingTarget[x]+4] )
  }
  
  
  #This block cleans the raw lines, stripping out everything but the year, title, and classification, and coercing years down to the first year shown. 
  for (x in 1:100) {
    Year[x] = gsub("[^0-9]", "", Year[x])
    Title[x] = substr(Title[x], gregexpr(">", Title[x])[[1]][1]+1, nchar(Title[x])-4)
    Classification[x] = substr(Classification[x], gregexpr(">", Classification[x])[[1]][1]+1, nchar(Classification[x])-6)
  }
  for (x in 1:100){
    Year[x] = substr(Year[x], 1, 4)
  }
  
  
  
  #creates a dataframe, assigns it if a total dataframe doesn't exist, and adds it to an existing one if one does
  df = as.data.frame(Title)
  df$Year = Year
  df$Classification = Classification
  df$Subject = SubjectName
    assign("CurrentDataFrame", df, envir = .GlobalEnv)
  if (exists("TotalDataFrame", envir = .GlobalEnv )==FALSE) {
    assign("TotalDataFrame", df, envir = .GlobalEnv)
  } else {
    assign("TotalDataFrame",rbind(TotalDataFrame, df), envir = .GlobalEnv)
  }
}



#This function determines the number of pages associated with a particular subject query
#Input is the url
#Output is either NA (no pages associated) or a number>0 indicating the number of pages
DeterminePageCount = function(x){
  
  #Opens, reads, and closes a connection to the URL
  open(url(x))
  PageCountHTML = readLines(url(x))
  closeAllConnections() 
  
  #Checks whether a site was reached. WarningFlag flags a line that is present only if the library encountered an error, not if no pages are associated with the query
  WarningFlag = grep("No Connections Available", PageCountHTML)[1]
  
  
  #If a warning flag was not thrown, gets the number of pages. If one is, loops the original code block until there is no warning flag
  if (is.na(WarningFlag)) {
    PhraseContainingCount = "results-bar-item results-bar-item-record-count"
    LineContainingCount <- grep(PhraseContainingCount, PageCountHTML, value = FALSE)[1]
    CountLineText = PageCountHTML[LineContainingCount]
    CountLineText = gsub("[^0-9]", "", CountLineText)
    CountLineText = as.numeric(substr(CountLineText, 5, 8))
    CountLineFinal = ceiling(CountLineText/100)
    CountLineFinal
  } else {
    while (is.na(WarningFlag)== FALSE) {
      open(url(x))
      PageCountHTML = readLines(url(x))
      closeAllConnections() 
      WarningFlag = grep("No Connections Available", PageCountHTML)[1]
    }
    PhraseContainingCount = "results-bar-item results-bar-item-record-count"
    LineContainingCount <- grep(PhraseContainingCount, PageCountHTML, value = FALSE)[1]
    CountLineText = PageCountHTML[LineContainingCount]
    CountLineText = gsub("[^0-9]", "", CountLineText)
    CountLineText = as.numeric(substr(CountLineText, 5, 8))
    CountLineFinal = ceiling(CountLineText/100)
    CountLineFinal
  }
}

#creates an LOC link associated with a query, input is subject name and page count
#The URL represents a search for books in English, between 1500 and 1930, with 100 records per page, with the KSUB search being CleanQuery and the page number being PageNumber (0 = 1, 1=2, etc.)
LinkCreator = function(Query,PageNumber) {
  CleanQuery = gsub(" ", "%20", Query)
  paste0("https://catalog.loc.gov/vwebv/search?searchArg1=", CleanQuery, "&argType1=all&searchCode1=KSUB&searchType=2&combine2=and&searchArg2=&argType2=all&searchCode2=GKEY&combine3=and&searchArg3=&argType3=all&searchCode3=GKEY&year=1523-2023&yearOption=range&fromYear=1500&toYear=1930&location=all&place=all&type=am&language=ENG&recCount=100&recPointer=", PageNumber, "00")
}



#This function combines the previous functions to scrape all data associated with a subject
#Takes in a query e.g. "Agriculture" and outputs a dataframe listed as TotalDataFrame with all the relevant entries 
FullSubjectSearch = function(x){
  
  
  #Generates a URL from the subject corresponding to the subject, and determines the page count of the query.
  UrlLink = LinkCreator(x, 0)
  TheNumberOfPages = DeterminePageCount(UrlLink)
  
  #If no pages are associated, immediately aborts. Otherwise, performs LOCScrape functionality on each page associated with the query
  if (is.na(TheNumberOfPages)) {
    
  } else {
  for (p in 1:TheNumberOfPages) {
    UrlLink = LinkCreator(x,p-1)
    LOCScrape(UrlLink, x)
    while (is.na(TotalDataFrame$Title[nrow(TotalDataFrame)-99])) {
      LOCScrape(UrlLink, x)
    }
  }
  }
}


#Function to clean data provided. Removes NAs, duplicate entries, and invalid years
#Input is a dataframe to be cleaned, output is a cleaned dataset 
CleanData = function(x) {
  CleaningData = na.omit(x)
  CleaningData = CleaningData %>%
    distinct(Title, Year, .keep_all = TRUE)
  CleaningData = subset(CleaningData, CleaningData$Year > 1499)
  CleaningData = subset(CleaningData, CleaningData$Year < 1931)
  CleanedData = subset(CleaningData, nchar(CleaningData$Year)==4)
  assign("CleanedData", CleanedData, envir = .GlobalEnv)
}
#-------------------------------------------------------------------------------------------------------------------------------

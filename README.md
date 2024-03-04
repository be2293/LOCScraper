# LoC Scraper

*Created by Benjamin Eyal, January 2024.*

This program scrapes the catalog of the Library of Congress (LoC) for technical books published between 1500 and 1930.

The program records the following data for each book:
- Title
- Publication year
- Subject (subject name used in the search)
- Classification code (currently, due to library non-uniformity, this information is not useful)

## Search details
The searches made by this scraper are equivalent to filling out the following fields in the advance search (https://catalog.loc.gov/vwebv/searchAdvanced?editSearchId=E) form of the catalog:
- [x] Subject: ALL (KSUB): INPUT SUBJECT
- [x] Years Published/Created: From 1500 to 1930
- [x] Location in the Library: All Locations in the Library
- [x] Place of Publication: All Places
- [x] Type of Material: Book
- [x] Language: English
- [x] Records per page: 100

The scraper will scrape all of the results pages. If a search does not have any results, the program will not have any output. If it does, you will find a dataset titled TotalDataFrame in the global environment. 

## Saving Results
The program will save the scraped results to an R dataframe. The example code provided will save it to a CSV, which can be ported to a SQL database or anything else needed. 

## URLs
When you run this program, make sure that the program is using the most up-to-date URL structure. If the LoC changes the URLs structure, the program will have no output. 

You can make edits to how the program builds the URL by updating the URL templates defined in the function in the LOCscraperfunctions file:
- [x] LinkCreator (Builds the URL for a search)

All searches have the same URL structure. We can easily manipulate the URL to get the search results that we want. 

Here is the URL template that the program is currently using. 
```R
url =   paste0("https://catalog.loc.gov/vwebv/search?searchArg1=", CleanQuery, "&argType1=all&searchCode1=KSUB&searchType=2&combine2=and&searchArg2=&argType2=all&searchCode2=GKEY&combine3=and&searchArg3=&argType3=all&searchCode3=GKEY&year=1523-2023&yearOption=range&fromYear=1500&toYear=1930&location=all&place=all&type=am&language=ENG&recCount=100&recPointer=", PageNumber, "00")
```
## Functions
If you want to scrape a topic, or group of topics, load the functions in LOCScraperfunctions.R to your workspace. Then, run the following code:
```R 
#choose your set of topics (as a list of strings)
topic_set = c("YOUR QUERIES HERE")

#Search for all topics
for (k in  1:length(topic_set)) {
  FullSubjectSearch(topic_set[k])
}
#cleans the data found
CleanData(TotalDataFrame)
#sends a csv to your current directory
write.csv(CleanedData, "CleanLOCData.csv")
```
The function FullSubjectSearch is structured as follows:
1. Check whether the search has results. If not, immediately abort. 
2. Extract the number of results pages associated with that search.
3. Loop through each page number and:
   1. Extract all of the book info from the page.
   2. Save the results of the page to a dataframe
   3. If the program encounters an error (No Connections Available), the program will reattempt the connection until the error is no longer relevant.
4. The program ends after scraping the last page.
The function CleanData is structured as follows:
1. Create a duplicate dataframe to the input. 
2. Remove NAs, duplicate entries, and invalid years.
3. Save the new dataframe to the workspace as CleanedDat

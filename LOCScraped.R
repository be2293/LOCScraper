setwd("C:/Users/starc/OneDrive/Documents/Columbia/Year 3/Semester 2/Research/USA")

#here is the code I used to generate the result. 


#You can change the topic list for your preferences
topic_set = c(    "Technology","Engineering", "Construction",
                  "Civil engineering", "Architecture", "Mechanical engineering",
                  "Nuclear engineering", "Electrical engineering", "Electronic engineering",
                  "Maritime engineering", "Naval engineering", "Metal engineering",
                  "Mining engineering", "Chemical technology", "Manufacturing", 
                  "Domestic arts", "Domestic sciences", "Industry",
                  "Commerce","Agriculture","Horticulture",
                  "Silk industry","Animal husbandry","Forestry",
                  "Fishing","Commerce","Transportation",
                  "Traffic","Communications")

for (k in  1:length(topic_set)) {
  FullSubjectSearch(topic_set[k])
}
CleanData(TotalDataFrame)
write.csv(CleanedData, "CleanLOCData.csv")

















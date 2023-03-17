#libraries to download
library(tidyverse)
library(packrat)
if(!requireNamespace("dataMeta"))
  install.packages("dataMeta", repos = "https://cloud.r-project.org")
library("dataMeta")
library(MASS)
library(gridExtra)

#Note! csv was exported from Qualtrics and then another column was added to clean the "years of experience" field. The largest number given was taken regardless of instrument and professional level
data_orig = read.csv("2_24_21 pit survey data results_edit8_24_21.csv",na.strings=c("","NA",-99))
data = data_orig[-c(1,2),]

#### demographic vars cleaning
data = data %>% rename(gender= Q1,birth.year=Q3, instrument=Q4,composer=Q5, arranger=Q6, music.degree=Q8,other.degree=Q9,loans=Q10,mainly.music=Q11,second.career=Q12,pit.currently = Q13, tour.ever = Q14,  why.no.tour = Q17,consider.touring = Q21,wish.work.more = Q22, looking = Q18,passed.over.bc = Q23,status=Q24,kids = Q25, dependents = Q26, live.in = Q27, job.security = Q28, anxiety.job.security = Q29.1,main.chair = Q15,sub.tour = Q16, max.years.training = Q7a)
data = data %>% dplyr::select(IPAddress,gender,birth.year,instrument,composer,arranger,music.degree,other.degree,loans,mainly.music,second.career,pit.currently,tour.ever,passed.over.bc,looking,status,kids,dependents,live.in,job.security,anxiety.job.security,bucketed_gender,wish.work.more,main.chair,sub.tour, consider.touring,why.no.tour, max.years.training)
#demographics = data %>% select(gender,birth.year,instrument,composer,arranger,years.training,music.degree,other.degree,loans,mainly.music,second.career)


#data = data %>% mutate(* = na_if(*,""))
data = droplevels(data)

data$birth.year = plyr::revalue(data$birth.year, c("9185" = "1985", "199" = "NA", "1048" = "1948", "-988" = "1988", "01021996" = "1996","-99"="NA"))

#Function to expand data
expand.delimited <- function(x, col1, col2, sep=",") {
  rnum <- 1
  expand_row <- function(y) {
    factr <- y[col1]
    strng <- toString(y[col2])
    expand <- strsplit(strng, sep)[[1]]
    num <- length(expand)
    factor <- rep(factr,num)
    return(as.data.frame(cbind(factor,expand),
                         row.names=seq(rnum:(rnum+num)-1)))
    rnum <- (rnum+num)-1
  }
  expanded <- apply(x,1,expand_row)
  df <- do.call("rbind", expanded)
  names(df) <- c(names(x)[col1],names(x)[col2])
  return(df)
}

#expanding
data1 = expand.delimited(data,col1=1,col2=4) #instrument
data1 = data1 %>% mutate(IPAddress = as.factor(IPAddress))
data_instruments = right_join(data1, data,by='IPAddress')

data2 = expand.delimited(data,col1=1,col2 = 12) #pit currently
data2 = data2 %>% mutate(IPAddress = as.factor(IPAddress))
data_pit.currently = right_join(data2, data,by='IPAddress')

data3 = expand.delimited(data,col1=1,col2 = 14) #passed over bc
data3 = data3 %>% mutate(IPAddress = as.factor(IPAddress))
data_po = right_join(data3, data,by='IPAddress')

#create a data dictionary
instrument.list = c("NA", "piano","keyboard","flute","clarinet","piccolo","oboe","trumpet","flugelhorn","saxophone-with write in","trombone","tuba","french horn","violin","viola","cello","acoustic bass","electric bass","acoustic guitar","electric guitar","harp - with write in","drums","percussion","other - with write in")

data = data[!duplicated(data$IPAddress),]
clean_dat = data
clean_dat$yob = strtoi(clean_dat$birth.year)
clean_dat$age = 2021-clean_dat$yob
clean_dat$main.chair = strtoi(gsub("[^0-9.-]", "", clean_dat$main.chair)) #is this fair?
clean_dat$sub.tour = strtoi(gsub("[^0-9.-]", "", clean_dat$sub.tour))
clean_dat$woman = ifelse(clean_dat$bucketed_gender=="female",1,0)
clean_dat$not_w = ifelse(clean_dat$woman==1,0,1)

#Now to group the instruments into sections#############





###### Changing back to Strings for some of the questions #######
subset_cd_nums = c(5:11,13,15:22,27) # pulled out easy columns
subset_cd = clean_dat[,subset_cd_nums]
subset_cd$music.degree = plyr::revalue(subset_cd$music.degree, c("1" = "None","2" = "Bachelor's Degree","3" = "Master's Degree","4"="DMA","5" = "PhD"))
subset_cd$loans = plyr::revalue(subset_cd$loans, c("1" = "Yes, paid off completely","2" = "Yes, paid off more than 50% to date","3" = "Yes, I owe more that 50% to date","4"="No"))
subset_cd$looking = plyr::revalue(subset_cd$looking,c("1" = "Broadway Pit","2" = "Broadway Touring Pit","3" = "Non Union Touring Pit","4"="Regional Theater","5" = "Community Theater","6" = "No - I'm currently employed","No, not looking"))


######### Break apart Columns -- where respondants had more than one answer, each answer was turned into a "yes/no" column #####
po_1 = data_po %>%mutate(passed_over = recode(passed.over.bc.x,"1"="age","2" = "gender","3"="race","4"="religion","5"="political views","6" = "location","7" = "nepotism","8"="other - write in")) %>% 
  mutate(yes_no = 1) %>%
  distinct %>%
  spread(passed_over, yes_no, fill = 0)

po = po_1[!duplicated(po_1$IPAddress),]

#######
data_pit.currently$orig_gender = data_pit.currently$gender
data_pit.currently$gender = data_pit.currently$bucketed_gender
#View(data_pit.currently)
po_2 = data_pit.currently %>% mutate(pit.currently = recode(pit.currently.x,"1"="broadway","2" = "broadway.touring","3"="non.union.touring","4"="regional.theater","5"="community.theater")) %>% 
  mutate(yes_no = 1) %>%
  distinct %>%
  spread(pit.currently, yes_no, fill = 0)

po2 = po_2[!duplicated(po_2$IPAddress),]


########
data_instruments$orig_gender = data_instruments$gender
data_instruments$gender = data_instruments$bucketed_gender

po_i = data_instruments %>% mutate(instruments = recode(instrument.x,"1"="piano","2" = "keyboard","3"="flute","4"="clarinet","5"="piccolo","6"="oboe","7"="trumpet","8"="flugelhorn","9"="saxaphone-write in","10"="trombone","11"="tuba","12"= "french horn", "13"="violin","14"="viola","15" = "cello","16" ="acoustic bass","17"="electric bass","18"="acoustic guitar","19"="electric guitar","20"="harp","21"="drums","22"="percussion","23"="other")) %>% 
  mutate(yes_no = 1) %>%
  distinct %>%
  spread(instruments, yes_no, fill = 0)

poi = po_i[!duplicated(po_i$IPAddress),]


#piano isn't in any family listed? Not sure where it goes...
poi$string = ifelse(poi$violin == 1 | poi$viola ==1 | poi$cello | poi$`acoustic bass`, 1,0)#c[violin,viola,acoustic bass,cello ]
poi$brass = ifelse(poi$trumpet ==1|poi$flugelhorn==1 |poi$trombone==1|poi$tuba==1|poi$`french horn`==1,1,0) #trumpet,flugelhorn,trombone,tuba,frenchhorn,
poi$wwind = ifelse(poi$flute==1|poi$clarinet==1|poi$piccolo==1|poi$oboe==1|poi$`saxaphone-write in`==1,1,0)#flute,clarinet,piccolo,oboe,saxophone
poi$rhythm = ifelse(poi$`acoustic guitar`==1 | poi$`electric guitar`==1 | poi$`electric bass`==1| poi$drums==1 | poi$percussion==1,1,0)
#master_chi_instrument(colStart=49,colEnd=52,df=poi,gender_column="bucketed_gender")
poi$piano_or_keyboard = ifelse(poi$piano == 1 | poi$keyboard==1,1,0)

poi_nodupes = poi[!duplicated(poi$IPAddress),] #to keep the instrument families from overcounting

#########
#transform data so that we pivot for each of the instruments
poi_sum = poi %>% group_by(piano, keyboard, flute,clarinet,piccolo,oboe,trumpet,flugelhorn,`saxaphone-write in`,trombone,tuba,`french horn`,violin,viola,cello,`acoustic bass`,`electric bass`,`acoustic guitar`,`electric guitar`,harp,drums, percussion) %>% mutate(num = n())


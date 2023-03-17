# data = read.csv("2_22_20 pit survey data prelim results.csv")
# data = data[-c(1,2,3),] #get rid of import information
# data[data==""]<-NA
# #### demographic vars cleaning
# demographics = data %>% select(gender= Q1,birth.year=Q3, instrument=Q4,composer=Q5, arranger=Q6, years.training=Q7,music.degree=Q8,other.degree=Q9,loans=Q10,mainly.music=Q11,second.career=Q12)
# dem = demographics %>% mutate(birth.year = as.factor(birth.year), instrument = as.factor(instrument), composer = as.factor(composer), arranger = as.factor(arranger), music.degree = as.factor(music.degree), other.degree=as.factor(other.degree), loans = as.factor(loans), mainly.music = as.factor(mainly.music), second.career = as.factor(second.career))
# 
# dem$gender = revalue(dem$gender, c("1"="male", "2"="female", "4" =  "trans male", "5" = "nonconforming"))
# dem$gender = dem$gender[-c("To which gender identity do you most identify? - Selected Choice"),]
# dem$birth.year = revalue(dem$birth.year, c("9185" = "1985", "199" = "NA", "1048" = "1948", "-988" = "1988", "01021996" = "1996", "{\"ImportId\":\"QID3_TEXT\"}" = "NA", "What is your year of birth (please enter the 4 digit year of your birth)"= "NA"))
# dem$birth.year = as.numeric(as.character(dem$birth.year))
# dem$music.degree = revalue(dem$music.degree, c("1" = "None", "2"="bachelors", "3" = "masters", "4" = "dma", "5" = "phd"))
# dem$other.degree =revalue(dem$other.degree, c("1" = "yes", "2" = "no"))
# dem$loans = revalue(dem$loans, c("1" = "paid off", "2" = "mostly paid off", "3" = "paying off", "4"= "no"))
# dem$mainly.music = revalue(dem$mainly.music, c("1" = "yes", "2" = "no"))
# dem$second.career = revalue(dem$second.career,c("1" = "yes", "2" = "no"))
# 
# ##block 1 - or outcome measures
# outcomes = data %>% select(pit.currently = "Q13", tour.ever = "Q14", where.looking = "Q15", consider.tour = "Q16", wish.work.more = "Q17", passed.over.bc = "Q18")
# outcomes$pit.currently =  revalue(outcomes$pit.currently,c("1" = "broadway", "2"="broadway.tour", "3" = "nonunion.tour" , "4" = "regional.theater", "5" = "community.theater"))
# outcomes$tour.ever = revalue(outcomes$tour.ever, c("1" = "yes", "2" = "no"))
# 
# 
# a = cbind(dem, outcomes)
# 
# ##block 2 - SES & family situation
# block_2  = data %>% select(status=Q24,kids = Q25, dependents = Q26, live.in = Q27, job.security = Q28, anxiety.job.security = Q29) #, Q19)#Q20","Q21" )
# block_2$status = revalue(block_2$status, c("1" = "single", "2" = 'divorced', "4" = 'engaged', "5" = 'relationship', "6" = 'married'))
# block_2$kids = revalue(block_2$kids, c("1" = "yes", "2"="no.plan", "3"="one.day"))
# block_2$dependents = revalue(block_2$dependents, c("1" = "yes", "2"="no"))
# block_2$live.in =revalue(block_2$live.in, c("1" = "rented.room", "2"= "rented.apartment", "3"="rented.house", "4" = "mortgaged.property", "5"="paid.property"))
# block_2$job.security =revalue(block_2$job.security, c("1"="very.secure", "2"="somewhat.secure", "3" = "not.secure"))
# 
# dat = cbind(a,block_2)
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 

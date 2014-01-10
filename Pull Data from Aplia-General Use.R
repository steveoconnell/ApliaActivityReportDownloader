######################################################
#you input your information in the following section
setwd( "C:/myworkingdirectorypath/" )
your.username <- 'myapliausername'
your.password <- 'myapliapassword'
#the following needs to contain a list of the 'ctx' codes for the courses for which you are an admin. 
#you can detect these on the homepage after signin to Aplia, then scroll over the links under 'my courses'
#there can be from 1...n courses listed here
classes <- c('mycoursecode1', 'mycoursecode2', ...)
######################################################

#initial setup
date <- Sys.Date()
require(RCurl)
require(XML)
require(cwhmisc)
require(plyr)
require(stringr)

#set options
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
curl = getCurlHandle()
curlSetOpt(
cookiejar = 'cookies.txt' ,
useragent = agent,
followlocation = TRUE ,
autoreferer = TRUE ,
curl = curl
)

# construct a list full of parameters to pass to the website
params <-
list(
'txtEmail' = your.username,
'txtPassword' = your.password
    )

###set up files and folders
#this removes the existing student list file if you have run the code before, otherwise returns a noninfluential error
file.remove(paste0(getwd(),"/","class_list.csv"))
#this creates the subfolder where the activity reports will be generated; if already exists, warning suppressed
dir.create(file.path(getwd(), ActivityReports), showWarnings = FALSE)

# # # # # # # # # # # # #
# custom save function  #
# extracting the list of students (class lists) to pass to the report generating javascript
# ..a course number, the parameters list, and the curl options
save.students <- function(ctx, params, curl ) {

	# logs into the form
	html = postForm('https://courses.aplia.com/af/servlet/corplogin', .params = params, curl = curl,
		style="POST")

	# extracts the text of the page with the class list
	html <-
	getURL(paste0('http://courses.aplia.com/af/servlet/mngstudents?ctx=',ctx),
		maxredirs = as.integer(20), followlocation = TRUE, curl = curl
	)
	html
	work <- htmlTreeParse(html, useInternal = TRUE)


	guid <- xpathApply(work, "//input[@value]", xmlGetAttr, "value")
	guid <- ldply(guid, ldply)
	guid <- guid[(grepl("USERAC",guid$V1)), ]

	email <- xpathApply(work, "//a[@class]", xmlValue)
	email <- ldply(email, ldply)
	email <- email[(grepl('@',email$V1)), ]

	name <-  xpathApply(work, "//td[@class]", xmlValue)
	name <- ldply(name, ldply)
	name <- name[(grepl(',',name$V1)), ]

	#the following line was done to debug and highlights that the later split command
	#operates on all comma occurrences; there may be additional debugging here if other
	#suffixes or other commas are present in the last names of students!!
	name <- gsub(pattern = ' Jr.,', replacement = '', x=name)

	#clean up text around name lines
	name <- gsub(pattern = '\r\n\t\t\t\t ', replacement = '', x=name)
	name <- gsub(pattern = '\r\n\t\t\t\t\r\n\t\t\t\t', replacement = '', x=name)
	name <- gsub(pattern = ' ', replacement = '', x=name)

	#put everything into a dataframe
	temp <- strsplit(name, ",")
	mat  <- matrix(unlist(temp), ncol=2, byrow=TRUE)
	firstlast   <- as.data.frame(mat)
	colnames(firstlast) <- c("last", "first")
	df <- data.frame(guid, email, name, ctx)
	df <- cbind(df,firstlast)
	df$name <- paste0(df$first,df$last)

	#write the table
	write.table(df, paste0(getwd(),"/","class_list.csv"),sep = ",", 
		append = TRUE, qmethod = c("d"), row.names=FALSE, col.names=FALSE)

	# clear up RAM
	gc()
	# confirm that the function worked by returning TRUE
	TRUE
}

#run the classes loop to extract student list
for (i in seq(classes)){
	save.students( classes[ i ] , params , curl )
}


# # # # # # # # # # # # #
# custom save function #
# initiate a function that requires..
# ..a class, a student id, student name,
# a constructed filepath to save the XLS sheet to, login parameters, and the curl options
save.aplia <- function( class, guid, name, file , params , curl ){
	# logs into the form
	html = postForm('https://courses.aplia.com/af/servlet/corplogin', .params = params, curl = curl,
		style="POST")

	# extracts the unique link
	html <-	getURL(
	paste0("http://courses.aplia.com/af/servlet/report?action=run_report&report_type=sa&ctx=",class,"&user_guid=",guid,"&name=",name),
		maxredirs = as.integer(20),	followlocation = TRUE, curl = curl
	)

	st <- cpos(html,"javascript:getReport('/",start=1)+22
	st
	en <- cpos(html,"')",start=st+1)-1
	en
	li <- paste0("http://courses.aplia.com",substr(html,st,en))
	li

	file <-
	getBinaryURL(
	li , curl = curl
	)
	writeBin( file , paste0(getwd(),"/ActivityReports/",guid,"_",name,"_",date,".xls"))
	# clear up RAM
	gc()

	TRUE
}

#********pull in the vectorized student list from the classes loop
inputs <- read.csv(paste0(getwd(),'/','class_list.csv'))
colnames(inputs) <- c("guid", "email", "name", "class", "last", "first")

#loop through the student activity report save function
for ( i in seq( nrow( inputs ) ) ){
	save.aplia( inputs[ i , 'class' ] , inputs[ i , 'guid' ], inputs[ i , 'name' ], file , params , curl )
}
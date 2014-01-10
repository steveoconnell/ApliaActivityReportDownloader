
# Downloading Cengage-Aplia Student User Activity Reports

R script for course instructors/TAs to automate downloading the full set of student activity reports in their Aplia courses.

## Directions

The provided R script takes the following four inputs and will download all student activity reports corresponding to the classes specified in the user input vector at the top of the script.

You will need to first create a main folder for the script to place its output, and then specify this directory in the file:

    setwd( "C:/myworkingdirectorypath/" )

Then place your login credentials in the following lines:

    your.username <- 'myapliausername'
    your.password <- 'myapliapassword'

And specify the class (ctx) codes for which you want to pull the reports. These codes can be found in the web address when you mouse over or click on your course(s) in the "My Courses" seciton of the instructor landing page. This vector must contain 1 or more entries.

    classes <- c('mycoursecode1', 'mycoursecode2', ...)


## Executing the script
A set of files will appear in the working directory when the script executes:

1) a "class_list.csv" file, containing the information for every student needed to feed into the report generator

2) an "ActivityReports" folder, containing separate activity reports for each student in the classes specified

3) a cookies file created by the options in RCurl (not needed after script runs)

## Contributing
I am happy to recieve general critique, suggestions or bug fixes on the code, or otherwise...

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgments
This script was written with heavy inspiration from Anthony J. Damico's "Analyze Survey Data For Free" repository (see https://github.com/ajdamico/usgsd/), in particular the PSID download program. Any mistakes or inelegancies in the script are attributable to me and me alone.

## License
Use in academic research will require a citation to the paper for which the code was developed:

Joyce, Ted, Sean Crockett, David A. Jaeger, R. Onur Altindag and Stephen D. O'Connell, "An experiment in online learning," City University of New York Graduate Center, mimeo, 2013.
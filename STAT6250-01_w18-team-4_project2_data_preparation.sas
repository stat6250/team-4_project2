*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Team Number] team-4

--

[Dataset 1 Name] Fire_Inspections_2016

[Dataset Description] Information on Fire Inspections performed at a given
location by the Fire Department.

[Experimental Unit Description] Fire Inspections for the year 2016

[Number of Observations] 25,045 
                   
[Number of Features] 35

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Inspections/wb4c-6hwj 

[Data Dictionary] https://data.sfgov.org/api/views/wb4c-6hwj/files/eb85e2a6-5fc5-41bb-9ec1-844e5524f000?download=true&filename=FIR-0003_DataDictionary_fire-inspections.xlsx 

[Unique ID Schema] The column "Inspection_Number" is the primary key or
unique ID, which also serves as the foreign key in datasets- 
Fire_Violations_2016 and Fire_Violations_2017. 

--

[Dataset 2 Name] Fire_Inspections_2017

[Dataset Description] Information on Fire Inspections performed at a given
location by the Fire Department.

[Experimental Unit Description] Fire Inspections for the year 2017

[Number of Observations] 24,208
                    
[Number of Features] 35

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Inspections/wb4c-6hwj 

[Data Dictionary] https://data.sfgov.org/api/views/wb4c-6hwj/files/eb85e2a6-5fc5-41bb-9ec1-844e5524f000?download=true&filename=FIR-0003_DataDictionary_fire-inspections.xlsx

[Unique ID Schema] The column "Inspection_Number" is the primary key or 
unique ID, which also serves as the foreign key in datasets- 
Fire_Violations_2016 and Fire_Violations_2017.


--

[Dataset 3 Name] Fire_Violations_2016

[Dataset Description] Information on Fire Violations issued by the
Fire Department at a given location.

[Experimental Unit Description] Fire Violations for the year 2016

[Number of Observations] 2,569
                    
[Number of Features] 19

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Violations/4zuq-2cbe 

[Data Dictionary] https://data.sfgov.org/api/views/4zuq-2cbe/files/a68685a7-41f8-432f-976d-aafb2711198e?download=true&filename=FIR-0006_DataDictionary_fire-violations.xlsx

[Unique ID Schema] The column "Violation_ID" is the unique id.

--

[Dataset 4 Name] Fire_Violations_2017

[Dataset Description] Information on Fire Violations issued by the
Fire Department at a given location.

[Experimental Unit Description] Fire Violations for the year 2017

[Number of Observations] 5,142
                    
[Number of Features] 19

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Violations/4zuq-2cbe 

[Data Dictionary] https://data.sfgov.org/api/views/4zuq-2cbe/files/a68685a7-41f8-432f-976d-aafb2711198e?download=true&filename=FIR-0006_DataDictionary_fire-violations.xlsx

[Unique ID Schema] The column "Violation_ID" is the unique id.
;


* environmental setup;


* setup environmental parameters;
%let inputDataset1URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Inspections_2016.xlsx?raw=true
;
%let inputDataset1Type = XLSX;
%let inputDataset1DSN = Fire_Inspections_2016_raw;

%let inputDataset2URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Inspections_2017.xlsx?raw=true
;
%let inputDataset2Type = XLSX;
%let inputDataset2DSN = Fire_Inspections_2017_raw;

%let inputDataset3URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Violations_2016.xlsx?raw=true
;
%let inputDataset3Type = XLSX;
%let inputDataset3DSN = Fire_Violations_2016_raw;

%let inputDataset4URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Violations_2017.xlsx?raw=true
;
%let inputDataset4Type = XLSX;
%let inputDataset4DSN = Fire_Violations_2017_raw;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename tempfile "%sysfunc(getoption(work))/tempfile.xlsx";
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%loadDataIfNotAlreadyAvailable(
    &inputDataset1DSN.,
    &inputDataset1URL.,
    &inputDataset1Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset2DSN.,
    &inputDataset2URL.,
    &inputDataset2Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset3DSN.,
    &inputDataset3URL.,
    &inputDataset3Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset4DSN.,
    &inputDataset4URL.,
    &inputDataset4Type.
)


* sort and check raw datasets for duplicates with respect to their unique ids,
  removing blank rows, if needed;
proc sort
        nodupkey
        data=Fire_Inspections_2016_raw
        dupout=Fire_Inspections_2016_raw_dups
        out=Fire_Inspections_2016_raw_sorted(where=(not(missing(Inspection_Number))))
    ;
    by
        Inspection_Address_Zipcode
        Inspection_Number
    ;
run;
proc sort
        nodupkey
        data=Fire_Inspections_2017_raw
        dupout=Fire_Inspections_2017_raw_dups
        out=Fire_Inspections_2017_raw_sorted
    ;
    by
        Inspection_Address_Zipcode
        Inspection_Number
    ;
run;
proc sort
        nodupkey
        data=Fire_Violations_2016_raw
        dupout=Fire_Violations_2016_raw_dups
        out=Fire_Violations_2016_raw_sorted
    ;
    by
        Violation_Number
    ;
run;
proc sort
        nodupkey
        data=Fire_Violations_2017_raw
        dupout=Fire_Violations_2017_raw_dups
        out=Fire_Violations_2017_raw_sorted
    ;
    by
        Violation_Number
    ;
run;


* combine Fire_Inspections_2016 and Fire_Inspections_2017 vertically and combine 
Fire_Violations_2016 and Fire_Violations_2017 vertically using proc sql which
overlays the columns that have the same name in both datasets and does not 
exclude duplicate rows;

proc sql;
    create table Fire_Inspections_1617 as
        select 
	    * 
	from 
	    Fire_Inspections_2016_raw_sorted
    union corresponding all
        select 
	    * 
	from 
	    Fire_Inspections_2017_raw_sorted
    ;
quit;

proc sql;
    create table Fire_Violations_1617 as
        select 
	    * 
	from 
	    Fire_Violations_2016_raw_sorted
    union corresponding all
        select
	    * 
	from
	    Fire_Violations_2017_raw_sorted
    ;
quit;

data Fire_Inspections_1617;
    set Fire_Inspections_1617;
    new = Put(Violation_Number, 8.);
    drop Violation_Number;
    rename new=Violation_Number
    Inspection_Type_Description=Inspection_Type;
run;
proc sort 
    data=Fire_Violations_1617; 
    by Inspection_Number; 
run;
proc sort 
    data=Fire_Inspections_1617; 
    by Inspection_Number; 
run;
* build analytic dataset from raw datasets with the least number of columns and
minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;

data SF_FireStats_1617_analytic_file;
    retain
        Inspection_Number
        Inspection_Type
        Inspection_Address_Zipcode
        Battalion
	Supervisor_District
        Address
        Violation_Id
        Violation_Item
        Zipcode
	Inspection_Start_Date
	Violation_Date
    ;
    keep
        Inspection_Number
        Inspection_Type
        Inspection_Address_Zipcode
        Battalion
	Supervisor_District
        Address
        Violation_Id
        Violation_Item
        Zipcode
	Inspection_Start_Date
	Violation_Date
    ;
    merge
        Fire_Inspections_1617
        Fire_Violations_1617
    ;
    by
	Inspection_Number
    ;
run;



****************************AS data manipulation steps*************************;
*
The first research question asks about the top 5 zipcode areas where
inspections have been done in 2016.
The reason for question 2 is to prepare a output for testing whether the
combining table which is created by sql work or not. The second resarch question
is similar to the first question to show the top 5 fire zipcode areas in 
2017.
Third question is to show the batallion and count the results that happened both 
in 2016 and 2017. 
;

*
Step- By using PROC FREQ, producing frequency table for top 5 Fire Inspection
zipcode areas where fire have happened in 2016 .PROC FREQ is used so as to view the
areas in order.
;
proc freq
       data = Work.Fire_Inspections_2016_raw noprint
   ;
   table
       Inspection_Address_Zipcode / out = Count list
   ;
       where 
           not(missing(Inspection_Address_Zipcode));
   ;
run;

*
The reason why to use sort command is to sort data count which is created above
and make the outcome looks more meaningful.By using decend count, the output
can be shown by highest to lowest.
;
proc sort
       data = Count
       out = Inspection_Count_Desc
   ;
   by
       descending count
   ;
run;

*
Step- By using PROC FREQ, producing frequency table for top 5 Fire Inspections
Type  in 2017 .PROC FREQ is used so as to view the areas in order
;
proc freq
       data = Work.Fire_Inspections_2017_raw noprint
   ;
   table
       Inspection_Type / out = Count list
   ;

run;

*
The reason why to use sort command is to sort data count which is created above
and make the outcome looks more meaningful.By using decend count, the output
can be shown by highest to lowest.
;
proc sort
       data = Count
       out = Inspection_Type_Count_Desc
   ;
   by
       descending count
   ;
run;

*
Step- By using PROC FREQ, producing frequency table for top 5 Fire Batallion
Type  in 2016 and 2017 .PROC FREQ is used so as to view the data in order.
;
proc freq
       data = Fire_Inspections_1617 noprint
   ;
   table
       Battalion / out = Count list
   ;

run;

*
The reason why to use sort command is to sort data count which is created above
and make the outcome looks more meaningful.By using decend count, the output
can be shown by highest to lowest.
;
proc sort
       data = Count
       out = Battalion_Count_Desc
   ;
   by
       descending count
   ;
run;



****************************DF data manipulation steps*************************;
*
The first research question asks about the top 5 Fire Inspections areas where
fire have been done in 2016.
The reason for question 2 is to prepare a output for testing whetehr the
combining table which is created by sql work or not. The second resarch question
is similar to the first question to show the top 5 fire inspections areas in 
2017.
Third question is to show the result and count the results happened both in 2016
and 2017. 
;

*
Step- By using PROC FREQ, producing frequency table for top 5 Fire Inspections
areas where fire have happened in 2016 .PROC FREQ is used so as to view the
areas in order.
;
proc freq
       data = Work.Fire_Inspections_2016_raw noprint
   ;
   table
       Fire_Prevention_District / out = Count list
   ;

run;

*
The reason why to use sort command is to sort data count which is created above
and make the outcome looks more meaningful.By using decend count, the output
can be shown by highest to lowest.
;
proc sort
       data = Count
       out = Count_Desc
   ;
   by
       descending Count
   ;
run;

*
Step- By using PROC FREQ, producing frequency table for top 5 Fire Inspections
areas where fire have happened in 2017 .PROC FREQ is used so as to view the
areas in order.
;
proc freq
       data = Work.Fire_Inspections_2017_raw noprint
   ;
   table
       Fire_Prevention_District / out = Count1 list
   ;

run;

*
The reason why to use sort command is to sort data count which is created above
and make the outcome looks more meaningful.By using decend count, the output
can be shown by highest to lowest.
;
proc sort
       data = Count1
       out = Count1_Desc
   ;
   by
       descending Count
   ;
run;

*
Step- By using PROC FREQ, producing frequency table for top 5 Fire Inspections
areas where fire have happened in both 2016 and 2017. Due to the final research
question, this output should be corresponding to the results to the first and
second questions. Therefore, the PROC FREQ statement invokes the procedure 
and optionally identifies the input data set
;
proc freq
       data = Fire_Inspections_1617 noprint
   ;
   table
       Fire_Prevention_District / out = Count2 list
   ;

run;

*
The reason why to use sort command is to sort data count which is created above
and make the outcome looks more meaningful.By using decend count, the output
can be shown by highest to lowest.
;
proc sort
       data = Count2
       out = Count2_Desc
   ;
   by
       descending Count
   ;
run;

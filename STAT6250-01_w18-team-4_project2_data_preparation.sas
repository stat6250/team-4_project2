*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Team Number] team-4

--

[Dataset 1 Name] Fire_Inspections_2016

[Dataset Description] Information on Fire Inspections performed at a given location by the Fire Department.

[Experimental Unit Description] Fire Inspections for the year 2016

[Number of Observations] 25,045 
                   
[Number of Features] 35

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Inspections/wb4c-6hwj 

[Data Dictionary] https://data.sfgov.org/api/views/wb4c-6hwj/files/eb85e2a6-5fc5-41bb-9ec1-844e5524f000?download=true&filename=FIR-0003_DataDictionary_fire-inspections.xlsx 

[Unique ID Schema] The column “Inspection Number” is the primary key or unique ID, which also serves as the foreign key in datasets- Fire_Violations_2016 and Fire_Violations_2017. 

--

[Dataset 2 Name] Fire_Inspections_2017

[Dataset Description] Information on Fire Inspections performed at a given location by the Fire Department.

[Experimental Unit Description] Fire Inspections for the year 2017

[Number of Observations] 24,208
                    
[Number of Features] 35

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Inspections/wb4c-6hwj 

[Data Dictionary] https://data.sfgov.org/api/views/wb4c-6hwj/files/eb85e2a6-5fc5-41bb-9ec1-844e5524f000?download=true&filename=FIR-0003_DataDictionary_fire-inspections.xlsx

[Unique ID Schema] The column “Inspection Number” is the primary key or unique ID, which also serves as the foreign key in datasets- Fire_Violations_2016 and Fire_Violations_2017.


--

[Dataset 3 Name] Fire_Violations_2016

[Dataset Description] Information on Fire Violations issued by the Fire Department at a given location.

[Experimental Unit Description] Fire Violations for the year 2016

[Number of Observations] 2,569
                    
[Number of Features] 19

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Violations/4zuq-2cbe 

[Data Dictionary] https://data.sfgov.org/api/views/4zuq-2cbe/files/a68685a7-41f8-432f-976d-aafb2711198e?download=true&filename=FIR-0006_DataDictionary_fire-violations.xlsx

[Unique ID Schema] The column “Violation ID” is the unique id.

--

[Dataset 4 Name] Fire_Violations_2017

[Dataset Description] Information on Fire Violations issued by the Fire Department at a given location.

[Experimental Unit Description] Fire Violations for the year 2017

[Number of Observations] 5,142
                    
[Number of Features] 19

[Data Source] https://data.sfgov.org/Housing-and-Buildings/Fire-Violations/4zuq-2cbe 

[Data Dictionary] https://data.sfgov.org/api/views/4zuq-2cbe/files/a68685a7-41f8-432f-976d-aafb2711198e?download=true&filename=FIR-0006_DataDictionary_fire-violations.xlsx

[Unique ID Schema] The column “Violation ID” is the unique id.

--

[Dataset 4 Name] sat15

[Dataset Description] SAT Test Results, AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 2,331

[Number of Features] 12

[Data Source]  The file http://www3.cde.ca.gov/researchfiles/satactap/sat15.xls
was downloaded and edited to produce file sat15-edited.xls by opening in Excel
and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sp/ai/reclayoutsat.asp

[Unique ID Schema] The column CDS is a unique id.
;


* environmental setup;

* create output formats;

proc format;
    value Percent_Eligible_FRPM_K12_bins
        low-<.39="Q1 FRPM"
        .39-<.69="Q2 FRPM"
        .69-<.86="Q3 FRPM"
        .86-high="Q4 FRPM"
    ;
    value PCTGE1500_bins
        low-20="Q1 SAT_Scores_GE_1500"
        20-<37="Q2 SAT_Scores_GE_1500"
        37-<56.3="Q3 SAT_Scores_GE_1500"
        56.3-high="Q4 SAT_Scores_GE_1500"
    ;
run;


* setup environmental parameters;
%let inputDataset1URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Inspections_2016.xlsx?raw=true
;
%let inputDataset1Type = XLS;
%let inputDataset1DSN = Fire_Inspections_2016_raw;

%let inputDataset2URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Inspections_2017.xlsx?raw=true
;
%let inputDataset2Type = XLS;
%let inputDataset2DSN = Fire_Inspections_2017_raw;

%let inputDataset3URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Violations_2016.xlsx?raw=true
;
%let inputDataset3Type = XLS;
%let inputDataset3DSN = Fire_Violations_2016_raw;

%let inputDataset4URL =
https://github.com/stat6250/team-4_project2/blob/master/data/Fire_Violations_2017.xlsx?raw=true
;
%let inputDataset4Type = XLS;
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
        out=Fire_Inspections_2016_raw_sorted(where=(not(missing(Inspection Number))))
    ;
    by
        Inspection Address Zipcode
        Inspection Number
    ;
run;
proc sort
        nodupkey
        data=Fire_Inspections_2017_raw
        dupout=Fire_Inspections_2017_raw_dups
        out=Fire_Inspections_2017_raw_sorted
    ;
    by
        Inspection Address Zipcode
        Inspection Number
    ;
run;
proc sort
        nodupkey
        data=Fire_Violations_2016_raw
        dupout=Fire_Violations_2016_raw_dups
        out=Fire_Violations_2016_raw_sorted
    ;
    by
        Violation Number
    ;
run;
proc sort
        nodupkey
        data=Fire_Violations_2017_raw
        dupout=Fire_Violations_2017_raw_dups
        out=Fire_Violations_2017_raw_sorted
    ;
    by
        Violation Number
    ;
run;



* combine  Fire_Inspections_2016 and Fire_Inspections_2017 vertically and combine 
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

* build analytic dataset from raw datasets with the least number of columns and
minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;

data SF_FireStats_1617_analytic_file;
    retain
        Inspection_Number
        Inspection_Type
        Inspection_Address_Zipcode
        Battalion
        Address
        Violation_Id
        Violation_Item
        Zipcode_of_Incident
    ;
    keep
        Inspection_Number
        Inspection_Type
        Inspection_Address_Zipcode
        Battalion
        Address
        Violation_Id
        Violation_Item
        Zipcode_of_Incident
    ;
    merge
        Fire_Inspections_1617
        Fire_Violations_1617
    ;
    by
	Inspection_Number
    ;
run;



%macro slc_submit_r64(                                                          
      pgmx                                                                      
     ,inp=NULL                                                                  
     ,out=NULL                                                                  
     ,resolve=NULL                                                              
     ,r2mac=NULL                                                                
     )/des="Semi colon separated set R commands - drop down to R";              
                                                                                
  %put 1111 inp=       &inp    ;                                                
  %put 1111 out=       &out    ;                                                
  %put 1111 r2mac=     &r2mac  ;                                                
  %put 1111 resolve=   &resolve;                                                
                                                                                
  %utlfkil(c:/temp/r_pgm.txt);                                                  
  %utlfkil(c:/temp/rcode.r);                                                    
                                                                                
  * clear clipboard ;                                                           
  filename _clp clipbrd;                                                        
  data _null_;                                                                  
    file _clp;                                                                  
    put " ";                                                                    
  run;quit;                                                                     
                                                                                
  ***********************************************************************;      
  * convert code string to a file and optionally resolve macro triggers *;      
  * add write to clipboard if requires                                  *;      
  ***********************************************************************;      
                                                                                
  data _null_;                                                                  
                                                                                
    length pgm $32756;                                                          
    file "c:/temp/r_pgm.txt" lrecl=32766 recfm=v;                               
                                                                                
    %if &resolve ^= NULL %then %do;                                             
        pgm=resolve(&pgmx);                                                     
        putlog pgm;                                                             
    %end;                                                                       
    %else %do;                                                                  
        pgm=&pgmx;                                                              
        putlog pgm;                                                             
    %end;                                                                       
                                                                                
  ***********************************************************************;      
  * conver backtic to single quote. Outside single quote is gone        *;      
  * add write to clipboard if asked for                                 *;      
  ***********************************************************************;      
                                                                                
    if index(pgm,"`") then pgm=tranwrd(pgm,"`","27"x);                          
                                                                                
    put pgm;                                                                    
    putlog pgm;                                                                 
                                                                                
  run;                                                                          
                                                                                
  ***********************************************************************;      
  * handle inputs and outputs and source the code file                  *;      
  ***********************************************************************;      
                                                                                
  data _null_;                                                                  
     file "c:/temp/rcode.r";                                                    
                                                                                
     put "proc r;";                                                             
     %if %qupcase(&inp) ^=NULL %then %do;                                       
        inp=resolve("&inp");                                                    
        put inp;                                                                
     %end;                                                                      
                                                                                
     put "  submit;";                                                           
     put "    source('c:/temp/r_pgm.txt',echo=TRUE)";                           
     put "  endsubmit;";                                                        
     %if %qupcase(&out) ^=NULL %then %do;                                       
        out=resolve("&out");                                                    
        put out;                                                                
     %end;                                                                      
     put "quit;";                                                               
     putlog "quit;";                                                            
   run;                                                                         
                                                                                
  ***********************************************************************;      
  * run r code with inputs and outputs                                  *;      
  ***********************************************************************;      
                                                                                
  %include "c:/temp/rcode.r";                                                   
                                                                                
  ***********************************************************************;      
  * write cliboard to macro variable r2mac                              *;      
  ***********************************************************************;      
                                                                                
  %if %upcase(&r2mac) ne NULL %then %do;                                        
    filename clp clipbrd ;                                                      
    data _null_;                                                                
     infile clp;                                                                
     input;                                                                     
     putlog "macro variable value = " _infile_;                                 
     call symputx("r2mac",_infile_,"G");                                        
    run;quit;                                                                   
   %end;                                                                        
                                                                                
%mend slc_submit_r64;                                                           
                                                                                
/*---- SETUP FOR EXAMPLES                                                       
                                                                                
* YOU NEED THIS DATA FOR ALL EXAMPLES;                                          
                                                                                
                                                                                
PROC SQL;                                                                       
CREATE TABLE class_sas (                                                        
    name CHAR(8),                                                               
    sex CHAR(1),                                                                
    age NUM,                                                                    
    height NUM,                                                                 
    weight NUM                                                                  
);                                                                              
QUIT;                                                                           
                                                                                
PROC SQL;                                                                       
INSERT INTO class_sas (name, sex, age, height, weight)                          
VALUES ('Alfred', 'M', 14, 69, 112.5)                                           
VALUES ('Alice', 'F', 13, 56.5, 84)                                             
VALUES ('Barbara', 'F', 13, 65.3, 98)                                           
VALUES ('Carol', 'F', 14, 62.8, 102.5)                                          
VALUES ('Henry', 'M', 14, 63.5, 102.5)                                          
VALUES ('James', 'M', 12, 57.3, 83)                                             
VALUES ('Jane', 'F', 12, 59.8, 84.5)                                            
VALUES ('Janet', 'F', 15, 62.5, 112.5)                                          
VALUES ('Jeffrey', 'M', 13, 62.5, 84)                                           
VALUES ('John', 'M', 12, 59, 99.5)                                              
VALUES ('Joyce', 'F', 11, 51.3, 50.5)                                           
VALUES ('Judy', 'F', 14, 64.3, 90)                                              
VALUES ('Louise', 'F', 12, 56.3, 77)                                            
VALUES ('Mary', 'F', 15, 66.5, 112)                                             
VALUES ('Philip', 'M', 16, 72, 150)                                             
VALUES ('Robert', 'M', 12, 64.8, 128)                                           
VALUES ('Ronald', 'M', 15, 67, 133)                                             
VALUES ('Thomas', 'M', 11, 57.5, 85)                                            
VALUES ('William', 'M', 15, 66.5, 112);                                         
QUIT;                                                                           
                                                                                
data workwpd.class_sas worksas.class_sas;                                       
  set class_sas;                                                                
run;                                                                            
                                                                                
                                                                                
1 SIMPLE 1 INPUT OUTPUT WITH MACRO VARIABLE FROM R                              
--------------------------------------------------                              
                                                                                
proc delete data=worksas.class_sas_males                                        
run;quit;                                                                       
                                                                                
%symdel r2mac / nowarn;                                                         
                                                                                
options set=RHOME "C:\Progra~1\R\R-4.5.2\bin\r";                                
                                                                                
%slc_submit_r64(                                                                
  '                                                                             
   library(sqldf);                                                              
    males<-sqldf(                                                               
     "                                                                          
      select                                                                    
         *                                                                      
      from                                                                      
         class_sas                                                              
      where                                                                     
         sex = `M`                                                              
     ");                                                                        
     print(males);                                                              
     writeClipboard(as.character(pi));                                          
  '                                                                             
   ,r2mac=Y                                                                     
   ,inp = %str(export data=worksas.class_sas r=class_sas;)                      
   ,out = %str(import data=worksas.class_sas_males r=males;)                    
   );                                                                           
                                                                                
proc print data=worksas.class_sas_males;                                        
run;quit;                                                                       
                                                                                
%put &=r2mac;                                                                   
                                                                                
In the log                                                                      
                                                                                
39        %put &=r2mac;                                                         
r2mac=3.14159265358979                                                          
                                                                                
      NAME SEX AGE HEIGHT WEIGHT                                                
1   Alfred   M  14   69.0  112.5                                                
2    Henry   M  14   63.5  102.5                                                
3    James   M  12   57.3   83.0                                                
4  Jeffrey   M  13   62.5   84.0                                                
5     John   M  12   59.0   99.5                                                
6   Philip   M  16   72.0  150.0                                                
7   Robert   M  12   64.8  128.0                                                
8   Ronald   M  15   67.0  133.0                                                
9   Thomas   M  11   57.5   85.0                                                
10 William   M  15   66.5  112.0                                                
                                                                                
                                                                                
2 SIMPLE 2 INPUT OUTPUT                                                         
-----------------------                                                         
                                                                                
proc delete data=worksas.class_sas_males workwpd.class_wpd_females              
run;quit;                                                                       
                                                                                
options set=RHOME "C:\Progra~1\R\R-4.5.2\bin\r";                                
%slc_submit_r64(                                                                
  '                                                                             
   library(sqldf);                                                              
   options(sqldf.dll = "d:/dll/sqlean.dll");                                    
    males<-sqldf(                                                               
     "                                                                          
      select                                                                    
         *                                                                      
      from                                                                      
         class_sas                                                              
      where                                                                     
         sex = `M`                                                              
     ");                                                                        
     print(males);                                                              
    females<-sqldf(                                                             
     "                                                                          
      select                                                                    
         *                                                                      
      from                                                                      
         class_wpd                                                              
      where                                                                     
         sex = `F`                                                              
     ");                                                                        
     print(females);                                                            
  '                                                                             
   ,inp   = %str(export data=worksas.class_sas r=class_sas;                     
                 export data=workwpd.class_wpd r=class_wpd;)                    
                                                                                
   ,out   = %str(import data=worksas.class_sas_males r=males;                   
                 import data=workwpd.class_wpd_females r=females;)              
   );                                                                           
                                                                                
proc print data=worksas.class_sas_males;                                        
title "input sas dataset output sas dataset";                                   
run;quit;                                                                       
                                                                                
proc print data=workwpd.class_wpd_females;                                      
title "input wpd dataset output wpd dataset";                                   
run;quit;                                                                       
                                                                                
      NAME SEX AGE HEIGHT WEIGHT       NAME SEX AGE HEIGHT WEIGHT               
1   Alfred   M  14   69.0  112.5  1   Alice   F  13   56.5   84.0               
2    Henry   M  14   63 .5  102.5  2 Barbara   F  13   65.3   98.0              
3    James   M  12   57.3   83.0  3   Carol   F  14   62.8  102.5               
4  Jeffrey   M  13   62.5   84.0  4    Jane   F  12   59.8   84.5               
5     John   M  12   59.0   99.5  5   Janet   F  15   62.5  112.5               
6   Philip   M  16   72.0  150.0  6   Joyce   F  11   51.3   50.5               
7   Robert   M  12   64.8  128.0  7    Judy   F  14   64.3   90.0               
8   Ronald   M  15   67.0  133.0  8  Louise   F  12   56.3   77.0               
9   Thomas   M  11   57.5   85.0  9    Mary   F  15   66.5  112.0               
10 William   M  15   66.5  112.0                                                
                                                                                
                                                                                
3 RUN R INSIDE SLC DATASETEP                                                    
----------------------------                                                    
                                                                                
* BEST;                                                                         
options noquotelenmax;                                                          
                                                                                
proc delete data=worksas.class_sas_m worksas.class_sas_f;                       
run;                                                                            
                                                                                
options set=RHOME "C:\Progra~1\R\R-4.5.2\bin\r";                                
                                                                                
data _null_;                                                                    
                                                                                
  do sex= "F", "M";                                                             
                                                                                
  call symputx('sex',sex);                                                      
                                                                                
  rc=dosubl(%tslit(                                                             
                                                                                
     %slc_submit_r64(                                                           
     '                                                                          
       library(sqldf);                                                          
                                                                                
       sex<-fn$sqldf(                                                           
         "                                                                      
          select                                                                
             *                                                                  
          from                                                                  
             class_sas                                                          
          where                                                                 
             sex = `&sex`                                                       
       ");                                                                      
      print(sex);                                                               
     '                                                                          
     ,resolve= Y                                                                
     ,inp    = %str(export data=worksas.class_sas r=class_sas;)                 
     ,out   =  %nrstr(import data=worksas.class_sas_&sex r=sex;)                
     );));                                                                      
                                                                                
  end;                                                                          
                                                                                
run;quit;                                                                       
                                                                                
                                                                                
proc print data=worksas.class_sas_M;                                            
title "worksas.class_sas_sex"                                                   
run;quit;                                                                       
                                                                                
proc print data=worksas.class_sas_F;                                            
title "worksas.class_sas_sex"                                                   
run;quit;                                                                       
                                                                                
                                                                                
4 CALL MACRO INSIDE R                                                           
---------------------                                                           
                                                                                
proc delete data=worksas.class_sas_m worksas.class_sas_f;                       
run;                                                                            
                                                                                
%array(sx,values=M F);                                                          
                                                                                
%put &=sx1; *--- SX1=M ---;                                                     
%put &=sx2; *--- SX2=F ---;                                                     
%put &=sxn; *--- SXN=2 ---;                                                     
                                                                                
%do_over(sx,phrase=%nrstr(                                                      
     %slc_submit_r64(                                                           
     '                                                                          
      library(sqldf);                                                           
      sex<-sqldf(                                                               
       "                                                                        
        select                                                                  
           *                                                                    
        from                                                                    
           class_sas                                                            
        where                                                                   
           sex = `?`                                                            
       ");                                                                      
      print(sex);                                                               
     '                                                                          
     ,resolve=Y                                                                 
     ,inp   = %str(export data=worksas.class_sas r=class_sas;)                  
     ,out   = %str(import data=worksas.class_sas_? r=sex;)                      
     );                                                                         
));                                                                             
                                                                                
                                                                                
proc print data=worksas.class_sas_M;                                            
title "worksas.class_sas_sex"                                                   
run;quit;                                                                       
                                                                                
proc print data=worksas.class_sas_F;                                            
title "worksas.class_sas_sex"                                                   
run;quit;                                                                       
                                                                                
---*/                                                                           
                                                                                
                                                                                

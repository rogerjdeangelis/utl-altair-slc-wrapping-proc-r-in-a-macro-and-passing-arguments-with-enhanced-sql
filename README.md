# utl-altair-slc-wrapping-proc-r-in-a-macro-and-passing-arguments-with-enhanced-sql
Altair slc wrapping proc r in a macro and passing arguments with enhanced sql
    %let pgm =utl-altair-slc-wrapping-proc-r-in-a-macro-and-passing-arguments-with-enhanced-sql;

    %stop_submission;

    Altair slc wrapping proc r in a macro and passing arguments with enhanced sql;

    Too long to post here, see github
    https://github.com/rogerjdeangelis/utl-altair-slc-wrapping-proc-r-in-a-macro-and-passing-arguments-with-enhanced-sql

    EXAMPLES (PROVIDES A VERY POWERFULL ENHANCED SQL)

      1 save utl_submit_r64 macro in your autocall library
      2 create input for all examples
      3 simple 1 input output with macro variable from r
      4 simple 2 input output
      5 run r inside slc datasetep
      6 call slc macro inside r

    PREP (ADD THESE LIBNAMES TO YOU AUTOEXEC)

      libname worksas sas7bdat "d:/worksas";
      libname workwpd wpd      "d:/workwpd";
      options noquotelenmax;
      d:/temp must exist
      download sqlean.dll (enhances sqlite)

    MACRO EXTENSIONS AND LIMITATIONS

     EXTENSIONS

      1 Can execute sas macros inside r
      2 Can return a macro named r2mac
      3 Can resolve macro variables inside r
      4 Supports mutiple input and output datasets
      5 R program supports three types of quotes backtick, single quote and double quote
      6 Suppots hundreds od sqlite extensions ( sqlean.dll )

     LIMITATIONS

      1 This solution creates files in c:/temp
      2 R program must be less than 32k
      3 May not support R functions and operators that use backticks,  mutiple single/double and embedded semi-colons
      4 Semicolon must be the line terminator, therefore other uses of a semicolon may not be supported.
      5 Do not use '#' comments (r source does not support ';' terminated r comments?.)

    This opens up advanced sql processing to programmers.

    What I learned from this work. I am begining to believe use of the quoting version
    of macro functions should be used freely, I don't see a downside. This would have
    saved me hours. The same with cards4 and ';;;;' instead or noe '4' versions.

    /*                                    _                  _ _
    / | ___  __ ___   _____    __ _ _   _| |_ ___   ___ __ _| | | _ __ ___   __ _  ___ _ __ ___
    | |/ __|/ _` \ \ / / _ \  / _` | | | | __/ _ \ / __/ _` | | || `_ ` _ \ / _` |/ __| `__/ _ \
    | |\__ \ (_| |\ V /  __/ | (_| | |_| | || (_) | (_| (_| | | || | | | | | (_| | (__| | | (_) |
    |_||___/\__,_| \_/ \___|  \__,_|\__,_|\__\___/ \___\__,_|_|_||_| |_| |_|\__,_|\___|_|  \___/

    */

    /*---  save macro in autoall library. Edit c:/wpsoto/slc_submit_r64.sas for your autocall library ---*/
    data _null_;
     file "c:/wpsoto/slc_submit_r64.sas";
     input;
     put _infile_;
    cards4;
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



    /*___                        _         _                   _
    |___ \    ___ _ __ ___  __ _| |_ ___  (_)_ __  _ __  _   _| |_
      __) |  / __| `__/ _ \/ _` | __/ _ \ | | `_ \| `_ \| | | | __|
     / __/  | (__| | |  __/ (_| | ||  __/ | | | | | |_) | |_| | |_
    |_____|  \___|_|  \___|\__,_|\__\___| |_|_| |_| .__/ \__,_|\__|
                                                  |_|
    */

    data worksas.class_sas;
       informat
         name $8.
         sex $1.
         age 8.
         height 8.
         weight 8.
    ;
    input
      name sex age height weight;
    cards4;
    Alfred M 14 69 112.5
    Alice F 13 56.5 84
    Barbara F 13 65.3 98
    Carol F 14 62.8 102.5
    Henry M 14 63.5 102.5
    James M 12 57.3 83
    Jane F 12 59.8 84.5
    Janet F 15 62.5 112.5
    Jeffrey M 13 62.5 84
    John M 12 59 99.5
    Joyce F 11 51.3 50.5
    Judy F 14 64.3 90
    Louise F 12 56.3 77
    Mary F 15 66.5 112
    Philip M 16 72 150
    Robert M 12 64.8 128
    Ronald M 15 67 133
    Thomas M 11 57.5 85
    William M 15 66.5 112
    ;;;;
    run;quit;

    data workwpd.class_wpd;
      set worksas.class;
    run;quit;

    proc contents data=worksas.class position;
    run;

    proc contents data=workwpd.class position;
    run;

    /**************************************************************************************************************************/
    /* class_wpd dataset d:/workwpd/class_wpd.wpd              |  class_sas d:/worksas/class_sas.sas7bdat                     */
    /* Altair SLC                                              |  Altair SLC                                                  */
    /*                                                         |                                                              */
    /* The CONTENTS Procedure                                  |  The CONTENTS Procedure                                      */
    /*                                                         |                                                              */
    /* Data Set Name           CLASS_WPD                       |  Data Set Name           CLASS_SAS                           */
    /* Member Type             DATA                            |  Member Type             DATA                                */
    /* Engine                  WPD                             |  Engine                  SAS7BDAT                            */
    /* Created                 02FEB2026:12:37:25              |  Created                 02FEB2026:12:37:25                  */
    /* Last Modified           02FEB2026:12:37:25              |  Last Modified           02FEB2026:12:37:25                  */
    /* Observations                    19                      |  Observations                    19                          */
    /* Variables               5                               |  Variables               5                                   */
    /* Indexes                 0                               |  Indexes                 0                                   */
    /* Observation Length      33                              |  Observation Length      40                                  */
    /* Deleted Observations             0                      |  Deleted Observations             0                          */
    /* Data Set Type                                           |  Data Set Type                                               */
    /* Label                                                   |  Label                                                       */
    /* Compressed              NO                              |  Compressed              NO                                  */
    /* Sorted                  NO                              |  Sorted                  NO                                  */
    /* Data Representation     Little endian, IEEE Windows     |  Data Representation     WINDOWS_64                          */
    /* Encoding                wlatin1 Windows-1252 Western    |  Encoding                wlatin1 Windows-1252 Western        */
    /*                                                         |                                                              */
    /*        Engine/Host Dependent Information                |            Engine/Host Dependent Information                 */
    /*                                                         |                                                              */
    /* Data Set Page Size          4096                        |  Data Set Page Size          4096                            */
    /* Number of Data Set Pages    2                           |  Number of Data Set Pages    1                               */
    /* First Data Page             1                           |  First Data Page             1                               */
    /* Max Obs Per Page            123                         |  Max Obs Per Page            101                             */
    /* Obs In First Data Page      19                          |  Obs In First Data Page      19                              */
    /* Data Set Diagnostic Code    0013                        |  File Name                   d:\worksas\class.sas7bdat       */
    /* File Name                   d:\workwpd\CLASS.wpd        |  Release Created             9.0101M3                        */
    /* WPD Engine Version          3                           |  Host Created                XP_PRO                          */
    /* Large Data Set Support      no                          |                                                              */
    /* Encrypted                   no                          |                                                              */
    /*                                                         |                                                              */
    /*   List of Variables and Attributes in Creation Order    |  List of Variables and Attributes in Creation Order          */
    /*                                                         |                                                              */
    /*  Number    Variable    Type   Len     Pos    Informat   |  Number    Variable    Type   Len     Pos    Informat        */
    /* _____________________________________________________   |  ____________________________________________________        */
    /*       1    NAME        Char     8      24    $8.        |       1    NAME        Char     8      24    $8.             */
    /*       2    SEX         Char     1      32    $1.        |       2    SEX         Char     1      32    $1.             */
    /*       3    AGE         Num      8       0    8.         |       3    AGE         Num      8       0    8.              */
    /*       4    HEIGHT      Num      8       8    8.         |       4    HEIGHT      Num      8       8    8.              */
    /*       5    WEIGHT      Num      8      16    8.         |       5    WEIGHT      Num      8      16    8.              */
    /*                                                         |                                                              */
    /*  CLASS_WPD total obs=19                                 | CLASS_SAS total obs=19                                       */
    /*  Obs    NAME       SEX    AGE    HEIGHT    WEIGHT       | Obs    NAME       SEX    AGE    HEIGHT    WEIGHT             */
    /*                                                         |                                                              */
    /*    1    Alfred      M      14     69.0      112.5       |   1    Alfred      M      14     69.0      112.5             */
    /*    2    Alice       F      13     56.5       84.0       |   2    Alice       F      13     56.5       84.0             */
    /*    3    Barbara     F      13     65.3       98.0       |   3    Barbara     F      13     65.3       98.0             */
    /*   ...                                                   |  ...                                                         */
    /*   17    Ronald      M      15     67.0      133.0       |  17    Ronald      M      15     67.0      133.0             */
    /*   18    Thomas      M      11     57.5       85.0       |  18    Thomas      M      11     57.5       85.0             */
    /*   19    William     M      15     66.5      112.0       |  19    William     M      15     66.5      112.0             */
    /*                                                         |                                                              */
    /**************************************************************************************************************************/

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC    09:11 Wednesday, February  4, 2026

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿ods _all_ close;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx

    NOTE: Library slchelp assigned as follows:
          Engine:        WPD
          Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp

    NOTE: Library worksas assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\worksas

    NOTE: Library workwpd assigned as follows:
          Engine:        WPD
          Physical Name: d:\workwpd


    LOG:  9:11:37
    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.023
          cpu time  : 0.000


    NOTE: AUTOEXEC processing completed

    1         data worksas.class_sas;
    2            informat
    3              name $8.
    4              sex $1.
    5              age 8.
    6              height 8.
    7              weight 8.
    8         ;
    9         input
    10          name sex age height weight;
    11        cards4;

    NOTE: Data set "WORKSAS.class_sas" has 19 observation(s) and 5 variable(s)
    NOTE: The data step took :
          real time : 0.008
          cpu time  : 0.015


    12        Alfred M 14 69 112.5
    13        Alice F 13 56.5 84
    14        Barbara F 13 65.3 98
    15        Carol F 14 62.8 102.5
    16        Henry M 14 63.5 102.5
    17        James M 12 57.3 83
    18        Jane F 12 59.8 84.5
    19        Janet F 15 62.5 112.5

    2                                                                                                                         Altair SLC

    20        Jeffrey M 13 62.5 84
    21        John M 12 59 99.5
    22        Joyce F 11 51.3 50.5
    23        Judy F 14 64.3 90
    24        Louise F 12 56.3 77
    25        Mary F 15 66.5 112
    26        Philip M 16 72 150
    27        Robert M 12 64.8 128
    28        Ronald M 15 67 133
    29        Thomas M 11 57.5 85
    30        William M 15 66.5 112
    31        ;;;;
    32        run;quit;
    33
    34        data workwpd.class_wpd;
    35          set worksas.class;
    36        run;

    NOTE: 19 observations were read from "WORKSAS.class"
    NOTE: Data set "WORKWPD.class_wpd" has 19 observation(s) and 5 variable(s)
    NOTE: The data step took :
          real time : 0.023
          cpu time  : 0.000


    36      !     quit;
    37
    38        proc contents data=worksas.class position;
    39        run;
    NOTE: Procedure contents step took :
          real time : 0.041
          cpu time  : 0.015


    40
    41        proc contents data=workwpd.class position;
    42        run;
    NOTE: Procedure contents step took :
          real time : 0.046
          cpu time  : 0.000


    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 0.187
          cpu time  : 0.093

    /*____      _                 _        _   _                   _                _               _
    |___ /  ___(_)_ __ ___  _ __ | | ___  / | (_)_ __  _ __  _   _| |_   ___  _   _| |_ _ __  _   _| |_
      |_ \ / __| | `_ ` _ \| `_ \| |/ _ \ | | | | `_ \| `_ \| | | | __| / _ \| | | | __| `_ \| | | | __|
     ___) |\__ \ | | | | | | |_) | |  __/ | | | | | | | |_) | |_| | |_ | (_) | |_| | |_| |_) | |_| | |_
    |____/ |___/_|_| |_| |_| .__/|_|\___| |_| |_|_| |_| .__/ \__,_|\__| \___/ \__,_|\__| .__/ \__,_|\__|
                           |_|                        |_|                              |_|
    */

    /*---------------------------------*/
    /*--- sas7bdat in add out      ----*/
    /*---------------------------------*/

    %*utlopts;
    proc delete data=worksas.class_sas_males
    run;quit;

    %symdel r2mac / nowarn;

    %inc "c:/wpsoto/slc_submit_r64.sas";

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
      '
       ,inp   = %str(export data=worksas.class_sas r=class_sas;)
       ,out   = %str(import data=worksas.class_sas_males r=males;)
       ,r2mac=%str(writeClipboard(as.character(pi));)
       );

    proc print data=worksas.class_sas_males;
    run;quit;

    %put &=r2mac;

    /*           _               _
      ___  _   _| |_ _ __  _   _| |_
     / _ \| | | | __| `_ \| | | | __|
    | (_) | |_| | |_| |_) | |_| | |_
     \___/ \__,_|\__| .__/ \__,_|\__|
                    |_|
    */

    /*************************************************************************************************************************/
    /*                                  |                                                                                     */
    /* FROM R dataframe Males           |  d:/worksas/class_males.sas7bdat                                                    */
    /*                                  |                                                                                     */
    /* Altair SLC                       |  Altair SLC                                                                         */
    /*                                  |                                                                                     */
    /*       NAME SEX AGE HEIGHT WEIGHT |  Obs     NAME      SEX    AGE    HEIGHT    WEIGHT                                   */
    /* 1   Alfred   M  14   69.0  112.5 |    1    Alfred      M      14     69.0      112.5                                   */
    /* 2    Henry   M  14   63.5  102.5 |    2    Henry       M      14     63.5      102.5                                   */
    /* 3    James   M  12   57.3   83.0 |    3    James       M      12     57.3       83.0                                   */
    /* 4  Jeffrey   M  13   62.5   84.0 |    4    Jeffrey     M      13     62.5       84.0                                   */
    /* 5     John   M  12   59.0   99.5 |    5    John        M      12     59.0       99.5                                   */
    /* 6   Philip   M  16   72.0  150.0 |    6    Philip      M      16     72.0      150.0                                   */
    /* 7   Robert   M  12   64.8  128.0 |    7    Robert      M      12     64.8      128.0                                   */
    /* 8   Ronald   M  15   67.0  133.0 |    8    Ronald      M      15     67.0      133.0                                   */
    /* 9   Thomas   M  11   57.5   85.0 |    9    Thomas      M      11     57.5       85.0                                   */
    /* 10 William   M  15   66.5  112.0 |   10    William     M      15     66.5      112.0                                   */
    /*------------------------------------------------------------------------------------------------------------------------*/
    /* Macro variable from R                                                                                                  */
    /*                                                                                                                        */
    /* 98        %put &=r2mac;                                                                                                */
    /*                                                                                                                        */
    /* SYMBOLGEN: Macro variable r2mac resolved to 3.14159265358979                                                           */
    /*                                                                                                                        */
    /* r2mac=3.14159265358979                                                                                                 */
    /**************************************************************************************************************************/

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */
    1                                          Altair SLC     12:03 Thursday, February  5, 2026

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿ods _all_ close;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx

    NOTE: Library slchelp assigned as follows:
          Engine:        WPD
          Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp

    NOTE: Library worksas assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\worksas

    NOTE: Library workwpd assigned as follows:
          Engine:        WPD
          Physical Name: d:\workwpd


    LOG:  12:03:33
    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.031
          cpu time  : 0.015


    NOTE: AUTOEXEC processing completed

    1         dproc delete data=worksas.class_sas_males
              ^
    ERROR: Expected a statement keyword : found "dproc"
    2         run;quit;
    3
    4         %symdel r2mac / nowarn;
    5
    6         %inc "c:/wpsoto/slc_submit_r64.sas";
    Start of %INCLUDE(level 1) c:/wpsoto/slc_submit_r64.sas
    7       +  %macro slc_submit_r64(
    8       +        pgmx
    9       +       ,inp=NULL
    10      +       ,out=NULL
    11      +       ,resolve=NULL
    12      +       ,r2mac=NULL
    13      +       )/des="Semi colon separated set R commands - drop down to R";
    14      +    %put 1111 inp=       &inp    ;
    15      +    %put 1111 out=       &out    ;
    16      +    %put 1111 r2mac=     &r2mac  ;
    17      +    %put 1111 resolve=   &resolve;
    18      +    %utlfkil(c:/temp/r_pgm.txt);
    19      +    %utlfkil(c:/temp/rcode.r);
    20      +    * clear clipboard ;
    21      +    filename _clp clipbrd;
    22      +    data _null_;
    23      +      file _clp;

    2                                                                                                                         Altair SLC

    24      +      put " ";
    25      +    run;quit;
    26      +    ***********************************************************************;
    27      +    * convert code string to a file and optionally resolve macro triggers *;
    28      +    * add write to clipboard if requires                                  *;
    29      +    ***********************************************************************;
    30      +    data _null_;
    31      +      length pgm $32756;
    32      +      file "c:/temp/r_pgm.txt" lrecl=32766 recfm=v;
    33      +      %if &resolve ^= NULL %then %do;
    34      +          pgm=resolve(&pgmx);
    35      +          putlog pgm;
    36      +      %end;
    37      +      %else %do;
    38      +          pgm=&pgmx;
    39      +          putlog pgm;
    40      +      %end;
    41      +    ***********************************************************************;
    42      +    * conver backtic to single quote. Outside single quote is gone        *;
    43      +    * add write to clipboard if asked for                                 *;
    44      +    ***********************************************************************;
    45      +      if index(pgm,"`") then pgm=tranwrd(pgm,"`","27"x);
    46      +      put pgm;
    47      +      putlog pgm;
    48      +    run;
    49      +    ***********************************************************************;
    50      +    * handle inputs and outputs and source the code file                  *;
    51      +    ***********************************************************************;
    52      +    data _null_;
    53      +       file "c:/temp/rcode.r";
    54      +       put "proc r;";
    55      +       %if %qupcase(&inp) ^=NULL %then %do;
    56      +          inp=resolve("&inp");
    57      +          put inp;
    58      +       %end;
    59      +       put "  submit;";
    60      +       put "    source('c:/temp/r_pgm.txt',echo=TRUE)";
    61      +       put "  endsubmit;";
    62      +       %if %qupcase(&out) ^=NULL %then %do;
    63      +          out=resolve("&out");
    64      +          put out;
    65      +       %end;
    66      +       put "quit;";
    67      +       putlog "quit;";
    68      +     run;
    69      +    ***********************************************************************;
    70      +    * run r code with inputs and outputs                                  *;
    71      +    ***********************************************************************;
    72      +    %include "c:/temp/rcode.r";
    73      +    ***********************************************************************;
    74      +    * write cliboard to macro variable r2mac                              *;
    75      +    ***********************************************************************;
    76      +    %if %upcase(&r2mac) ne NULL %then %do;
    77      +      filename clp clipbrd ;
    78      +      data _null_;
    79      +       infile clp;
    80      +       input;
    81      +       putlog "macro variable value = " _infile_;
    82      +       call symputx("r2mac",_infile_,"G");
    83      +      run;quit;
    84      +     %end;
    85      +  %mend slc_submit_r64;
    End of %INCLUDE(level 1) c:/wpsoto/slc_submit_r64.sas

    3                                                                                                                         Altair SLC

    86
    87        options set=RHOME "C:\Progra~1\R\R-4.5.2\bin\r";
    88        %slc_submit_r64(
    1111 inp=       export data=worksas.class_sas r=class_sas;
    1111 out=       import data=worksas.class_sas_males r=males;
    1111 r2mac=     writeClipboard(as.character(pi));
    1111 resolve=   NULL
    89          '
    90           library(sqldf);
    91            males<-sqldf(
    92             "
    93              select
    94                 *
    95              from
    96                 class_sas
    97              where
    98                 sex = `M`
    99             ");
    100            print(males);
    101         '
    102          ,inp   = %str(export data=worksas.class_sas r=class_sas;)
    103          ,out   = %str(import data=worksas.class_sas_males r=males;)
    104          ,r2mac=%str(writeClipboard(as.character(pi));)
    105          );

    NOTE: The file _clp is:
          Clipboard

    NOTE: 1 record was written to file _clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000



    NOTE: The file 'c:\temp\r_pgm.txt' is:
          Filename='c:\temp\r_pgm.txt',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:03:32 Feb 05 2026,
          Last Modified=12:03:32 Feb 05 2026,
          Lrecl=32766, Recfm=V

    library(sqldf);    males<-sqldf(     "      select         *      from         class_sas      where         sex = `M`     ");     print(males);
    library(sqldf);    males<-sqldf(     "      select         *      from         class_sas      where         sex = 'M'     ");     print(males);
    NOTE: 1 record was written to file 'c:\temp\r_pgm.txt'
          The minimum record length was 143
          The maximum record length was 143
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000



    NOTE: The file 'c:\temp\rcode.r' is:
          Filename='c:\temp\rcode.r',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:03:32 Feb 05 2026,

    4                                                                                                                         Altair SLC

          Last Modified=12:03:32 Feb 05 2026,
          Lrecl=32767, Recfm=V

    quit;
    NOTE: 7 records were written to file 'c:\temp\rcode.r'
          The minimum record length was 5
          The maximum record length was 44
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    Start of %INCLUDE(level 1) c:/temp/rcode.r
    106     +  proc r;
    NOTE: Using R version 4.5.2 (2025-10-31 ucrt) from C:\Program Files\R\R-4.5.2
    107     +  export data=worksas.class_sas r=class_sas;
    NOTE: Creating R data frame 'class_sas' from data set 'WORKSAS.class_sas'

    108     +    submit;
    109     +      source('c:/temp/r_pgm.txt',echo=TRUE)
    110     +    endsubmit;

    NOTE: Submitting statements to R:

    >     source('c:/temp/r_pgm.txt',echo=TRUE)
    > library(sqldf)
    Loading required package: gsubfn
    Loading required package: proto
    Loading required package: RSQLite
    > males <- sqldf("      select         *      from         class_sas      where         sex = 'M'     ")
    > print(males)

    NOTE: Processing of R statements complete

    111     +  import data=worksas.class_sas_males r=males;
    NOTE: Creating data set 'WORKSAS.class_sas_males' from R data frame 'males'
    NOTE: Data set "WORKSAS.class_sas_males" has 10 observation(s) and 5 variable(s)

    112     +  quit;
    NOTE: Procedure r step took :
          real time : 1.407
          cpu time  : 0.046


    End of %INCLUDE(level 1) c:/temp/rcode.r

    NOTE: The infile clp is:
          Clipboard

    macro variable value =
    NOTE: 1 record was read from file clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    113
    114       proc print data=worksas.class_sas_males;
    115       run;quit;
    NOTE: 10 observations were read from "WORKSAS.class_sas_males"
    NOTE: Procedure print step took :

    5                                                                                                                         Altair SLC

          real time : 0.000
          cpu time  : 0.000


    116
    117       %put &=r2mac;
    r2mac=
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 1.550
          cpu time  : 0.140


    /*  _        _                 _        ____    _                   _                _               _
    | || |   ___(_)_ __ ___  _ __ | | ___  |___ \  (_)_ __  _ __  _   _| |_   ___  _   _| |_ _ __  _   _| |_
    | || |_ / __| | `_ ` _ \| `_ \| |/ _ \   __) | | | `_ \| `_ \| | | | __| / _ \| | | | __| `_ \| | | | __|
    |__   _|\__ \ | | | | | | |_) | |  __/  / __/  | | | | | |_) | |_| | |_ | (_) | |_| | |_| |_) | |_| | |_
       |_|  |___/_|_| |_| |_| .__/|_|\___| |_____| |_|_| |_| .__/ \__,_|\__| \___/ \__,_|\__| .__/ \__,_|\__|
                            |_|                            |_|                              |_|
    */

    proc delete data=worksas.class_sas_males
    run;quit;

    proc delete data=workwpd.class_wpd_females
    run;quit;

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

    /**************************************************************************************************************************/
    /* Altair SLC                         |                                                                                   */
    /*                                    |                                                                                   */
    /* SAS DATASETS IN AND OUT            |                                                                                   */
    /*                                    |    INPUT SAS DATASET OUTPUT SAS DATASET                                           */
    /*       NAME SEX AGE HEIGHT WEIGHT   |    Obs     NAME      SEX    AGE    HEIGHT    WEIGHT                               */
    /* 1   Alfred   M  14   69.0  112.5   |      1    Alfred      M      14     69.0      112.5                               */
    /* 2    Henry   M  14   63.5  102.5   |      2    Henry       M      14     63.5      102.5                               */
    /* 3    James   M  12   57.3   83.0   |      3    James       M      12     57.3       83.0                               */
    /* 4  Jeffrey   M  13   62.5   84.0   |      4    Jeffrey     M      13     62.5       84.0                               */
    /* 5     John   M  12   59.0   99.5   |      5    John        M      12     59.0       99.5                               */
    /* 6   Philip   M  16   72.0  150.0   |      6    Philip      M      16     72.0      150.0                               */
    /* 7   Robert   M  12   64.8  128.0   |      7    Robert      M      12     64.8      128.0                               */
    /* 8   Ronald   M  15   67.0  133.0   |      8    Ronald      M      15     67.0      133.0                               */
    /* 9   Thomas   M  11   57.5   85.0   |      9    Thomas      M      11     57.5       85.0                               */
    /* 10 William   M  15   66.5  112.0   |     10    William     M      15     66.5      112.0                               */
    /*                                    |                                                                                   */
    /* WPD DATASETS IN AND OUT            |                                                                                   */
    /*                                    |    INPUT WPD DATASET OUTPUT WPD DATASET                                           */
    /*      NAME SEX AGE HEIGHT WEIGHT    |    Obs     NAME      SEX    AGE    HEIGHT    WEIGHT                               */
    /* 1   Alice   F  13   56.5   84.0    |      1    Alice       F      13     56.5       84.0                               */
    /* 2 Barbara   F  13   65.3   98.0    |      2    Barbara     F      13     65.3       98.0                               */
    /* 3   Carol   F  14   62.8  102.5    |      3    Carol       F      14     62.8      102.5                               */
    /* 4    Jane   F  12   59.8   84.5    |      4    Jane        F      12     59.8       84.5                               */
    /* 5   Janet   F  15   62.5  112.5    |      5    Janet       F      15     62.5      112.5                               */
    /* 6   Joyce   F  11   51.3   50.5    |      6    Joyce       F      11     51.3       50.5                               */
    /* 7    Judy   F  14   64.3   90.0    |      7    Judy        F      14     64.3       90.0                               */
    /* 8  Louise   F  12   56.3   77.0    |      8    Louise      F      12     56.3       77.0                               */
    /* 9    Mary   F  15   66.5  112.0    |      9    Mary        F      15     66.5      112.0                               */
    /**************************************************************************************************************************/

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC     12:06 Thursday, February  5, 2026

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿ods _all_ close;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx

    NOTE: Library slchelp assigned as follows:
          Engine:        WPD
          Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp

    NOTE: Library worksas assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\worksas

    NOTE: Library workwpd assigned as follows:
          Engine:        WPD
          Physical Name: d:\workwpd


    LOG:  12:06:05
    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.015
          cpu time  : 0.000


    NOTE: AUTOEXEC processing completed

    1         proc delete data=worksas.class_sas_males
    2         run;quit;
    NOTE: WORK.RUN (memtype="DATA") was not found, and has not been deleted
    NOTE: Deleting "WORKSAS.CLASS_SAS_MALES" (memtype="DATA")
    NOTE: Procedure delete step took :
          real time : 0.000
          cpu time  : 0.000


    3
    4         proc delete data=workwpd.class_wpd_females
    5         run;quit;
    NOTE: WORK.RUN (memtype="DATA") was not found, and has not been deleted
    NOTE: Deleting "WORKWPD.CLASS_WPD_FEMALES" (memtype="DATA")
    NOTE: Procedure delete step took :
          real time : 0.000
          cpu time  : 0.000


    6
    7         options set=RHOME "C:\Progra~1\R\R-4.5.2\bin\r";
    8         %slc_submit_r64(
    1111 inp=       export data=worksas.class_sas r=class_sas;                  export data=workwpd.class_wpd r=class_wpd;
    1111 out=       import data=worksas.class_sas_males r=males;                  import data=workwpd.class_wpd_females r=females;
    1111 r2mac=     NULL
    1111 resolve=   NULL

    2                                                                                                                         Altair SLC

    9           '
    10           library(sqldf);
    11            males<-sqldf(
    12             "
    13              select
    14                 *
    15              from
    16                 class_sas
    17              where
    18                 sex = `M`
    19             ");
    20             print(males);
    21            females<-sqldf(
    22             "
    23              select
    24                 *
    25              from
    26                 class_wpd
    27              where
    28                 sex = `F`
    29             ");
    30             print(females);
    31          '
    32           ,inp   = %str(export data=worksas.class_sas r=class_sas;
    33                         export data=workwpd.class_wpd r=class_wpd;)
    34
    35           ,out   = %str(import data=worksas.class_sas_males r=males;
    36                         import data=workwpd.class_wpd_females r=females;)
    37           );

    NOTE: The file _clp is:
          Clipboard

    NOTE: 1 record was written to file _clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000



    NOTE: The file 'c:\temp\r_pgm.txt' is:
          Filename='c:\temp\r_pgm.txt',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:06:04 Feb 05 2026,
          Last Modified=12:06:04 Feb 05 2026,
          Lrecl=32766, Recfm=V

    library(sqldf);    males<-sqldf(     "      select         *      from         class_sas      where         sex = `M`     ");     print(males);    females<-sqldf(     "      select         *      from         class_wpd      where         sex = `F`
         print(females);
    library(sqldf);    males<-sqldf(     "      select         *      from         class_sas      where         sex = 'M'     ");     print(males);    females<-sqldf(     "      select         *      from         class_wpd      where         sex = 'F'
         print(females);
    NOTE: 1 record was written to file 'c:\temp\r_pgm.txt'
          The minimum record length was 275
          The maximum record length was 275
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.015



    3                                                                                                                         Altair SLC


    NOTE: The file 'c:\temp\rcode.r' is:
          Filename='c:\temp\rcode.r',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:06:04 Feb 05 2026,
          Last Modified=12:06:04 Feb 05 2026,
          Lrecl=32767, Recfm=V

    quit;
    NOTE: 7 records were written to file 'c:\temp\rcode.r'
          The minimum record length was 5
          The maximum record length was 110
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    Start of %INCLUDE(level 1) c:/temp/rcode.r
    38      +  proc r;
    NOTE: Using R version 4.5.2 (2025-10-31 ucrt) from C:\Program Files\R\R-4.5.2
    39      +  export data=worksas.class_sas r=class_sas;                  export data=workwpd.class_wpd r=class_wpd;
    NOTE: Creating R data frame 'class_sas' from data set 'WORKSAS.class_sas'

    NOTE: Creating R data frame 'class_wpd' from data set 'WORKWPD.class_wpd'

    40      +    submit;
    41      +      source('c:/temp/r_pgm.txt',echo=TRUE)
    42      +    endsubmit;

    NOTE: Submitting statements to R:

    >     source('c:/temp/r_pgm.txt',echo=TRUE)
    > library(sqldf)
    Loading required package: gsubfn
    Loading required package: proto
    Loading required package: RSQLite
    > males <- sqldf("      select         *      from         class_sas      where         sex = 'M'     ")
    > print(males)
    > females <- sqldf("      select         *      from         class_wpd      where         sex = 'F'     ")
    > print(females)

    NOTE: Processing of R statements complete

    43      +  import data=worksas.class_sas_males r=males;                  import data=workwpd.class_wpd_females r=females;
    NOTE: Creating data set 'WORKSAS.class_sas_males' from R data frame 'males'
    NOTE: Data set "WORKSAS.class_sas_males" has 10 observation(s) and 5 variable(s)

    NOTE: Creating data set 'WORKWPD.class_wpd_females' from R data frame 'females'
    NOTE: Data set "WORKWPD.class_wpd_females" has 9 observation(s) and 5 variable(s)

    44      +  quit;
    NOTE: Procedure r step took :
          real time : 1.554
          cpu time  : 0.046


    End of %INCLUDE(level 1) c:/temp/rcode.r
    45
    46        proc print data=worksas.class_sas_males;
    47        title "input sas dataset output sas dataset";
    48        run;quit;

    4                                                                                                                         Altair SLC

    NOTE: 10 observations were read from "WORKSAS.class_sas_males"
    NOTE: Procedure print step took :
          real time : 0.015
          cpu time  : 0.015


    49
    50        proc print data=workwpd.class_wpd_females;
    51        title "input wpd dataset output wpd dataset";
    52        run;quit;
    NOTE: 9 observations were read from "WORKWPD.class_wpd_females"
    NOTE: Procedure print step took :
          real time : 0.000
          cpu time  : 0.000


    53
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 1.696
          cpu time  : 0.140


    /*___                             _           _     _           _       _                 _
    | ___|  _ __ _   _ _ __    _ __  (_)_ __  ___(_) __| | ___   __| | __ _| |_ __ _ ___  ___| |_ ___ _ __
    |___ \ | `__| | | | `_ \  | `__| | | `_ \/ __| |/ _` |/ _ \ / _` |/ _` | __/ _` / __|/ _ \ __/ _ \ `_ \
     ___) || |  | |_| | | | | | |    | | | | \__ \ | (_| |  __/| (_| | (_| | || (_| \__ \  __/ ||  __/ |_) |
    |____/ |_|   \__,_|_| |_| |_|    |_|_| |_|___/_|\__,_|\___| \__,_|\__,_|\__\__,_|___/\___|\__\___| .__/
                                                                                              |_|
    */

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


    /**************************************************************************************************************************/
    /* Altair SLC                         |                                                                                   */
    /*                                    |                                                                                   */
    /* SAS DATASETS IN AND OUT            |                                                                                   */
    /*                                    |    INPUT SAS DATASET OUTPUT SAS DATASET                                           */
    /*       NAME SEX AGE HEIGHT WEIGHT   |    Obs     NAME      SEX    AGE    HEIGHT    WEIGHT                               */
    /* 1   Alfred   M  14   69.0  112.5   |      1    Alfred      M      14     69.0      112.5                               */
    /* 2    Henry   M  14   63.5  102.5   |      2    Henry       M      14     63.5      102.5                               */
    /* 3    James   M  12   57.3   83.0   |      3    James       M      12     57.3       83.0                               */
    /* 4  Jeffrey   M  13   62.5   84.0   |      4    Jeffrey     M      13     62.5       84.0                               */
    /* 5     John   M  12   59.0   99.5   |      5    John        M      12     59.0       99.5                               */
    /* 6   Philip   M  16   72.0  150.0   |      6    Philip      M      16     72.0      150.0                               */
    /* 7   Robert   M  12   64.8  128.0   |      7    Robert      M      12     64.8      128.0                               */
    /* 8   Ronald   M  15   67.0  133.0   |      8    Ronald      M      15     67.0      133.0                               */
    /* 9   Thomas   M  11   57.5   85.0   |      9    Thomas      M      11     57.5       85.0                               */
    /* 10 William   M  15   66.5  112.0   |     10    William     M      15     66.5      112.0                               */
    /*                                    |                                                                                   */
    /* WPD DATASETS IN AND OUT            |                                                                                   */
    /*                                    |    INPUT WPD DATASET OUTPUT WPD DATASET                                           */
    /*      NAME SEX AGE HEIGHT WEIGHT    |    Obs     NAME      SEX    AGE    HEIGHT    WEIGHT                               */
    /* 1   Alice   F  13   56.5   84.0    |      1    Alice       F      13     56.5       84.0                               */
    /* 2 Barbara   F  13   65.3   98.0    |      2    Barbara     F      13     65.3       98.0                               */
    /* 3   Carol   F  14   62.8  102.5    |      3    Carol       F      14     62.8      102.5                               */
    /* 4    Jane   F  12   59.8   84.5    |      4    Jane        F      12     59.8       84.5                               */
    /* 5   Janet   F  15   62.5  112.5    |      5    Janet       F      15     62.5      112.5                               */
    /* 6   Joyce   F  11   51.3   50.5    |      6    Joyce       F      11     51.3       50.5                               */
    /* 7    Judy   F  14   64.3   90.0    |      7    Judy        F      14     64.3       90.0                               */
    /* 8  Louise   F  12   56.3   77.0    |      8    Louise      F      12     56.3       77.0                               */
    /* 9    Mary   F  15   66.5  112.0    |      9    Mary        F      15     66.5      112.0                               */
    /**************************************************************************************************************************/

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC     12:07 Thursday, February  5, 2026

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿ods _all_ close;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx

    NOTE: Library slchelp assigned as follows:
          Engine:        WPD
          Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp

    NOTE: Library worksas assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\worksas

    NOTE: Library workwpd assigned as follows:
          Engine:        WPD
          Physical Name: d:\workwpd


    LOG:  12:07:06
    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.031
          cpu time  : 0.015


    NOTE: AUTOEXEC processing completed

    1         options noquotelenmax;
    2
    3         proc delete data=worksas.class_sas_m worksas.class_sas_f;
    4         run;
    NOTE: Deleting "WORKSAS.CLASS_SAS_M" (memtype="DATA")
    NOTE: Deleting "WORKSAS.CLASS_SAS_F" (memtype="DATA")
    NOTE: Procedure delete step took :
          real time : 0.000
          cpu time  : 0.000


    5
    6         options set=RHOME "C:\Progra~1\R\R-4.5.2\bin\r";
    7
    8         data _null_;
    9
    10          do sex= "F", "M";
    11
    12          call symputx('sex',sex);
    13
    14          rc=dosubl(%tslit(
    15
    16             %slc_submit_r64(
    1111 inp=       export data=worksas.class_sas r=class_sas;
    1111 out=       import data=worksas.class_sas_&sex r=sex;
    1111 r2mac=     NULL

    2                                                                                                                         Altair SLC

    1111 resolve=   Y
    17             '
    18               library(sqldf);
    19
    20               sex<-fn$sqldf(
    21                 "
    22                  select
    23                     *
    24                  from
    25                     class_sas
    26                  where
    27                     sex = `&sex`
    28               ");
    29              print(sex);
    30             '
    31             ,resolve= Y
    32             ,inp    = %str(export data=worksas.class_sas r=class_sas;)
    33             ,out   =  %nrstr(import data=worksas.class_sas_&sex r=sex;)
    34             );));
    35
    36          end;
    37
    38        run;

    38      !     quit;
    39        ;                                                     ;                                                       * clear clipboard ;                                                              filename _clp clipbrd;
    39                        data _null_;                                                                       file _clp;                                                                       put " ";
    39           run;

    NOTE: The file _clp is:
          Clipboard

    NOTE: 1 record was written to file _clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    39      !        quit;                                                                        ***********************************************************************;         * convert code string to a file and optionally resolve macro triggers *;
    39        e to clipboard if requires                                  *;         ***********************************************************************;         data _null_;                                                                       length
    39                                                                    file "c:/temp/r_pgm.txt" lrecl=32766 recfm=v;                                                      pgm=resolve('        library(sqldf);         sex<-fn$sqldf(          "           s
    39            *           from              class_sas           where              sex = `&sex`        ");       print(sex);      ');                                                              putlog pgm;
    39                      ***********************************************************************;         * conver backtic to single quote. Outside single quote is gone        *;         * add write to clipboard if asked for
    39         ***********************************************************************;           if index(pgm,"`") then pgm=tranwrd(pgm,"`","27"x);                               put pgm;
    39        ;                                                                    run;

    NOTE: The file 'c:\temp\r_pgm.txt' is:
          Filename='c:\temp\r_pgm.txt',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:07:06 Feb 05 2026,
          Last Modified=12:07:06 Feb 05 2026,
          Lrecl=32766, Recfm=V

    library(sqldf);         sex<-fn$sqldf(          "           select              *           from              class_sas           where              sex = `F`        ");       print(sex);
    library(sqldf);         sex<-fn$sqldf(          "           select              *           from              class_sas           where              sex = 'F'        ");       print(sex);
    NOTE: 1 record was written to file 'c:\temp\r_pgm.txt'
          The minimum record length was 187
          The maximum record length was 187
    NOTE: The data step took :

    3                                                                                                                         Altair SLC

          real time : 0.013
          cpu time  : 0.015


    39      !                                                                                                                                                       ***********************************************************************;         * handle i
    39        ts and source the code file                  *;         ***********************************************************************;         data _null_;                                                                        file "c:/temp/rcode.
    39                                                      put "proc r;";                                                inp=resolve("export data=worksas.class_sas r=class_sas;");                                                             put inp;
    39                                                               put "  submit;";                                                                 put "    source('c:/temp/r_pgm.txt',echo=TRUE)";                                 put "  endsubmit;";
    39                                    out=resolve("import data=worksas.class_sas_&sex r=sex;");                                                             put out;                                                                            put "quit;"
    39                                                               putlog "quit;";                                                                run;

    NOTE: The file 'c:\temp\rcode.r' is:
          Filename='c:\temp\rcode.r',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:07:06 Feb 05 2026,
          Last Modified=12:07:06 Feb 05 2026,
          Lrecl=32767, Recfm=V

    quit;
    NOTE: 7 records were written to file 'c:\temp\rcode.r'
          The minimum record length was 5
          The maximum record length was 42
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    39      !                                                                                                                                                                                                                       ***************************
    39        *****************************;         * run r code with inputs and outputs                                  *;         ***********************************************************************;         %include "c:/temp/rcode.r";
    Start of %INCLUDE(level 1) c:/temp/rcode.r
    40      +  proc r;
    NOTE: Using R version 4.5.2 (2025-10-31 ucrt) from C:\Program Files\R\R-4.5.2
    41      +  export data=worksas.class_sas r=class_sas;
    NOTE: Creating R data frame 'class_sas' from data set 'WORKSAS.class_sas'

    42      +    submit;
    43      +      source('c:/temp/r_pgm.txt',echo=TRUE)
    44      +    endsubmit;

    NOTE: Submitting statements to R:

    >     source('c:/temp/r_pgm.txt',echo=TRUE)
    > library(sqldf)
    Loading required package: gsubfn
    Loading required package: proto
    Loading required package: RSQLite
    > sex <- fn$sqldf("           select              *           from              class_sas           where              sex = 'F'        ")
    > print(sex)

    NOTE: Processing of R statements complete

    45      +  import data=worksas.class_sas_F r=sex;
    NOTE: Creating data set 'WORKSAS.class_sas_F' from R data frame 'sex'
    NOTE: Data set "WORKSAS.class_sas_F" has 9 observation(s) and 5 variable(s)

    46      +  quit;
    NOTE: Procedure r step took :
          real time : 1.488
          cpu time  : 0.046



    4                                                                                                                         Altair SLC

    End of %INCLUDE(level 1) c:/temp/rcode.r
    39                                  ***********************************************************************;         * write cliboard to macro variable r2mac                              *;         *****************************************************
    39        ***;;
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 1.501
          cpu time  : 0.062
    47        ;                                                     ;                                                       * clear clipboard ;                                                              filename _clp clipbrd;
    47                        data _null_;                                                                       file _clp;                                                                       put " ";
    47           run;

    NOTE: The file _clp is:
          Clipboard

    NOTE: 1 record was written to file _clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    47      !        quit;                                                                        ***********************************************************************;         * convert code string to a file and optionally resolve macro triggers *;
    47        e to clipboard if requires                                  *;         ***********************************************************************;         data _null_;                                                                       length
    47                                                                    file "c:/temp/r_pgm.txt" lrecl=32766 recfm=v;                                                      pgm=resolve('        library(sqldf);         sex<-fn$sqldf(          "           s
    47            *           from              class_sas           where              sex = `&sex`        ");       print(sex);      ');                                                              putlog pgm;
    47                      ***********************************************************************;         * conver backtic to single quote. Outside single quote is gone        *;         * add write to clipboard if asked for
    47         ***********************************************************************;           if index(pgm,"`") then pgm=tranwrd(pgm,"`","27"x);                               put pgm;
    47        ;                                                                    run;

    NOTE: The file 'c:\temp\r_pgm.txt' is:
          Filename='c:\temp\r_pgm.txt',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:07:07 Feb 05 2026,
          Last Modified=12:07:07 Feb 05 2026,
          Lrecl=32766, Recfm=V

    library(sqldf);         sex<-fn$sqldf(          "           select              *           from              class_sas           where              sex = `M`        ");       print(sex);
    library(sqldf);         sex<-fn$sqldf(          "           select              *           from              class_sas           where              sex = 'M'        ");       print(sex);
    NOTE: 1 record was written to file 'c:\temp\r_pgm.txt'
          The minimum record length was 187
          The maximum record length was 187
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    47      !                                                                                                                                                       ***********************************************************************;         * handle i
    47        ts and source the code file                  *;         ***********************************************************************;         data _null_;                                                                        file "c:/temp/rcode.
    47                                                      put "proc r;";                                                inp=resolve("export data=worksas.class_sas r=class_sas;");                                                             put inp;
    47                                                               put "  submit;";                                                                 put "    source('c:/temp/r_pgm.txt',echo=TRUE)";                                 put "  endsubmit;";
    47                                    out=resolve("import data=worksas.class_sas_&sex r=sex;");                                                             put out;                                                                            put "quit;"
    47                                                               putlog "quit;";                                                                run;

    NOTE: The file 'c:\temp\rcode.r' is:
          Filename='c:\temp\rcode.r',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:07:07 Feb 05 2026,

    5                                                                                                                         Altair SLC

          Last Modified=12:07:07 Feb 05 2026,
          Lrecl=32767, Recfm=V

    quit;
    NOTE: 7 records were written to file 'c:\temp\rcode.r'
          The minimum record length was 5
          The maximum record length was 42
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    47      !                                                                                                                                                                                                                       ***************************
    47        *****************************;         * run r code with inputs and outputs                                  *;         ***********************************************************************;         %include "c:/temp/rcode.r";
    Start of %INCLUDE(level 1) c:/temp/rcode.r
    48      +  proc r;
    NOTE: Using R version 4.5.2 (2025-10-31 ucrt) from C:\Program Files\R\R-4.5.2
    49      +  export data=worksas.class_sas r=class_sas;
    NOTE: Creating R data frame 'class_sas' from data set 'WORKSAS.class_sas'

    50      +    submit;
    51      +      source('c:/temp/r_pgm.txt',echo=TRUE)
    52      +    endsubmit;

    NOTE: Submitting statements to R:

    >     source('c:/temp/r_pgm.txt',echo=TRUE)
    > library(sqldf)
    Loading required package: gsubfn
    Loading required package: proto
    Loading required package: RSQLite
    > sex <- fn$sqldf("           select              *           from              class_sas           where              sex = 'M'        ")
    > print(sex)

    NOTE: Processing of R statements complete

    53      +  import data=worksas.class_sas_M r=sex;
    NOTE: Creating data set 'WORKSAS.class_sas_M' from R data frame 'sex'
    NOTE: Data set "WORKSAS.class_sas_M" has 10 observation(s) and 5 variable(s)

    54      +  quit;
    NOTE: Procedure r step took :
          real time : 1.386
          cpu time  : 0.000


    End of %INCLUDE(level 1) c:/temp/rcode.r
    47                                  ***********************************************************************;         * write cliboard to macro variable r2mac                              *;         *****************************************************
    47        ***;;
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 1.386
          cpu time  : 0.000
    NOTE: The data step took :
          real time : 2.969
          cpu time  : 0.109


    55
    56
    57        proc print data=worksas.class_sas_M;
    58        title "worksas.class_sas_sex"

    6                                                                                                                         Altair SLC

    59        run;quit;
    NOTE: 10 observations were read from "WORKSAS.class_sas_M"
    NOTE: Procedure print step took :
          real time : 0.000
          cpu time  : 0.000


    60
    61        proc print data=worksas.class_sas_F;
    62        title "worksas.class_sas_sex"
    63        run;quit;
    NOTE: 9 observations were read from "WORKSAS.class_sas_F"
    NOTE: Procedure print step took :
          real time : 0.000
          cpu time  : 0.000


    64
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 3.050
          cpu time  : 0.187

    /*__              _ _                                   _           _     _
     / /_    ___ __ _| | |  _ __ ___   __ _  ___ _ __ ___  (_)_ __  ___(_) __| | ___   _ __
    | `_ \  / __/ _` | | | | `_ ` _ \ / _` |/ __| `__/ _ \ | | `_ \/ __| |/ _` |/ _ \ | `__|
    | (_) || (_| (_| | | | | | | | | | (_| | (__| | | (_) || | | | \__ \ | (_| |  __/ | |
     \___/  \___\__,_|_|_| |_| |_| |_|\__,_|\___|_|  \___/ |_|_| |_|___/_|\__,_|\___| |_|

    */

    proc delete data=worksas.class_sas_m worksas.class_sas_f;
    run;

    %array(sx,values=M F);

    %put &=sx1; /*--- SX1=M ---*/
    %put &=sx2; /*--- SX2=F ---*/
    %put &=sxn; /*--- SXN=2 ---*/

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


    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC     12:10 Thursday, February  5, 2026

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿ods _all_ close;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx

    NOTE: Library slchelp assigned as follows:
          Engine:        WPD
          Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp

    NOTE: Library worksas assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\worksas

    NOTE: Library workwpd assigned as follows:
          Engine:        WPD
          Physical Name: d:\workwpd


    LOG:  12:10:24
    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.015
          cpu time  : 0.000


    NOTE: AUTOEXEC processing completed

    1         proc delete data=worksas.class_sas_m worksas.class_sas_f;
    2         run;
    NOTE: Deleting "WORKSAS.CLASS_SAS_M" (memtype="DATA")
    NOTE: Deleting "WORKSAS.CLASS_SAS_F" (memtype="DATA")
    NOTE: Procedure delete step took :
          real time : 0.000
          cpu time  : 0.000


    3
    4         %array(sx,values=M F);
    5
    6         %put &=sx1; /*--- SX1=M ---*/
    sx1=M
    7         %put &=sx2; /*--- SX2=F ---*/
    sx2=F
    8         %put &=sxn; /*--- SXN=2 ---*/
    sxn=2
    9
    10        %do_over(sx,phrase=%nrstr(
    NOTE: View opening spill file for output observations.
    11             %slc_submit_r64(
    12             '
    13              library(sqldf);
    14              sex<-sqldf(
    15               "

    2                                                                                                                         Altair SLC

    16                select
    17                   *
    18                from
    19                   class_sas
    20                where
    21                   sex = `?`
    22               ");
    23              print(sex);
    24             '
    25             ,resolve=Y
    26             ,inp   = %str(export data=worksas.class_sas r=class_sas;)
    27             ,out   = %str(import data=worksas.class_sas_? r=sex;)
    28             );
    29        ));
    1111 inp=       export data=worksas.class_sas r=class_sas;
    1111 out=       import data=worksas.class_sas_M r=sex;
    1111 r2mac=     NULL
    1111 resolve=   Y

    NOTE: The file _clp is:
          Clipboard

    NOTE: 1 record was written to file _clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000



    NOTE: The file 'c:\temp\r_pgm.txt' is:
          Filename='c:\temp\r_pgm.txt',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:10:24 Feb 05 2026,
          Last Modified=12:10:24 Feb 05 2026,
          Lrecl=32766, Recfm=V

    library(sqldf);       sex<-sqldf(        "         select            *         from            class_sas         where            sex = `M`        ");       print(sex);
    library(sqldf);       sex<-sqldf(        "         select            *         from            class_sas         where            sex = 'M'        ");       print(sex);
    NOTE: 1 record was written to file 'c:\temp\r_pgm.txt'
          The minimum record length was 168
          The maximum record length was 168
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.015



    NOTE: The file 'c:\temp\rcode.r' is:
          Filename='c:\temp\rcode.r',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:10:24 Feb 05 2026,
          Last Modified=12:10:24 Feb 05 2026,
          Lrecl=32767, Recfm=V

    quit;
    NOTE: 7 records were written to file 'c:\temp\rcode.r'
          The minimum record length was 5

    3                                                                                                                         Altair SLC

          The maximum record length was 42
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    Start of %INCLUDE(level 1) c:/temp/rcode.r
    30      +  proc r;
    NOTE: Using R version 4.5.2 (2025-10-31 ucrt) from C:\Program Files\R\R-4.5.2
    31      +  export data=worksas.class_sas r=class_sas;
    NOTE: Creating R data frame 'class_sas' from data set 'WORKSAS.class_sas'

    32      +    submit;
    33      +      source('c:/temp/r_pgm.txt',echo=TRUE)
    34      +    endsubmit;

    NOTE: Submitting statements to R:

    >     source('c:/temp/r_pgm.txt',echo=TRUE)
    > library(sqldf)
    Loading required package: gsubfn
    Loading required package: proto
    Loading required package: RSQLite
    > sex <- sqldf("         select            *         from            class_sas         where            sex = 'M'        ")
    > print(sex)

    NOTE: Processing of R statements complete

    35      +  import data=worksas.class_sas_M r=sex;
    NOTE: Creating data set 'WORKSAS.class_sas_M' from R data frame 'sex'
    NOTE: Data set "WORKSAS.class_sas_M" has 10 observation(s) and 5 variable(s)

    36      +  quit;
    NOTE: Procedure r step took :
          real time : 1.361
          cpu time  : 0.062


    End of %INCLUDE(level 1) c:/temp/rcode.r
    1111 inp=       export data=worksas.class_sas r=class_sas;
    1111 out=       import data=worksas.class_sas_F r=sex;
    1111 r2mac=     NULL
    1111 resolve=   Y

    NOTE: The file _clp is:
          Clipboard

    NOTE: 1 record was written to file _clp
          The minimum record length was 1
          The maximum record length was 1
    NOTE: The data step took :
          real time : 0.016
          cpu time  : 0.000



    NOTE: The file 'c:\temp\r_pgm.txt' is:
          Filename='c:\temp\r_pgm.txt',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:10:25 Feb 05 2026,
          Last Modified=12:10:25 Feb 05 2026,

    4                                                                                                                         Altair SLC

          Lrecl=32766, Recfm=V

    library(sqldf);       sex<-sqldf(        "         select            *         from            class_sas         where            sex = `F`        ");       print(sex);
    library(sqldf);       sex<-sqldf(        "         select            *         from            class_sas         where            sex = 'F'        ");       print(sex);
    NOTE: 1 record was written to file 'c:\temp\r_pgm.txt'
          The minimum record length was 168
          The maximum record length was 168
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000



    NOTE: The file 'c:\temp\rcode.r' is:
          Filename='c:\temp\rcode.r',
          Owner Name=SLC\suzie,
          File size (bytes)=0,
          Create Time=09:32:02 Feb 05 2026,
          Last Accessed=12:10:25 Feb 05 2026,
          Last Modified=12:10:25 Feb 05 2026,
          Lrecl=32767, Recfm=V

    quit;
    NOTE: 7 records were written to file 'c:\temp\rcode.r'
          The minimum record length was 5
          The maximum record length was 42
    NOTE: The data step took :
          real time : 0.000
          cpu time  : 0.000


    Start of %INCLUDE(level 1) c:/temp/rcode.r
    37      +  proc r;
    NOTE: Using R version 4.5.2 (2025-10-31 ucrt) from C:\Program Files\R\R-4.5.2
    38      +  export data=worksas.class_sas r=class_sas;
    NOTE: Creating R data frame 'class_sas' from data set 'WORKSAS.class_sas'

    39      +    submit;
    40      +      source('c:/temp/r_pgm.txt',echo=TRUE)
    41      +    endsubmit;

    NOTE: Submitting statements to R:

    >     source('c:/temp/r_pgm.txt',echo=TRUE)
    > library(sqldf)
    Loading required package: gsubfn
    Loading required package: proto
    Loading required package: RSQLite
    > sex <- sqldf("         select            *         from            class_sas         where            sex = 'F'        ")
    > print(sex)

    NOTE: Processing of R statements complete

    42      +  import data=worksas.class_sas_F r=sex;
    NOTE: Creating data set 'WORKSAS.class_sas_F' from R data frame 'sex'
    NOTE: Data set "WORKSAS.class_sas_F" has 9 observation(s) and 5 variable(s)

    43      +  quit;
    NOTE: Procedure r step took :
          real time : 1.371
          cpu time  : 0.015



    5                                                                                                                         Altair SLC

    End of %INCLUDE(level 1) c:/temp/rcode.r
    44
    45        proc print data=worksas.class_sas_M;
    46        title "worksas.class_sas_sex"
    47        run;quit;
    NOTE: 10 observations were read from "WORKSAS.class_sas_M"
    NOTE: Procedure print step took :
          real time : 0.000
          cpu time  : 0.000


    48
    49        proc print data=worksas.class_sas_F;
    50        title "worksas.class_sas_sex"
    51        run;quit;
    NOTE: 9 observations were read from "WORKSAS.class_sas_F"
    NOTE: Procedure print step took :
          real time : 0.000
          cpu time  : 0.015


    52
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 3.001
          cpu time  : 0.218
    /*              _
      ___ _ __   __| |
     / _ \ `_ \ / _` |
    |  __/ | | | (_| |
     \___|_| |_|\__,_|

    */

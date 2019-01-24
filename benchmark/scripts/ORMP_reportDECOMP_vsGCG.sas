%let logpath=\\orgrdlog01\data\LOGS\gcg_20180713_gcg_GCG3_decomplst5;
/*%let logpath=\\orgrdlog01\data\LOGS\gcg_20180714_gcg_t7200_GCG3_miplib2010b;*/

/* How did I get gcg_resuluts.txt? */

PROC IMPORT OUT= WORK.T 
            DATAFILE= "&logpath\gcg_results.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=NO;
     DATAROW=1; 
	 GUESSINGROWS=20000;
RUN;
data t2(rename=(var1=name var2=logfiletmp var4=scip_solution_time var5=nodes var6=objective var7=best_bound var8=solution_time_tot var9=read_time)); 
   length solution_status $ 20 result_status $ 20;
   set t(drop=VAR10); 
   status="OK";
   iterations=.;
   memory=.;
   if var3="solving was interrupted [time limit reached]" then do; result_status="LIMIT"; solution_status="TIME_LIM"; end;
   else if var3="problem is solved [optimal solution found]" then do; result_status="SOLVED"; solution_status="OPTIMAL"; end;
   else if var3="solving was interrupted [gap limit reached]" then do; result_status="SOLVED"; solution_status="OPTIMAL_RGAP"; end;
   else if var3="problem is solved [infeasible]" then do; result_status="SOLVED"; solution_status="INFEASIBLE"; end;
   else do; result_status="ERROR"; solution_status="FAIL"; end; 
run;
data dg0;
   length logfile $200;
   set t2;
   logfile=cat("&logpath\",logfiletmp);
   solution_time = solution_time_tot - read_time;
   absolute_gap=.;
   relative_gap=.;
   if(solution_status IN ("TIME_LIM")) then do;
      if(objective=1e20) then solution_status = "TIME_LIM_NOSOL"; else solution_status = "TIME_LIM_SOL";
   end;
   if(solution_status IN ("TIME_LIM_SOL","OPTIMAL","OPTIMAL_RGAP")) then do;
      absolute_gap=objective-best_bound;
      relative_gap=abs(objective-best_bound) / (1.e-10 + abs(best_bound));
   end;
run;
proc print data=dg0(obs=10); run;
proc sort data=work.dg0; by name; run;
%let dg0L=GCG 3.0;

/******************************************************************************************/
/******************************************************************************************/
%include '\\orgrdlog01\data\scripts_eval\ORMP_reportDECOMP_Macros.sas';
/******************************************************************************************/
/******************************************************************************************/
%let path = \\orgrdlog01\data\LOGS\;
%let outputBase = U:\benchmarks\decomp2\2018JUL\vsGCG2_2;
/*%let outputBase = U:\benchmarks\decomp2\2018JUL\vsGCG_MIPLIB2010B;*/
%let output     = &outputBase.\mip_hybrid;
/******************************************************************************************/
options dlcreatedir;
libname dir1 ("&outputBase");
libname dir2 ("&output");
/******************************************************************************************/

%let listMip = \\orgrdlog01\data\scripts\milpBenchPlusDecompMinusAPC4HNoDecomp.lst;
/*%let listMip = \\orgrdlog01\data\scripts\milpMIPLIB2010_B.lst;*/

/*%let dm0 = optmilp_20180507_parmilp_v940m5b_dlist_direct; %let dm0L=MILP 2018 (v14.3.2) [355 solved];*/
/*%ORMP_readOPTMILP(work.dm0, "&listMip", "&path.&dm0", solver='parmilp');*/
/*proc sort data=work.dm0; by name; run;*/
/*proc print data=work.dm0; run;*/



/******************************************************************************************/
/* Hybrid On */
/******************************************************************************************/
%macro HybridOn();
/* Current playpen status against 9.4m5b -> +10 instances from 14.32, same speed. */
%SetupDataSetNames(date=20180712, extra=v940m5b_poollp20_default_hybrid, name=940m5b_DECOMP(LPISA20MB),n=151p2);

/* This is not the most recent playpen and also 9.5 */
/*%SetupDataSetNamesOpt(date=20180705, opt=auto7200, extra=v950m50_stop_default_hybrid, name=950m0_DECOMP(Jul 0705 - Stop),n=151p2);*/

%mend HybridOn;


%HybridOn();

/******************************************************************************************/
/******************************************************************************************/
ods listing close;
ods html path="&output"(url=none) contents="menu.htm" frame="index.htm" body="summary.htm";  
goptions reset=all;
goptions transparency;
/******************************************************************************************/
%Compare2(n1=g0,n2=151p2);

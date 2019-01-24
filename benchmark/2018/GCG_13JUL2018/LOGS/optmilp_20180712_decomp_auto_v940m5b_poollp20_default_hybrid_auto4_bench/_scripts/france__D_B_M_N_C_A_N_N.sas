
option fullstimer;
option ls=256;
%include "/LOG_DATA/scripts/options_decomp_auto.sas";
libname lib ('/opt/input'  '/ORDATA/miplib') ACCESS=READONLY;
%let _OROPTMILP_=;
%put OPTIONS=  &options;
%put OPTIONSD=  &optionsd;
%put OPTIONSDS=  &optionsds;
%put OPTIONSDM=  &optionsdm;
%put OPTIONSDMIP=  &optionsdmip;
proc optmilp localdata=on nthreads=4 relobjgap=0.0001 data=lib.france__D_B_M_N_C_A_N_N &options; &optionsd hybrid=on; &optionsds; &optionsdm; &optionsdmip;
performance nthreads=4;
run;
%put &_OROPTMILP_;
endsas;


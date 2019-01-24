#!/usr/bin/env bash 
#The third before last SCIP Status should be what we want.

rm gcg_results.txt
for i in *_condorout.*; do
#for i in t; do
    echo $i
    name=$(basename "$i" | cut -d. -f1)
    name2=$(sed 's/_gcg_condorout//g' <<< $name)
#    echo $name
    echo "Name : " $name2 " " > tmp1
    echo "LogFile : " $i " " >> tmp1 
    tac $i | grep -m 3 -B 5 "SCIP Status" | tac | head -5 >> tmp1
    echo "GCGTime : " `grep "GCGTIME" $i | awk '{print $2}'` >> tmp1
    grep "reading" $i | tail -n1 >> tmp1
    awk -F ':' '{print $2}' tmp1 | awk -F '(' '{print $1}' | awk '{if(NR==3) printf("\"%s\"\t",$0); else printf("%s\t",$0);}END{printf("\n");}' >> gcg_results.txt
done;
rm tmp1



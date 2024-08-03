#!/bin/bash

######----------------------------------------------------- ######
######------------- RUN FOR 4/1-CORE EXPERIMENTS ---------- ######
######----------------------------------------------------- ######

## Set the paths
# source env.sh;

## Eror Checking
if [ -z ${MAX_GEM5_PARALLEL_RUNS+x} ];
then
    echo "MAX_GEM5_PARALLEL_RUNS is unset";
    exit
else
    echo "MAX_GEM5_PARALLEL_RUNS is set to '$MAX_GEM5_PARALLEL_RUNS'";
fi

rfm=$1
br=$2
rfm0_or_para1=$3
qsub=$4

#max_act_trefi=166  # DDR4
#max_act_trefi=83    # DDR5
max_act_trefi=79    # DDR5

# Check if $qsub is empty
if [ -z "$qsub" ] 
then
    qsub=0
fi
# Setting default vals for rfm and br
if [ -z "$rfm" ] 
then
    rfm=1
fi
if [ -z "$br" ] 
then
    br=1
fi
if [ -z "$rfm0_or_para1" ] 
then
    rmf0_or_para1=0
fi
defense_name=RFM
if [ $rfm0_or_para1 -eq 1 ] 
then
    defense_name=PARA
fi

if [ $qsub -gt 0 ] 
then
    qsub=1
    qsub_cmdfile="pride_experiments.txt"
    rm -rf $qsub_cmdfile ; touch $qsub_cmdfile ;
fi

config="${defense_name}${rfm}.BR${br}.4C"
# for bmk in mix2 mix17 \
#  for bmk in  \
#      gcc bwaves mcf cactuBSSN namd povray lbm wrf \
#      x264 blender deepsjeng imagick leela nab exchange2 roms xz parest \
#      mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 \
#      mix11 mix12 mix13 mix14 mix15 mix16 mix17 \
  for bmk in  \
      bwaves mcf gcc cactuBSSN namd povray lbm wrf \
      blender deepsjeng imagick leela nab exchange2 roms xz \
      mix1 mix3 mix4 mix6 mix7 mix9 mix10 \
      mix11 mix12 mix13 mix14 mix15 mix16 mix17 \
; do 
    #************* RRS base config BEGIN *************#
    # 
    if [ $qsub -gt 0 ] 
    then
	echo "./runscript_pride.sh $bmk $config 4 2017 --rh_defense --rh_mitigation=${defense_name} --rh_rfm_per_trefi=${rfm} --rh_rfm_blast_radius=${br} --rh_rfm_maxacts_per_trefi=${max_act_trefi}" >> $qsub_cmdfile;
    else    	    
    ./runscript_pride.sh $bmk $config 4 2017 \
     --rh_defense --rh_mitigation=${defense_name} --rh_rfm_per_trefi=${rfm} --rh_rfm_blast_radius=${br} --rh_rfm_maxacts_per_trefi=${max_act_trefi} ;
    fi
    #************* RRS base config END *************#

##     #************* RRS scalability configs BEGIN *************#
##     # RRS for TRH=2K
##     ./runscript.sh $bmk AE.RRS.2K.4C 4 2017 \
##      --rh_defense --rh_mitigation=RRS --rh_actual_threshold=2000;
##     # RRS for TRH=4K
##     ./runscript.sh $bmk AE.RRS.4K.4C 4 2017 \
##      --rh_defense --rh_mitigation=RRS --rh_actual_threshold=4000;
##     #************* RRS scalability configs END *************#

    ## Wait for a core to be available
    exp_count=`ps aux | grep -i "gem5" | grep -i "pride" | grep -v "grep" | wc -l`

    echo "Currently Running Experiments: $exp_count \n\n\n"

#    if [ -z "$qsub" ] 
#    then
	while [ $exp_count -gt ${MAX_GEM5_PARALLEL_RUNS} ]
	do
            echo "\tSleeping since experiments exceeded $MAX_GEM5_PARALLEL_RUNS...  Waiting for some to finish."
            sleep 300
            exp_count=`ps aux | grep -i "gem5" | grep -i "pride" | grep -v "grep" | wc -l`
            echo
	done
#    fi
done

exp_count=`ps aux | grep -i "gem5" | grep -i "pride" | grep -v "grep" | wc -l`
if [ -z "$qsub" ] 
then
    while [ $exp_count -gt 0 ]
    do
	sleep 300
	exp_count=`ps aux | grep -i "gem5" | grep -i "pride" | grep -v "grep" | wc -l`    
    done
fi

if [ $qsub -gt 0 ]
then 
    echo "Sending jobs to farm"
    echo "./run_qsub.sh $qsub_cmdfile ;"
    echo "Done sending jobs to farm"
fi

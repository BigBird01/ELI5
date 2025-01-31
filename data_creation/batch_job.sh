#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
SOURCE=$(dirname "$(readlink -f "$0")")/
TARGET_DIR=$HOME/job_dir/ELI5
mkdir -p $TARGET_DIR
rsync -ruC --exclude  pre_computed  --exclude processed_data --exclude *.pyc $SOURCE/ $TARGET_DIR

work_dir=$TARGET_DIR/
log_dir=/mount/biglm_data/ELI5/logs_docs/
mkdir -p $log_dir

export WORLD_SIZE=16
nodes=$(python -c "for i in range(1,$WORLD_SIZE):  print(i)")
node_ids=($(python -c "for i in range(0,$WORLD_SIZE):  print(i)"))
#years=($(python -c "for i in range(2011,2011+$WORLD_SIZE):  print(i)"))
#master=$(ssh -x -o LogLevel=ERROR worker-1 "echo \$hostname" )
for i in $nodes; do
	worker=worker-${node_ids[$i]}
	sy=${years[$i]}
	rank=$i
	ssh -x -o LogLevel=ERROR  $worker "mkdir -p $TARGET_DIR"
	rsync -ruC  --exclude  pre_computed  --exclude processed_data -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"  $TARGET_DIR/ $worker:$TARGET_DIR
	ssh -x -o LogLevel=ERROR  $worker "mkdir -p $log_dir; cd $work_dir; nohup ./download_docs.sh $rank > ${log_dir}/nohup_${i}.std  2> ${log_dir}/nohup_${i}.err &"
done

i=0
rank=$i
worker=worker-${node_ids[$i]}
sy=${years[$i]}
ssh -x -o LogLevel=ERROR  $worker "mkdir -p $TARGET_DIR"
rsync -ruC  --exclude  pre_computed  --exclude processed_data -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"  $TARGET_DIR/ $worker:$TARGET_DIR
ssh -x -o LogLevel=ERROR  $worker "mkdir -p $log_dir; cd $work_dir; ./download_docs.sh $rank"

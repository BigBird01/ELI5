#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
cd $SCRIPT_DIR
rank=$1

#pip install -r requirements.txt
output=/mount/biglm_data/ELI5/processed_data/support_docs_$rank
pre_computed=/mount/biglm_data/ELI5/pre_computed
mkdir -p $output
slsize=$[71520/16]

kill -9 $(ps -x |grep "download_support_docs.py" |grep -v grep|awk -F' ' '{print $1}')
python download_support_docs.py  --slnum $rank --slsize $slsize --subreddit_names '["explainlikeimfive", "AskHistorians", "askscience"]' --output_dir $output \
	--wet_urls ${pre_computed}/wet.paths --pre_computed_dir ${pre_computed}

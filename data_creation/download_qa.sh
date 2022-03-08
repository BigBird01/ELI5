#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
cd SCRIPT_DIR
year=$1

pip install -r requirements.txt
output=/mount/biglm_data/ELI5/processed_data_$year
mkdir -p $output
python download_reddit_qalist.py  -sy $year -ey $year --subreddit_list '["explainlikeimfive", "AskHistorians", "askscience"]' --output_dir $output 

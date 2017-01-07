#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: ${0} /path/to/videos/ /path/to/new_filenames.txt /path/to/destination/directory"
  echo
  echo "Script will look for subdirectories in /path/to/videos/ and copy first file from each subdirectory"
  echo "to destination directory and rename this file to consecutive filename from new_filenames.txt."
  echo "It is expected that each subdirectory contains exactly one file."
  exit
fi

echo "From: ${1}"
echo "To: ${3}"
echo "new filenames: ${2}"
echo

cd ${1}

dir_count=`ls -dtr */ | wc -l`
filenames_count=`cat ${2} | wc -l`
if [ ${dir_count} -ne ${filenames_count} ]; then
  echo "FATAL: Directories count not equal new filenames count: ${dir_count} != ${filenames_count}"
  exit
fi

counter=1

for directory in `ls -dtr */`
do
  formatted_counter=$(printf "%02d" ${counter})
  echo "${formatted_counter} Going into ${directory}"
  cd ${directory}

  current_filename=`ls | head -n 1`
  echo "current_filename=${current_filename}"

  desired_filename=`sed -n "${counter}p" < ${2}`
  echo "desired_filename=${desired_filename}"

  final_filename="${formatted_counter}_${desired_filename}_${current_filename}"
  echo "final_filename=${final_filename}"

  cp ${current_filename} ${3}/${final_filename}

  cd ../
  ((counter++))
done


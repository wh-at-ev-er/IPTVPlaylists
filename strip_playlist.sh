#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "No arguments supplied: Please supply TRUE or FALSE to rename English TV Shows Groups etc"
    exit 1
fi

BASLINE=/storage/playlists
RUNAREA=/storage/scripts
group_file='groups.txt'
playlist_input='temp.txt'
playlist_url='http://xxxx'
playlist_output='tv_channels_and_vod.m3u'
rename_tv_groups=$1
tv_groups="
English TV Shows
English Documentary
"

wget -q -O $RUNAREA/$playlist_input $playlist_url

if [ "$?" -eq 0 ]; then

  dos2unix $RUNAREA/$playlist_input
  rm -f $BASLINE/$playlist_output
  echo '#EXTM3U' > $BASLINE/$playlist_output

  while read p; do
    output=""
    lines_written=FALSE
    escape_string=$(echo $p | sed "s/[!@#$%^&*/()=-]/\\\&/g")
    output=`awk '/group-title="'$escape_string'"/{print;exit}' $RUNAREA/$playlist_input`
    
    if [ -z "$output" ]; then
      IFS=$'\n'
      for group in $tv_groups
      do
        output=`awk '/group-title="'"$group"'",'$escape_string'*/{nr[NR]; nr[NR+1]}; NR in nr' $RUNAREA/$playlist_input`

        if [ "$rename_tv_groups" == 'TRUE' ] && [ ! -z "$output" ]; then
          for items in $output 
          do
            category=$(echo $items | awk -F'"' '{ print $8 }')
            if [[ "$category" == "$group" ]]; then
              showname=$(echo $items | sed -e 's/.*"'"$group"'",\(.*\) S[0-9][0-9] E[0-9][0-9].*/\1/')
              echo $items | sed -e "s/"$group"/$showname/g" >> $BASLINE/$playlist_output
            else 
              echo $items >> $BASLINE/$playlist_output
            fi
          done 
			  
          lines_written=TRUE
          break
			  
        fi
      done	
    fi
      
    if [[ "$lines_written" == 'FALSE' ]]; then
      IFS=
      awk '/group-title="'$escape_string'"/{nr[NR]; nr[NR+1]}; NR in nr' $RUNAREA/$playlist_input >> $BASLINE/$playlist_output
    fi

  done < $RUNAREA/$group_file

  awk '!/--/' $BASLINE/$playlist_output > temp && mv temp $BASLINE/$playlist_output

  rm -f $RUNAREA/$playlist_input

fi

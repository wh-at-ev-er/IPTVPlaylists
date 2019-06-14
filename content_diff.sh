#!/bin/bash
BASEDIR=~/playlists
playlist_input='temp.txt'
playlist_url='http://xxx'
playlist_new='new_playlist.txt'
playlist_curr='curr_playlist.txt'
email_addr='a@a.com

wget -q -O $BASEDIR/$playlist_input $playlist_url 

if [ "$?" -eq 0 ]; then

  more $BASEDIR/$playlist_input | grep "#EXTINF:" | awk -F'"' '{ print $8$9 }' > $BASEDIR/$playlist_new

  sort $BASEDIR/$playlist_new -o $BASEDIR/$playlist_new

  rm $BASEDIR/$playlist_input

  if [ ! -f $BASEDIR/$playlist_curr ]; then
    cp $BASEDIR/$playlist_new $BASEDIR/$playlist_curr
  fi

  sort $BASEDIR/$playlist_curr -o $BASEDIR/$playlist_curr

  playlist_additions="$(diff -w "$BASEDIR/$playlist_new" "$BASEDIR/$playlist_curr" | grep '<' | sed 's/< //' )"

  playlist_deletions="$(diff -w "$BASEDIR/$playlist_new" "$BASEDIR/$playlist_curr" | grep '>' | sed 's/> //' )"

  if [[ ! -z $playlist_additions ]]; then
    echo "$playlist_additions" | mail -s "New IPTV Content $(date +"%Y%m%d")" $email_addr
  fi

  if [[ ! -z $playlist_deletions ]]; then
    echo "$playlist_deletions" | mail -s "Removed IPTV Content $(date +"%Y%m%d")" $email_addr
  fi

  mv $BASEDIR/$playlist_curr $BASEDIR/"$playlist_curr"_$(date +"%Y%m%d")

  mv $BASEDIR/$playlist_new $BASEDIR/$playlist_curr

  find $BASEDIR/ -type f -mtime +7 -name '*.txt*' -execdir rm -- '{}' \;
  
else
  
  echo "Unable to Download IPTV Playlist $(date +"%Y%m%d")" | mail -s "Unable to Download IPTV Playlist $(date +"%Y%m%d")" $email_addr

fi

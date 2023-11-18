#!/bin/bash
#
#   This file echoes a bunch of color codes to the 
#   terminal to demonstrate what's available.  Each 
#   line is the color code of one forground color,
#   out of 17 (default + 16 escapes), followed by a 
#   test use of that color on all nine background 
#   colors (default + 8 escapes).
#

T='gYw'   # The test text

echo -e "\n                 40m     41m     42m     43m\
     44m     45m     46m     47m";

for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
           '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
           '  36m' '1;36m' '  37m' '1;37m';
  do FG=${FGs// /}
  echo -en " $FGs \033[$FG  $T  "
  for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
    do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
  done
  echo;
done
echo


###############################################################3

# #!/bin/bash
#https://arc.msn.com/v3/Delivery/Placement?pid=209567&fmt=json&rafb=0&ua=WindowsShellClient%2F0&cdm=1&disphorzres=9999&dispvertres=9999&lo=80217&pl=en-US&lc=en-US&ctry=IN&time=2017-12-31T23:59:59Z
#https://arc.msn.com/v3/Delivery/Placement?&fmt=json&cdm=1&ctry=IN&pid=338387&ua=WindowsShellClient%2F0&rafb=2

start=`date +%s`

desk="/home/me/Windows/BC38214F38210A4A/wall/desktop"
phone="/home/me/Windows/BC38214F38210A4A/wall/phone"
cntr=1
while [ $cntr -le 100 ]
do
   curl -s "arc.msn.com/v3/Delivery/Placement?&fmt=json&cdm=1&ctry=UK&pid=338387&ua=WindowsShellClient%2F0&lc=en-IN" > test.json
   sed --in-place 's/\\//g;s/\"{/{/g;s/}\"/}/g' test.json

   desk_file=$(cat test.json | jq -r '.batchrsp.items[].item.ad | "\(.title_text.tx) | \(.image_fullscreen_001_landscape.u)"')
   name=$(echo $desk_file | cut -d"|" -f1)
   desk_url=$(echo $desk_file | cut -d"|" -f2)
   if grep -Fq "$desk_url" "$desk/wallpapers.txt"
   then
	   echo "$name : Already present"
   else
	   echo "$cntr) $name"
	   echo $desk_file >> "$desk/wallpapers.txt"
	   phone_file=$(cat test.json | jq -r '.batchrsp.items[].item.ad | "\(.title_text.tx) | \(.image_fullscreen_001_portrait.u)"')
	   echo $phone_file >> "$phone/wallpapers.txt"
	   phone_url=$(echo $phone_file | cut -d"|" -f2)
       file=$(echo $name | sed 's/[ ]/-/g;s/[.,!@#$%^&*()_\x27]//g' | tr '[:upper:]' '[:lower:]').jpg

	   curl -s $(echo $desk_url | sed 's/https:\/\///') -o "$desk/$file" &
	   curl -s $(echo $phone_url | sed 's/https:\/\///') -o "$phone/$file" &
       wait

       exiftool -overwrite_original -all= "$desk/$file" > /dev/null 2>&1 &
       exiftool -overwrite_original -all= "$phone/$file" > /dev/null 2>&1 &
       wait

	   cntr=`expr $cntr + 1`
   fi
done

end=`date +%s`

echo "Execution Time is: $(($end-$start)) seconds"

cat 2020-06-30-103.md | egrep '^##### ' | sed 's/^##### //' | sed 's/<a name="//' | sed 's/"><\/a>//' | while read -r title ;
do link=$(echo $title | awk -F " " '{print $NF}') ;
stitle=$(echo $title | awk -F " " 'NF{NF--};1') ;
echo "[$stitle](#$link]" ;
done
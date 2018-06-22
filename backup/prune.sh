#!/bin/bash

############################################
#
# Prune
#
#  Removes old files according to 
#  data retention policy. 
#
#  Usage: prune.sh [OPTION] DIRECTORY
#
#  Options:
#   -r : Use recursive remove
#   -t : Test mode - does not remove files
#   -d=RETAIN_DAYS : Number of past days to preserve
#   -w=RETAIN_WEEKS : Number of past weeks to preserve
#   -m=RETAIN_MONTHS : Number of past months to preserve
#   -y=RETAIN_YEARS : Number of past years to preserve
#   -f=RE_FILENAME : Regular expression for filename format inlcuding (YYYY-MM-DD)
#
############################################

# default data retention policy parameters
RETAIN_DAYS=7
RETAIN_WEEKS=8
RETAIN_MONTHS=12
RETAIN_YEARS=5

# default filename regex: "*.YYYY-MM-DD.*"
RE_FILENAME=".*\.([0-9]{4}-[0-9]{2}-[0-9]{2})\..*"

# flags
FLAG_RECURSIVE=''
FLAG_TEST='false'

while getopts 'rtd:w:m:y:f:' flag; do
  case "${flag}" in
      r) FLAG_RECURSIVE='-R' ;;
      t) FLAG_TEST='true' ;;
      d) RETAIN_DAYS="${OPTARG}" ;;
      w) RETAIN_WEEKS="${OPTARG}" ;;
      m) RETAIN_MONTHS="${OPTARG}" ;;
      y) RETAIN_YEARS="${OPTARG}" ;;
      f) RE_FILENAME="${OPTARG}" ;;
      *) error "Unexpected option ${flag}" ;;
    esac
done
shift $((OPTIND-1))

# internal vars
DIR=$1
DAYS=" 07 14 21 28 "
DAYLIMIT=$(date "+%Y-%m-%d" -d "$RETAIN_DAYS days ago")
WEEKLIMIT=$(date "+%Y-%m-%d" -d "$RETAIN_WEEKS weeks ago")
MONTHLIMIT=$(date "+%Y-%m-%d" -d "$RETAIN_MONTHS months ago")
YEARLIMIT=$(date "+%Y-%m-%d" -d "$RETAIN_YEARS years ago")

cd "$DIR"

# file loop
for fn in $( ls "$DIR" )
do
    if [[ $fn =~ $RE_FILENAME ]];
    then
        DELETE=true
        FDATE=${BASH_REMATCH[1]}

        if   [[ "$FDATE" > "$DAYLIMIT" ]] ;
        then
            DELETE=false
        elif [[ "$FDATE" < "$DAYLIMIT" || "$FDATE" == "$DAYLIMIT" ]] && 
             [[ "$FDATE" > "$WEEKLIMIT" ]] &&
             [ "${DAYS/ ${FDATE:8:2} /}" != "$DAYS" ] ;
        then
             DELETE=false
         elif [[ "$FDATE" < "$WEEKLIMIT" || "$FDATE" == "$WEEKLIMIT" ]] && 
             [[ "$FDATE" > "$MONTHLIMIT" ]] &&
             [ "${FDATE:8:2}" == ${DAYS:1:2} ] ;
        then
              DELETE=false
        elif [[ "$FDATE" < "$MONTHLIMIT" || "$FDATE" == "$MONTHLIMIT" ]] &&
             [[ "$FDATE" > "$YEARLIMIT" ]] &&
             [ "${FDATE:5:2}" == '01' ] &&
             [ "${FDATE:8:2}" == ${DAYS:1:2} ] ;
        then
             DELETE=false
        fi

        if [ "$DELETE" = true ]
        then
             if [ "$FLAG_TEST" = true ]
             then
                 echo "REMOVE ${fn}"
             else
                 rm -v $FLAG_RECURSIVE $fn
             fi
        fi
    fi
done

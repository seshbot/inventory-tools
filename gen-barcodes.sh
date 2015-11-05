#!/bin/bash

HELP=FALSE
VERBOSE=FALSE
ANNOTATE=TRUE
PREFIX=
IDXFIRST=
IDXLAST=
OUTPUTFILENAME=
VECTORISE=FALSE

if [[ $# == 0 ]]; then
  HELP=TRUE
fi

TMPDIR="./tmp"
while [[ $# > 0 ]]
do
   key="$1"

   case $key in
       -p|--prefix)
       PREFIX="$2"
       shift
       ;;
       -h|--help)
       HELP=TRUE
       ;;
       -v|--verbose)
       VERBOSE=TRUE
       ;;
       -f|--first)
       IDXFIRST="$2"
       shift
       ;;
       -l|--last)
       IDXLAST="$2"
       shift
       ;;
       -n|--nolabels)
       ANNOTATE=FALSE
       ;;       
       -o)
       OUTPUTFILENAME="$2"
       shift
       ;;       
       *)
       # if its numeric, assume it is the range specifier
       if [ "$1" -eq "$1" ] 2>/dev/null; then 
          if [ "${IDXFIRST}x" = "x" ]; then
            IDXFIRST="$1"
          else
            IDXLAST="$1"
          fi
       fi
       ;;
   esac
   shift
done


function assert_command_exists {
   CMD=$1
   CMDNAME=$CMD
   if [ -n "$2" ]; then
      CMDNAME=$2
   fi

   command -v $CMD > /dev/null 2>&1
   if [ $? -eq 1 ]; then
      echo "Command '${CMD}' not found - please install ${CMDNAME}"
      exit 1
   fi
}

function run_command {
  if [ "$VERBOSE" = TRUE ]; then
    echo "$@"
  fi
  eval "$@"
  if [ $? -ne 0 ]; then
    echo "command failed!"
  fi
}

if [ "${HELP}" = "TRUE" ]; then
   echo "gen-barcodes.sh barcode sheet generation"
   echo "  this will generate a sheet full of DataMatrix barcodes in a 4x11 grid"
   echo "Usage: ./gen-barcode.sh --prefix P --first N --last L -o filename"
   echo "   -p | --prefix      prefix to use at start of each barcode generated (e.g., 10)"
   echo "   -f | --first       first barcode number in range"
   echo "   -l | --last        last barcode number in range"
   echo "   -n | --nolabels    do not add labels underneath barcodes"
   echo "   -v | --verbose     show verbose output while processing"
   echo "   -o                 set output filename"
   echo ""
   echo "e.g.:"
   echo "./gen-barcodes.sh -p S10 -f 0 -l 43"
   echo "   - this will generate 44 barcodes ranging from 100000 to 100043 into a file named 'barcodes-S10-2015-10-06.png' (depending on date)"
   exit 0
fi

if [ "${PREFIX}x" = "x" ]; then
   echo "Must specify a prefix (e.g., '--prefix 10') on command line"
   exit 1
fi

if [ "${IDXFIRST}x" = "x" -o "${IDXLAST}x" = "x" ]; then
   echo "Must specify a first and last index to use for barcode generation (e.g., -f 0 -l 20)"
   exit 1
fi

DIMS="133x70+0+0"
if [ "${ANNOTATE}" = "TRUE" ]; then
   #DIMS="143x75+0+0"
   DIMS="455x295+0+0"
   assert_command_exists "convert" "ImageMagick"
fi

assert_command_exists "dmtxwrite" "dmtx-utils"

rm ${TMPDIR}/*.png > /dev/null 2>&1
mkdir -p $TMPDIR

echo "generating individual barcodes in ${TMPDIR}..."

for IDX in `seq -f "%04g" $IDXFIRST $IDXLAST`; do
   CODE="${PREFIX}${IDX}"
   FILENAME="${TMPDIR}/${CODE}.png"

   if [ "$VERBOSE" = TRUE ]; then
      echo "generating ${FILENAME}..."
   fi

   if [ "${ANNOTATE}" = "TRUE" ]; then
      run_command "echo -n \"${CODE}\" | dmtxwrite | convert - -gravity South -splice 0x50 -extent 295x135 -bordercolor White -border 80x80 -pointsize 45 -annotate +0+50 \"KBC ${CODE}\" $FILENAME"
   else
      run_command "echo -n \"${CODE}\" | dmtxwrite -o $FILENAME"
   fi
done

assert_command_exists "montage" "ImageMagick"

FILENAME=$OUTPUTFILENAME
if [ "${OUTPUTFILENAME}x" = "x" ]; then
   SUFFIX=`date "+%Y-%m-%d"`
   FILENAME="barcodes-${PREFIX}-${SUFFIX}.png"
fi

if [[ ${OUTPUTFILENAME} = *.svg ]]; then
   if [ "${VERBOSE}" = "TRUE" ]; then
     echo "SVG requires potrace to vectorise... checking potrace is available"
   fi
   VECTORISE=TRUE
   assert_command_exists "potrace" "potrace"
fi

echo "generating montaged sheets of barcodes as ${FILENAME}..."

#TILES="4x11"
#TILES="36x52"
TILES="7x16"

if [ "${VECTORISE}" = "TRUE" ]; then
  run_command "montage \"${TMPDIR}/${PREFIX}*.png\" -tile $TILES -geometry $DIMS bmp:- | potrace -a 1 -s -o ${FILENAME}"
else
  run_command "montage \"${TMPDIR}/${PREFIX}*.png\" -tile $TILES -geometry $DIMS ${FILENAME}"
fi

echo "done."

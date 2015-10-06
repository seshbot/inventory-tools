# Inventory Management Utilities
A few tools to help with my inventory tracking system

## gen-barcodes.sh
This generates a sheet full of DataMatrix 2D barcodes given a few command line options (quite specific to my requirements)

`gen-barcodes.sh` uses the following tools:
 - `dmtxwrite` (from [dmtx-utils](https://github.com/dmtx/dmtx-utils)) to generate the DataMatrix barcodes
 - `convert` ([ImageMagick](http://www.imagemagick.org/script/index.php)) to annotate the output files with text
 - `montage` ([ImageMagick](http://www.imagemagick.org/script/index.php)) to gather the barcodes into a single page image that aligns nicely with my sticker paper

Note: in order for the text annotation to work I also had to install `ghostscript` on OSX.

```
Usage: ./gen-barcode.sh --prefix P --first N --last L -o filename
   -p | --prefix      prefix to use at start of each barcode generated (e.g., 10)
   -f | --first       first barcode number in range
   -l | --last        last barcode number in range
   -n | --nolabels    do not add labels underneath barcodes
   -v | --verbose     show verbose output while processing
   -o                 set output filename

e.g.:
./gen-barcodes.sh -p 10 -f 0 -l 43
   - this will generate 44 barcodes ranging from 100000 to 100043 into a file named 'barcodes-2015-10-06.png' (depending on date)
```

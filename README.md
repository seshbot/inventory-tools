# Inventory Management Utilities
A few tools to help with my inventory tracking system

## gen-barcodes.sh
This generates a sheet full of DataMatrix 2D barcodes given a few command line options (quite specific to my requirements)

`gen-barcodes.sh` uses the following tools:
 - `dmtxwrite` (from [dmtx-utils](https://github.com/dmtx/dmtx-utils)) to generate the DataMatrix barcodes
 - `convert` (ImageMagick) to annotate the output files with text
 - `montage` (ImageMagick) to gather the barcodes into a single page image that aligns nicely with my sticker paper

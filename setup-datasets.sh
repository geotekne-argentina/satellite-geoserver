#!/bin/bash

# Download Global levels from 0 to 10
curl "https://link.us1.storjshare.io/s/jv4zufs2kc5njqrawylqwy3aaqpq/satellite/global-0-10.zip?download=1" -o ./data/geoserver/data_dir/coverages/gpkg/global-0-10.zip
unzip -o ./data/geoserver/data_dir/coverages/gpkg/global-0-10.zip -d ./data/geoserver/data_dir/coverages/gpkg/

# Download my Selection (ie. San Marino) levels from 11 to 15
curl "https://link.us1.storjshare.io/s/jvngc4iocrvaknymv76noyztwkqa/satellite%2Fcountries%2Fsanmarino-11-to-15.zip?download=1" -o ./data/geoserver/data_dir/coverages/gpkg/sanmarino-11-to-15.zip
unzip -o ./data/geoserver/data_dir/coverages/gpkg/sanmarino-11-to-15.zip -d ./data/geoserver/data_dir/coverages/gpkg/
mv ./data/geoserver/data_dir/coverages/gpkg/sanmarino-11-to-15.gpkg ./data/geoserver/data_dir/coverages/gpkg/selection-11-to-15.gpkg

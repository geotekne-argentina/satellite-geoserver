# satellite-geoserver
Docker-compose that assembles the necessary components to implement a Geoserver instance which publishes a base map of satellite images based on tiles generated by [ESA EOX](http://maps.eox.at/).

In practice the goal of this example is to provide a global scope raster basemap structure, which:

- provide enough visual detail (spatial resolution like GoogleMaps or similar)
- can be mounted locally, without depending on external services
- is reasonably up-to-date (in terms of dates)

The assembly detailed here can be applied with different data sources. In our case we use [ESA EOX S2Maps](https://s2maps.eu/), since it allows us to obtain images with a zoom level of 15 (pixels up to 10m), providing good detail and without cloud coverage, which are generated from the dataset of the Sentinel platform - year 2020 - and that are accessible to the public at no cost.

The GPKG files used to store the tiles were compiled using [MapProxy](https://mapproxy.org/).

In next image you can see how sample app works, local base maps using different levels (selected area for levels 11 to 15 is San Marino) and remote maps working with WMS.

![showcase](./img/satellite-geoserver-optimized.gif)

## Steps

With the scripts included in the repository we have simplified the required steps to deploy a solution that includes a Geoserver instance which is publishing a set of raster layers that allow a base layer to be displayed at a global scale (with zoom levels from 0 to 10), with possibility to improve the scale on certain selected areas (zoom in levels from 11 to 15).

This simplification is conditional on the deployment being carried out specifically on the same host (on which the docker-compose that initializes the system will be executed). If you have to deploy on more than one host, you will have to consider some technical aspects (the same as moving from docker-compose to swarm or kubernetes).

The idea is to keep the use case simple (below is the diagram of containers and volumes that will be created).

The steps are:

1. Install [git](https://github.com/git-guides/install-git), [docker](https://docs.docker.com/engine/install/ubuntu/) and [docker-compose ](https://docs.docker.com/compose/install/) on the host machine.

2. Download the git repository of this project.

   to. **git clone https://github.com/geotekne-argentina/satellite-geoserver.git**

3. Download the files corresponding to the mosaic datasets/raster tiles that will be used, executing the script **./setup-datasets.sh**

4. Having finished step 3 (with the download of the datasets confirmed), execute the script **./startup.sh**

   1. **IMPORTANT: Make sure the mapped ports (80, 8080) on the host are free/available for use.**

5. Opening a browser, at http://localhost, you will find a simple test application, on which you have the option to navigate the maps of **Sentinel2 Maps** or **satellite-local**, version which points to the local server that renders the local datasets.



## Notes



- **About MAP LICENSES**:

  - The datasets that are shared depend on the licensing conditions mentioned in [s2maps.eu](https://s2maps.eu/).

  - It is suggested to review the license of use of such images in case of use in commercial systems! It is under your responsibility! (not ours)

  - In particular, the important section mentioned in the portal is the following:

    *"Feel free to use the provided service endpoints ([WMTS](https://tiles.maps.eox.at/wmts/1.0.0/WMTSCapabilities.xml) or [WMS](https://tiles.maps.eox.at/wms?service=wms&request=getcapabilities)) directly in your application. You may also download the data as rendered image mosaics directly from these services or more conveniently from our [Sentinel-2 cloudless Download Service](https://s2maps.eu/?downloadservice). Just make sure to follow the license conditions which are the attribution requirements for the corresponding year and non-commercial usage (2018, 2019 & 2020). The maximum request size is limited to 4096px, but you may stitch multiple requests to fit your needs.*

    *If you are looking for the original GeoTIFF files from 2016 instead, have a look at [this blog post](https://eox.at/2017/03/sentinel-2-cloudless-original-tiles-available/). You may download the data as source GeoTIFFs from the AWS S3 bucket eox-s2maps in the eu-central-1 region. Warning: AWS may charge you for download bandwidth"*

  - From which it follows that as long as they are not used commercially and the corresponding mentions of attribution are made, the services can be used directly (WMS or WMTS) or by downloading the tiles. In our case, the example application allows us to visualize how it connects to the service directly via WMS and also how it connects to a local server which has a copy of the tiles packed in Geopackages files (according to levels).

- **About DEMO APP:**

  - Specifically, the demo application that we attach mentions the data source, as well as it does the same in the metadata attached to the tiles rendered by Geoserver.
  - The application shows the availability of maps locally, as well as connects to the WMS services of [s2maps.eu](https://s2maps.eu/).

- **About DOWNLOADING LAYERS (Geopackages):**

  - The base layer that is published in Geoserver is in turn made up of 2 layers originating from different Geopackage-type datastores. The catalog configuration in Geoserver is defined in such a way that only files with certain names should be replaced.
  - One of the Geopackages defines the tiles for levels 0 to 10 of global coverage (this will be recognized in the ./data/geoserver/data_dir/coverages/gpkg folder with the name global-0-10.gpkg), while the other (named selection-11-to-15.gpkg) contains the tiles for levels 11 to 15.
  - The setup-datasets.sh script downloads the file for global coverage at levels 0 to 10, and the selection of tiles at scale 11 to 15, in our case having selected the Republic of San Marino (because San Marino ? "perche mi piace San Marino, simplice")
  - **NEWS !!! (2024-04-15)**: download from [this page](https://link.storjshare.io/s/jv5m557e5rc2r5yjkl6o7zmfowba/satellite/) the different GPKG for levels 11 to 15 (selection by country, not all of them covered), as well as those of global scale (from 0 to 7 and to 10 levels)
  
  

## Technical Details
- An instance of each service.

- Used images

   - geoserver: geotekne/geoserver:pear-alpine-2.16.2
   - wmsclient: nginx, which maps the simple web application (built with OpenLayers) that allows you to select between using ESA EOX as the map data source, or using the local raster basemap instance (satellite-local)

- Geoserver data volume mapped to folder on host, storing Geoserver catalog with predefined layers, etc.

- Nginx data volume mapped to folder on host (where OpenLayers app is located)

- Ports mapped on host:

   - geoserver: 8080
   - wmsclient:80
   
   

## Diagram

![](./diagram.png)

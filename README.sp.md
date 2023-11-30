# satellite-geoserver
Docker-compose que ensambla los componentes necesarios para implementar una instancia Geoserver que publica mapa base de imagenes satelitales basadas en tiles generados por [ESA EOX](http://maps.eox.at/).

En la práctica el objetivo de este ejemplo es brindar una estructura de mapa base raster de alcance global, que:

- provea suficiente detalle visual (resolución espacial del tipo GoogleMaps o similar)
- pueda montarse de forma particular, es decir local, sin depender de servicios externos
- este razonablemente actualizado (en términos de fechas)

El ensamble que aqui se detalla se puede aplicar con diferentes fuentes de datos. En nuestro caso utilizamos [ESA EOX S2Maps](https://s2maps.eu/), ya que nos permite obtener imágenes con nivel de zoom 15 (pixeles de hasta 10m), brindando buen detalle y sin cobertura de nubosidad, que son generadas a partir de dataset de la plataforma Sentinel - año 2020 - y que estan accesibles al público sin costo.

Los archivos GPKG utilizados para almacenar los tiles/teselas fueron recopilados utilizando [MapProxy](https://mapproxy.org/). 

En la siguiente imagen se puede ver como funciona la aplicación de ejemplo, los mapas locales según distintos niveles (el area seleccionada para los niveles 11 a 15 es San Marino) y los mapas remotos funcionando con WMS.

![showcase](./img/satellite-geoserver-optimized.gif)

## Pasos

Con los scripts que se incluyen en el repositorio hemos simplificado los pasos a seguir para desplegar una solución que incluye un Geoserver publicando un conjunto de capas raster que permitan visualizar una capa base a escala global (con niveles de zoom de 0 a 10), con posibilidad de mejorar la escala sobre ciertas areas seleccionadas (zoom en niveles de 11 a 15). 

Esta simplificación está condicionada a que el despliegue se realice especificamente en un mismo host (en el cual se ejecutará el docker-compose que inicializa el sistema). En caso de tener que hacer un despligue en más de un host, hay que contemplar algunos aspectos técnicos (los mismos que llevar de docker-compose a swarm o a kubernetes).

La idea es mantener el caso de uso simple (debajo esta el diagrama de contenedores y volúmenes que se crearán).

Los pasos son:

1. Instalar [git](https://github.com/git-guides/install-git), [docker](https://docs.docker.com/engine/install/ubuntu/) y [docker-compose](https://docs.docker.com/compose/install/) en la máquina host.

2. Descargar el repositorio git de este proyecto.

   a. **git clone https://github.com/geotekne-argentina/satellite-geoserver.git**

3. Descargar los archivos correspondientes a los datasets de mosaicos/teselas raster que se utilizarán, ejecutando el script **./setup-datasets.sh**

4. Habiendo finalizado el paso 3 (con la descarga de los datasets confirmada), ejecutar el script **./startup.sh**  

   1. **IMPORTANTE: asegurarse que los puertos mapeados (80, 8080) en el host están libres/disponibles para su uso.**

5. Abriendo un navegador, en http://localhost, se encontrara una aplicacion simple de testing, sobre la cual se tiene la opcion de navegar los mapas de **Sentinel2 Maps** o de **satellite-local**, versión que apunta a su servidor local que renderiza los datasets locales.

   

## Notas



- **Acerca de las LICENCIAS de MAPAS**: 

  - Los datasets que se comparten dependen de las condiciones de licenciamiento que se mencionan en [s2maps.eu](https://s2maps.eu/).

  - Se sugiere revisar licencia de uso de tales imágenes en caso de uso en sistemas comerciales! Es bajo su responsabilidad! (no la nuestra)

  - En particular la sección importante mencionada en el portal es la siguiente: 

    *"Feel free to use the provided service endpoints ([WMTS](https://tiles.maps.eox.at/wmts/1.0.0/WMTSCapabilities.xml) or [WMS](https://tiles.maps.eox.at/wms?service=wms&request=getcapabilities)) directly in your application. You may also download the data as rendered image mosaics directly from these services or more conveniently from our [Sentinel-2 cloudless Download Service](https://s2maps.eu/?downloadservice). Just make sure to follow the license conditions which are the attribution requirements for the corresponding year and non-commercial usage (2018, 2019 & 2020). The maximum request size is limited to 4096px, but you may stitch multiple requests to fit your needs.*

    *If you are looking for the original GeoTIFF files from 2016 instead, have a look at [this blog post](https://eox.at/2017/03/sentinel-2-cloudless-original-tiles-available/). You may download the data as source GeoTIFFs from the AWS S3 bucket eox-s2maps in the eu-central-1 region. Warning: AWS may charge you for download bandwidth"*

  - De la cual se desprende que en tanto no se usen comercialmente y se hagan las menciones correspondientes de atribución se pueden usar los servicios de forma directa (WMS o WMTS) o bien descargando las teselas. En nuestro caso, la aplicación de ejemplo permite visualizar como se conecta al servicio de forma directa via WMS y también como se conecta a servidor local el cual tiene una copia de las teselas empaquetadas en  archivos Geopackages (según niveles).

- **Acerca de la APLICACIÓN DEMO:** 

  - Especificamente, la aplicacion demo que adjuntamos hace mención a la fuente de datos, así como en los metadatos adjuntos a las teselas renderizadas por Geoserver, se brinda el mismo detalle.
  - La aplicación muestra la disponibilidad de mapas de forma local, así como también conecta a los servicios WMS de  [s2maps.eu](https://s2maps.eu/).

- **Acerca de la DESCARGA de CAPAS (Geopackages):**

  - La capa base que se publica en Geoserver se compone a su vez de 2 capas originadas en diferentes datastores de tipo Geopackage. La configuración del catalogo en Geoserver esta definida de forma tal que solo deben reemplazarse archivos con ciertos nombres.
  - Uno de los Geopackages define las teselas para los niveles 0 a 10 para cobertura global (este será reconocido en la carpeta ./data/geoserver/data_dir/coverages/gpkg con el nombre global-0-10.gpkg), en tanto que el otro (de nombre selection-11-to-15.gpkg) contiene las teselas para los niveles 11 a 15.
  - El script setup-datasets.sh hace la descarga del archivo para cobertura global en los niveles 0 a 10, y de la seleccion de teselas a escala 11 a 15, en nuestro caso habiendo seleccionado a la República de San Marino (porque San Marino ? "perche mi piace San Marino, semplice")
  - **Trabajo en progreso**: en esta página https://geotekne-argentina.github.io/ se publicarán los accesos a diferentes GPKG para niveles 11 a 15 (selecciones por país), así como los de escala global y otros recursos.

  

## Detalle Técnico
- Una instancia de cada servicio.

- Imagenes utilizadas
  - geoserver: geotekne/geoserver:pear-alpine-2.16.2
  - wmsclient: nginx, que mapea la aplicación web simple (creada con OpenLayers) que permite seleccionar entre utilizar ESA EOX como fuente de datos del mapa, o bien utilizando la instancia local de mapa base raster (satellite-local)
  
- Volumen de datos de Geoserver mapeado a carpeta en host, almacenando el catálogo Geoserver con capas predefinidas, etc.

- Volumen de datos de Nginx mapeado a carpeta en host (donde esta la app OpenLayers)

- Puertos mapeados en host:

  - geoserver: 8080
  - wmsclient: 80

  

## Diagrama

![](./diagram.png)

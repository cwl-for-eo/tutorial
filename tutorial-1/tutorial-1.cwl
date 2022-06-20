cwlVersion: v1.0

$graph:
- class: Workflow
  id: cropper
  label: this is a label
  doc: this is a description
  requirements: 
    - class: ScatterFeatureRequirement
    - class: MultipleInputFeatureRequirement
  inputs: 
    red_channel: 
      type: string
    green_channel: 
      type: string
    blue_channel: 
      type: string
    bbox: 
      type: string
    epsg: 
      type: string
  outputs: 
    tifs:
      outputSource:
      - node_translate/tif
      type: File[]
  steps: 
    node_translate:
      in:
        asset_href: [red_channel, green_channel, blue_channel]
        bbox: bbox
        epsg: epsg
      out:
      - tif
      run: "#translate"
      scatter: asset_href
      scatterMethod: dotproduct 

- class: CommandLineTool
  id: translate
  requirements: 
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PROJ_LIB: /srv/conda/envs/notebook/share/proj
  hints:
    DockerRequirement
      dockerPull: docker.io/osgeo/gdal:latest  
  baseCommand: 
  - gdal_translate
  arguments: 
  - -projwin 
  - valueFrom: ${ return inputs.bbox.split(",")[0]; }
  - valueFrom: ${ return inputs.bbox.split(",")[3]; }
  - valueFrom: ${ return inputs.bbox.split(",")[2]; }
  - valueFrom: ${ return inputs.bbox.split(",")[1]; }
  - -projwin_srs
  - $( inputs.epsg )
  - $( inputs.asset_href )
  - valueFrom: ${ return inputs.asset_href.split("/").slice(-1)[0]; }
  inputs:
    asset_href:
      type: string
    bbox:
      type: string
    epsg:
      type: string  
  outputs: 
    tif:
      outputBinding:
        glob: '*.tif'
      type: File
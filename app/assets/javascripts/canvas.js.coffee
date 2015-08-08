ColorCampSubscriber = ->
  this.enabled = true
  this.dispatcher = null
  this.channelName = 'all_users'
  this.subscribed_channel = null
  this.channel_svg = false
  this.reconnectIntv = null
  this.canvas = {
    offsetZ : null
    minZ : 0
    maxZ : 0
    positionOffsetZ : 0 #250
    matrixDimensions : [0,0] #y,x
    colorBoxSize : 20
    matrixHeightPct : 0.6
    particles : null
    usePointCloud : true
  }
  this.colors = []
  this.colorsMatrix = []

  # Handle dev vs production
  if window.location.hostname == 'color.camp'
    this.url = window.location.hostname + '/websocket/'
  else
    this.url = window.location.hostname + ':3001/websocket/'

  return this


jQuery.extend true, ColorCampSubscriber.prototype, {

  #
  initialize : ->
    return unless this.enabled

    $(document).ready (->
      this.canvasInitialize() if this.enabled
    ).bind(this)

  #
  uninitialize : ->
    return if this.enabled

    this.websocketUninitialize()
    this.canvasUninitialize()

  #
  enable : ->
    this.enabled = true
    this.initialize()

  #
  disable : ->
    this.enabled = false
    this.uninitialize()

  #
  setChannelName : (name)->
    this.websocketChannelUnsubscribe()
    this.channelName = name

    if this.channelName && this.dispatcher && this.dispatcher.state == 'connected'
      this.websocketChannelSubscribe()


  # --- Websocket ---

  #
  websocketInitialize : ->
    this.dispatcher = new WebSocketRails(this.url)

    this.dispatcher.bind 'connection_closed', (->
      clearTimeout this.reconnectIntv

      this.reconnectIntv = setTimeout (->
        this.dispatcher.reconnect()
      ).bind(this), 10000

    ).bind(this)

    this.dispatcher.on_open = (->
      this.websocketChannelSubscribe()
    ).bind(this)

  #
  websocketUninitialize : ->
    try
      this.websocketChannelUnsubscribe()
      if this.dispatcher.channels
        this.dispatcher.unsubscribe(k) for k,n of this.dispatcher.channels
      this.dispatcher.disconnect()
    catch e
      #

    this.dispatcher = null

  #
  websocketChannelSubscribe : ->
    this.websocketChannelUnsubscribe()
    this.subscribed_channel = this.dispatcher.subscribe this.channelName
    this.subscribed_channel.bind 'new_color', this.dataAddNewColor.bind(this)

  #
  websocketChannelUnsubscribe : ->
    try
      this.subscribed_channel.destroy()
      this.dispatcher.unsubscribe(this.channelName)
      this.subscribed_channel = null
    catch e
      #


  # --- Data ---

  #
  dataResetMatrix : ->
    this.colorsMatrix = []
    for y in [0..(this.canvas.matrixDimensions[0]-1)]
      this.colorsMatrix[y] = []
      for x in [0..(this.canvas.matrixDimensions[1]-1)]
        this.colorsMatrix[y][x] = null
    this.canvasResize()

  #
  dataIsMatrixFull : ->
    for y in [0..(this.canvas.matrixDimensions[0]-1)]
      for x in [0..(this.canvas.matrixDimensions[1]-1)]
        return false unless this.colorsMatrix[y][x]
    true

  #
  dataResizeMatrix : ->
    # Extend X
    for y in [0..(this.canvas.matrixDimensions[0]-1)]
      this.colorsMatrix[y].unshift(null)
      this.colorsMatrix[y].push(null)
    this.canvas.matrixDimensions[1] += 2

    # Extend Y
    row = []
    for x in [0..(this.canvas.matrixDimensions[1]-1)]
      row[x] = null
    this.colorsMatrix.unshift(row)
    this.colorsMatrix.push(row)

    this.canvas.matrixDimensions[0] += 2

    this.dataSetColorBoxSize()

    # Reassociate colors
    colorIds = $.map this.colors, (e)-> e.id
    for y in [0..(this.canvas.matrixDimensions[0]-1)]
      for x in [0..(this.canvas.matrixDimensions[1]-1)]
        if this.colorsMatrix[y] && this.colorsMatrix[y][x]
          i = colorIds.indexOf(this.colorsMatrix[y][x])
          if i >= 0
            this.colors[i].y += 1
            this.colors[i].x += 1

    this.canvasResize()

  #
  dataSetColorBoxSize : ->
    w = (this.canvas.element.parent().width() / Math.floor this.canvas.matrixDimensions[1])# * 0.8
    h = (this.canvas.element.parent().height() / Math.floor this.canvas.matrixDimensions[0])# * 0.8
    w = 100000 if w < 1 # Prevent 0
    h = 100000 if h < 1 # Prevent 0
    this.canvas.colorBoxSize = Math.min w, h, this.canvas.colorBoxSize

  #
  dataGetEmptyMatrixPosition : ->
    id = Math.ceil(Math.random() * 1000)
    i = 0
    while true
      i++
      y = Math.floor(Math.random() * this.canvas.matrixDimensions[0])
      x = Math.floor(Math.random() * this.canvas.matrixDimensions[1])
      return {x : x, y : y} unless this.colorsMatrix[y][x]
      if i > 10
        i = 0
        this.dataResizeMatrix() 

  #
  dataAssignCoords : ->
    # Resize matrix if the matrix is full
    this.dataResizeMatrix() if this.dataIsMatrixFull()

    # Loop through each color, set if not x & y coords
    $.each this.colors, ((i,n)->
      unless n.x && n.y
        pos = this.dataGetEmptyMatrixPosition()
        return this unless pos
        this.colorsMatrix[pos.y][pos.x] = n.id
        this.colors[i].x = pos.x
        this.colors[i].y = pos.y
        this.colors[i].z = (Date.parse(n.created_at) - this.canvas.offsetZ) / 1000 / 60
    ).bind(this)

  #
  dataAddNewColor : (color)->
    this.dataPrependColors [color]
    this.canvasDrawColors() if this.canvas.scene

    if typeof this.colors[1] != 'undefined'
      x = this.canvas.camera.position.x
      y = this.canvas.camera.position.y
      z = this.canvas.camera.position.z + this.colors[0].z - this.colors[1].z

      new TWEEN.Tween( this.canvas.camera.position ).to( { z: z, x : x, y : y }, 250 ).start();

  #
  dataLoadColors : (colors)->
    if colors
      $.each colors, ((i,v) ->
        this.colors[i] = v
      ).bind(this)
      this.canvasSetOffsets()
      this.dataAssignCoords()

      this.canvasDrawColors() if this.canvas.scene

  #
  dataAppendColors : (colors) ->
    Array.prototype.push.apply(this.colors, colors)
    this.dataAssignCoords()

  #
  dataPrependColors : (colors) ->
    Array.prototype.unshift.apply(this.colors, colors)
    this.dataAssignCoords()
    this.canvas.step_index += colors.length


  # --- Canvas ---

  #
  canvasInitialize : ->
    this.canvasUninitialize() # for clarify

    return unless $('canvas.colorcamp-canvas').size() > 0
    this.canvas.element = $('canvas.colorcamp-canvas').eq(0)

    w = this.canvas.element.parent().width()
    h = this.canvas.element.parent().height()

    this.canvas.scene = new THREE.Scene()
    # this.canvas.scene.fog = new THREE.Fog 0xffffff, 1, 10000

    this.canvas.camera = new THREE.PerspectiveCamera 25, w / h, 1, 86400
    this.canvas.camera.position.set 0, 0, 3600

    this.canvas.renderer = new THREE.WebGLRenderer { canvas: this.canvas.element.get(0) }
    this.canvas.renderer.setClearColor 0xFFFFFF, 1
    this.canvas.renderer.setPixelRatio window.devicePixelRatio
    this.canvas.renderer.setSize w, h

    this.canvas.raycaster = new THREE.Raycaster()

    this.canvas.mouse = new THREE.Vector2()
    this.canvas.matrixDimensions = [6,10]#[24,36] #y,x
    this.dataResetMatrix()
    this.dataSetColorBoxSize()
    this.canvasDrawColors()

    $(document)
      .on 'mousemove', this.canvasEventMousemove.bind(this)
      # .on 'keydown', this.canvasEventKeypress.bind(this)
    $(window).on 'resize', this.canvasResize.bind(this)

    this.canvasAnimate()

  #
  canvasUninitialize : ->
    try 
      $(document)
        .off 'mousemove', this.canvasEventMousemove.bind(this)
        # .off 'keydown', this.canvasEventKeypress.bind(this)
      $(window).off 'resize', this.canvasResize.bind(this)
    catch err
      #

    this.canvas.scene = null
    this.colors = []
    this.colorsMatrix = []


  #
  canvasAnimate : ->
    this.canvasRender()
    # setTimeout (->
    requestAnimationFrame( this.canvasAnimate.bind(this) )
    # ).bind(this), 60

  #
  canvasRender : ->
    this.canvas.lastCameraX = this.canvas.camera.position.x
    this.canvas.camera.position.x += ( this.canvas.mouse.x - this.canvas.camera.position.x ) * 0.05

    if !this.canvas.lastCameraX || this.canvas.lastCameraX != this.canvas.camera.position.x
      if this.canvas.scene
        this.canvas.camera.lookAt(this.canvas.scene.position)
        this.canvas.renderer.render this.canvas.scene, this.canvas.camera

  #
  canvasResize : (e)->
    # Reset canvas size and aspect ration
    w = this.canvas.element.parent().width()
    h = this.canvas.element.parent().height()
    this.canvas.camera.aspect = w / h
    this.canvas.renderer.setSize w, h

    # Resize the vFOV to 
    matrixHeight = (this.canvas.matrixDimensions[0] * this.canvas.colorBoxSize) / this.canvas.matrixHeightPct
    fov = (2 * Math.atan( matrixHeight / ( 2 * this.canvas.camera.position.z - this.canvas.closestZ ) ) ) * (180 / Math.PI)
    this.canvas.camera.fov = fov

    # Update the projection
    this.canvas.camera.updateProjectionMatrix()

  #
  canvasSetOffsets : ->
    # Store offset positions
    this.canvas.offsetZ = Date.parse this.colors[0].created_at
    this.canvas.closestZ = (Date.parse(this.colors[0].created_at) - this.canvas.offsetZ) / 1000 / 60

  #
  canvasDrawColors : ->
    # Items
    this.canvas.scene.remove this.canvas.particles
    return unless this.colors.length > 0

    if this.canvas.usePointCloud
      this.canvas.geometry = new THREE.Geometry()
      this.canvas.particleColors = []
      this.canvasDrawColorPointCloud(color,i) for i,color of this.colors
      this.canvas.geometry.colors = this.canvas.particleColors

      sprite = THREE.ImageUtils.loadTexture 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgAAAAIABAMAAAFxUflfAAAAJ1BMVEX8/Pz7+/v8/Pz9/f39/f3+/v79/f3+/v7////+/v7////+/v7///+579fpAAAAC3RSTlP3+Pj4/Pz9/f3+/lvbVvIAAAOTSURBVHja7d09TjJRFIDhMyT2rMAQWxs6W5dAQ8ciWABLcAkuwaWwBsIOtFQIYGEm/sJoRrky57mF8fu8nLw+CgxxgOpsFBHRG8RFvF3bZSwiIqKaTOPgsuF4G2ajP99wOzyBDXcDGyKimocNv7MhyS/MEa6bR7iNcnfwfzaM48vjh0XUxw9uYWywwQYbbLDBhh8eYIQBBhjwvQFNj5xOYEDT48sMA5oexhuQY8A8DDCgEwNcnTsxoAN3rh04RnKoa4ABLwPGb/7RG9Qf9q3tsv5QX8S9swEGGGCAAQYYYIABBhhggAEGGGCAAQYYYIABBhhggAEGGGCAAQYYcHMdRVfrMygECBAgQIAAAQIECBBw+gFtn2UgQICA1gFtn68kQIAAAa0D2j73U4AAAQIECBBw+gHzECBAgAABAgQIEJA9wFGxAAECBAjwBws/AgECigc4h0SAACc0ChAgQIAAAQIECBBQPKD4n2zG+77y+j4IB98R4eBafPHZ+7UpLVA84EmAAAECBAgQIECAAAECBAgQIECAAAECBAhIH7AWIECAAAECBKQPcP6AAAECBAgQIECAAAECBAgQIGAnQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQKczCZAgAABAgQIECBAgAABXgZEQPqAlQC/hK4FAtIHPAoQIECAAAECBAgQIECAAAECBAgQIECAgNIBUTyg9Kom09Tf/xMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADQvbUGMBsBAAAAAAAAAAAAAAAAAIBsa1PdDgEAAAAAAAAAAAAAAAAAAAAAAADkArgbAAAAAAAAAAAAAAAAAACAbGsHAAAAAAAAAAAAAAAAAAAAAACQDyD5Gy4CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALoM4FRZAAAAAAAAAAAAAAAAAAAAAECy5cXUAAAAAABAagDvMDF0FQAAwG0AAAAAAAAAAAAAAAAAsgHMRgAAJF5rAAAApAZYAQDgNgAAgNS3AZMpAAAA8q5HAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJ0FSP86QlfnP7tE7wPYxYevV/37qPq/1bd7aNqx+Pxf22Xzxerv5vIZgbMGZM6EZtYAAAAASUVORK5CYII='
      size = this.canvas.colorBoxSize * (this.canvas.matrixDimensions[1] + 1)

      material = new THREE.PointCloudMaterial { size: size, map: sprite, vertexColors: THREE.VertexColors, alphaTest: 0, transparent: true}
      this.canvas.particles = new THREE.PointCloud this.canvas.geometry, material

    else
      this.canvas.particles = new THREE.Group()
      this.canvasDrawColor(color,i) for i,color of this.colors

    this.canvas.scene.add this.canvas.particles

  #
  canvasDrawColorPointCloud : (color,i)->
    vertex = new THREE.Vector3()
    vertex.x = (color.x - Math.floor(this.canvas.matrixDimensions[1] / 2)) * this.canvas.colorBoxSize
    vertex.y = (color.y - Math.floor(this.canvas.matrixDimensions[0] / 2)) * this.canvas.colorBoxSize
    vertex.z = color.z
    this.canvas.geometry.vertices.push vertex
    this.canvas.particleColors[ i ] = new THREE.Color parseInt(color.color.hex, 16)

  #
  canvasDrawColor : (color,i)->
    # Set and load material
    hexColor = parseInt(color.color.hex, 16)
    material = new THREE.MeshBasicMaterial { color: hexColor, transparent: false }
    geometry = new THREE.BoxGeometry( this.canvas.colorBoxSize, this.canvas.colorBoxSize, .1 )

    colorMesh = new THREE.Mesh geometry, material
    colorMesh.id = color.id
    colorMesh.position.x = (color.x - Math.floor(this.canvas.matrixDimensions[1] / 2)) * this.canvas.colorBoxSize
    colorMesh.position.y = (color.y - Math.floor(this.canvas.matrixDimensions[0] / 2)) * this.canvas.colorBoxSize
    colorMesh.position.z = color.z

    colorMesh.matrixAutoUpdate = false
    colorMesh.updateMatrix()

    # Add to canvas
    this.canvas.particles.add colorMesh


  #
  canvasEventMousemove : (e)->
    this.canvas.mouse.x = (2 * e.clientX) - (window.innerWidth)

  #
  canvasEventKeypress : (e)->
    # if e.keyCode == 38 || e.keyCode == 40 # Up
    #   e.preventDefault()
    #   this.canvasMoveZ e

  #
  canvasMoveZ : (e) ->
    return

}



document.colorCamp = new ColorCampSubscriber

$ ->

  # TODO : FIX W/ MESSAGING
  # if chrome.app.isInstalled || !navigator.userAgent.match(/Chrome\//)
  #   $('.extension-install.chrome').hide()
  # else
  #   $('.extension-install.chrome a').on 'click', ->
  #     chrome.webstore.install('https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca', ->
  #       console.log('Installed', arguments)
  #     , ->
  #       console.log('Unable to install', arguments)
  #     )
  #     return false
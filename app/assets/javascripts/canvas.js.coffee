ColorCampSubscriber = ->
  this.debug = true
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

    this.canvas.camera = new THREE.PerspectiveCamera 20, w / h, 1, 86400
    this.canvas.camera.position.set 0, 0, 3600

    this.canvas.renderer = new THREE.WebGLRenderer { canvas: this.canvas.element.get(0) }
    this.canvas.renderer.setClearColor 0xFFFFFF, 1
    this.canvas.renderer.setPixelRatio window.devicePixelRatio
    this.canvas.renderer.setSize w, h

    this.canvas.raycaster = new THREE.Raycaster()
    this.canvas.raycaster.params.PointCloud.threshold = 10

    this.canvas.mousePan = new THREE.Vector2()
    this.canvas.mouse = new THREE.Vector2()

    this.canvas.matrixDimensions = [6,10]#[24,36] #y,x
    this.dataResetMatrix()
    this.dataSetColorBoxSize()
    this.canvasDrawColors()

    if this.debug
      this.canvas.spheres = []
      this.canvas.spheresIndex = 0
      sphereGeometry = new THREE.SphereGeometry 8,32,32
      sphereMaterial = new THREE.MeshBasicMaterial { color: 0xff0000, shading: THREE.FlatShading }
      sphere = new THREE.Mesh sphereGeometry, sphereMaterial
      sphere.position.z = 1
      this.canvas.scene.add sphere
      this.canvas.spheres.push sphere
    

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
    requestAnimationFrame( this.canvasAnimate.bind(this) )
    this.canvasRender()

  #
  canvasRender : ->
    # this.canvas.lastCameraX = this.canvas.camera.position.x
    # this.canvas.camera.position.x += ( this.canvas.mousePan.x - this.canvas.camera.position.x ) * 0.05

    if this.canvas.particles
      this.canvas.raycaster.setFromCamera this.canvas.mouse, this.canvas.camera

      intersections = this.canvas.raycaster.intersectObjects [ this.canvas.particles ]

      intersection = if intersections.length > 0
        intersections[ 0 ]
      else

      if intersection && intersection.index >= 0
        if !this.currentIntersection || this.currentIntersection.index != intersection.index
          this.currentIntersection = intersection

          # show site name
          $(window).trigger 'colorcamp:raycast:change', this.colors[ this.currentIntersection.index ]

          if this.debug
            x = this.currentIntersection.object.geometry.attributes.position.array[ this.currentIntersection.index * 3 ]
            y = this.currentIntersection.object.geometry.attributes.position.array[ this.currentIntersection.index * 3 + 1 ]
            z = this.currentIntersection.object.geometry.attributes.position.array[ this.currentIntersection.index * 3 + 2 ]
            this.canvas.spheres[ this.canvas.spheresIndex ].position.setX x
            this.canvas.spheres[ this.canvas.spheresIndex ].position.setY y
            this.canvas.spheres[ this.canvas.spheresIndex ].position.setZ z + 10
            this.canvas.spheres[ this.canvas.spheresIndex ].scale.set 1, 1, 1

      else
        $(window).trigger 'colorcamp:raycast:change', null

        if this.debug
          this.canvas.spheres[ this.canvas.spheresIndex ].scale.set .1, .1, .1
        

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

    # Update the projection
    this.canvas.camera.updateProjectionMatrix()
    this.canvas.renderer.setSize w, h

    # Resize the vFOV to 
    matrixHeight = (this.canvas.matrixDimensions[0] * this.canvas.colorBoxSize) / this.canvas.matrixHeightPct
    fov = (2 * Math.atan( matrixHeight / ( 2 * this.canvas.camera.position.z - this.canvas.closestZ ) ) ) * (180 / Math.PI)
    this.canvas.camera.fov = fov



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
      this.canvas.geometry = new THREE.BufferGeometry()
      this.canvas.particlePositions = new Float32Array this.colors.length * 3
      this.canvas.particleColors = new Float32Array this.colors.length * 3

      this.canvasDrawColorPointCloud(color,i) for i,color of this.colors
      this.canvas.geometry.addAttribute 'position', new THREE.BufferAttribute( this.canvas.particlePositions, 3 )
      this.canvas.geometry.addAttribute 'color', new THREE.BufferAttribute( this.canvas.particleColors, 3 )
      this.canvas.geometry.computeBoundingBox()

      size = this.canvas.colorBoxSize * (this.canvas.matrixDimensions[1] + 1)

      material = new THREE.PointCloudMaterial { size: size, vertexColors: THREE.VertexColors }
      this.canvas.particles = new THREE.PointCloud this.canvas.geometry, material
      this.canvas.particles.scale.set(1,1,1)
      this.canvas.particles.position.set(0,0,0)

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

    this.canvas.particlePositions[ i * 3 ] = vertex.x
    this.canvas.particlePositions[ i * 3 + 1 ] = vertex.y
    this.canvas.particlePositions[ i * 3 + 2 ] = vertex.z

    this.canvas.particleColors[ i * 3 ] = color.color.rgb[0] / 255
    this.canvas.particleColors[ i * 3 + 1 ] = color.color.rgb[1] / 255
    this.canvas.particleColors[ i * 3 + 2 ] = color.color.rgb[2] / 255

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
    this.canvas.mousePan.x = (2 * e.clientX) - (window.innerWidth)
    this.canvas.mouse.x = ( e.clientX / this.canvas.element.width() ) * 2 - 1
    # Normalize because canvas is not full height of window
    this.canvas.mouse.y = -( Math.max(0, e.clientY - this.canvas.element.offset().top) / this.canvas.element.height() ) * 2 + 1
    this.canvas.mouse.z = 0.5

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
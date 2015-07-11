ColorCampSubscriber = ->
  this.enabled = true
  this.dispatcher = null
  this.channelName = 'all_users'
  this.subscribed_channel = null
  this.channel_svg = false
  this.reconnectIntv = null
  this.canvas = {
    step_z : 10
    step_index : 0
    offsetZ : null
  }
  this.colors = []

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

    this.websocketInitialize()
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
      this.dispatcher.unsubscribe(k) for k,n of this.dispatcher.channels
      this.dispatcher.disconnect()
    catch e
      #

    this.dispatcher = null

  #
  websocketChannelSubscribe : ->
    this.subscribed_channel = this.dispatcher.subscribe this.channelName
    this.subscribed_channel.bind 'new_color', ((data)->
      this.dataAddNewColor(data)
    ).bind(this)


  # --- Data ---

  #
  dataAssignCoords : (colors, startN) ->
    return if !colors || colors.length == 0

    startX = 0
    startY = 0
    startX = this.colors[startN].x if startN && this.colors[startN]
    startY = this.colors[startN].y if startN && this.colors[startN]

    # Set an offset if not already
    this.canvas.offsetZ = Date.parse colors[0].created_at unless this.canvas.offsetZ
    offsetZ = this.canvas.offsetZ

    $.map colors, (n,i)->
      return this if n.x && n.y
      incrX = Math.ceil(Math.random() * 100) - 50
      n.x = incrX if !n.x

      incrY = Math.ceil(Math.random() * 100) - 50
      n.y = incrY if !n.y

      n.z = (Date.parse(n.created_at) - offsetZ) / 100 / 60

      return this

    colors

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
    colors = this.dataAssignCoords(colors, this.colors.length)
    $.each colors, ((i,v) ->
      this.colors[i] = v
    ).bind(this)

    this.canvasDrawColors() if this.canvas.scene

  #
  dataAppendColors : (colors) ->
    colors = this.dataAssignCoords(colors, this.colors.length)
    Array.prototype.push.apply(this.colors, colors)

  #
  dataPrependColors : (colors) ->
    colors = this.dataAssignCoords(colors.reverse(), 0).reverse() # reverse the order and then back
    Array.prototype.unshift.apply(this.colors, colors)
    this.canvas.step_index += colors.length


  # --- Canvas ---

  #
  canvasInitialize : ->
    this.canvasUninitialize() # for clarify

    if ($('canvas#colorcamp-canvas').size() > 0)
      this.canvas.element = $('canvas#colorcamp-canvas').eq(0)
    else
      this.canvas.element = $('<canvas></canvas>').attr('id', 'colorcamp-canvas')
      $('body').append this.canvas.element

    this.canvas.scene = new THREE.Scene()

    this.canvas.camera = new THREE.PerspectiveCamera 45, window.innerWidth / window.innerHeight, 1, 3000
    this.canvas.camera.position.set 0, 0, 250

    this.canvas.renderer = new THREE.WebGLRenderer { canvas: this.canvas.element.get(0) }
    this.canvas.renderer.setClearColor 0xFFFFFF, 1
    this.canvas.renderer.setPixelRatio( window.devicePixelRatio )
    this.canvas.renderer.setSize( window.innerWidth, window.innerHeight )

    this.canvas.mouse = new THREE.Vector2()

    this.canvasDrawColors()

    document.body.appendChild( this.canvas.renderer.domElement )

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
    $('canvas#colorcamp-canvas').remove()

  #
  canvasAnimate : ->
    this.canvasRender()
    setTimeout (->
      requestAnimationFrame( this.canvasAnimate.bind(this) )
    ).bind(this), 120 # ~30 fps

  #
  canvasRender : ->
    this.canvas.renderer.render this.canvas.scene, this.canvas.camera
    TWEEN.update()

  #
  canvasResize : (e)->
    this.canvas.camera.aspect = window.innerWidth / window.innerHeight
    this.canvas.renderer.setSize( window.innerWidth, window.innerHeight )
    this.canvas.camera.updateProjectionMatrix()

  #
  canvasDrawColors : ->
    this.canvas.scene.remove this.canvas.particles

    geometry = new THREE.Geometry
    geometryColors = []
    for i,color of this.colors
      vertex = new THREE.Vector3()
      vertex.x = color.x
      vertex.y = color.y
      vertex.z = color.z
      geometry.vertices.push( vertex );
      geometryColors[i] = new THREE.Color parseInt(color.color.hex, 16)

    geometry.colors = geometryColors

    material = new THREE.PointCloudMaterial { size: 50, vertexColors: THREE.VertexColors }

    this.canvas.particles = new THREE.PointCloud geometry, material
    this.canvas.scene.add this.canvas.particles

  #
  canvasEventMousemove : (e)->
    # e.preventDefault()
    # this.canvas.mouse.x = e.clientX - (window.innerWidth / 2)
    # this.canvas.mouse.y = - (e.clientY - (window.innerHeight / 2))

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

  # Start
  document.colorCamp.initialize()


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
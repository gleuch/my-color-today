ColorCampSubscriber = ->
  this.enabled = true
  this.dispatcher = null
  this.channel_name = 'all_users'
  this.subscribed_channel = null
  this.channel_svg = false
  this.reconnectIntv = null
  this.canvas = {
    step_z : 10
    step_index : 0
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
    this.subscribed_channel = this.dispatcher.subscribe this.channel_name
    this.subscribed_channel.bind 'new_color', (data)->
      console.log('new color', data)
      $(window).trigger 'color:update'


  # --- Data ---

  #
  dataAssignCoords : (colors, startN) ->
    startX = 0
    startY = 0
    startX = this.colors[startN].x if this.colors[startN]
    startY = this.colors[startN].y if this.colors[startN]

    # For now, linear
    # TODO : CURVE IT
    # incrX = Math.ceil(Math.random() * 100) - 50
    # incrY = Math.ceil(Math.random() * 100) - 50

    $.map colors, (n,i)->
      return this if n.x && n.y

      incrX = Math.ceil(Math.random() * 10) - 5
      n.x = startX + (incrX * i) if !n.x

      incrY = Math.ceil(Math.random() * 10) - 5
      n.y = startY + (incrY * i) if !n.y
      return this

    colors

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

    this.canvas.element = $('<canvas></canvas>').attr('id', 'colorcamp-canvas')
    $('body').append this.canvas.element

    this.canvas.scene = new THREE.Scene()

    this.canvas.camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 3000 )
    this.canvas.camera.position.set( 0, 0, 150 )

    this.canvas.renderer = new THREE.WebGLRenderer({ alpha: true, canvas: this.canvas.element.get(0) })
    this.canvas.renderer.setPixelRatio( window.devicePixelRatio )
    this.canvas.renderer.setSize( window.innerWidth, window.innerHeight )

    this.canvas.mouse = new THREE.Vector2()

    this.canvasDrawColors()

    this.canvas.renderer.setSize( window.innerWidth, window.innerHeight )
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
    return unless this.canvas.scene
    requestAnimationFrame( this.canvasAnimate.bind(this) )
    this.canvasRender()

  #
  canvasRender : ->
    this.canvas.camera.position.x += ( this.canvas.mouse.x - this.canvas.camera.position.x ) * 0.05;
    this.canvas.camera.position.y += ( - this.canvas.mouse.y - this.canvas.camera.position.y ) * 0.05;
    this.canvas.camera.lookAt this.canvas.scene.position
    this.canvas.renderer.render this.canvas.scene, this.canvas.camera

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
      vertex.z = - this.canvas.step_z * (parseInt(i) + 1)
      geometry.vertices.push( vertex );
      geometryColors[i] = new THREE.Color parseInt(color.color.hex, 16)

    geometry.colors = geometryColors

    material = new THREE.PointCloudMaterial { size: 85, vertexColors: THREE.VertexColors, alphaTest: 0.5, transparent: true }

    this.canvas.particles = new THREE.PointCloud geometry, material
    this.canvas.scene.add this.canvas.particles

  #
  canvasEventMousemove : (e)->
    e.preventDefault()
    this.canvas.mouse.x = e.clientX - (window.innerWidth / 2)
    this.canvas.mouse.y = - (e.clientY - (window.innerHeight / 2))

  #
  canvasEventKeypress : (e)->
    if e.keyCode == 38 || e.keyCode == 40 # Up
      e.preventDefault()
      this.canvasMoveZ e

  #
  canvasMoveZ : (e) ->
    return
    # i = 1
    # i = 10 if e.shiftKey # Skip 10 at time if shiftkey pressed
    # oldStep = this.canvas.step_index + 0
    #
    # if e.keyCode == 38 # Up
    #   this.canvas.step_index += i if (this.colors.length - 1) > this.canvas.step_index
    # else if e.keyCode == 40
    #   this.canvas.step_index -= i if this.canvas.step_index > 0
    #
    # # Normalize
    # this.canvas.step_index = Math.min((this.colors.length - 1), Math.max(0, this.canvas.step_index))
    #
    # z = - this.canvas.step_z * this.canvas.step_index
    # y = this.colors[this.canvas.step_index].y
    # x = this.colors[this.canvas.step_index].x
    #
    # console.log this.canvas.step_index, '--', z, y, x
    #
    # # new TWEEN.Tween( this.canvas.camera.position ).to( { z: z, x : x, y : y }, 250 ).start();
}



document.colorCamp = new ColorCampSubscriber

$ ->

  # Start
  document.colorCamp.initialize()


  # TODO : FIX W/ MESSAGING
  if chrome.app.isInstalled || !navigator.userAgent.match(/Chrome\//)
    $('.extension-install.chrome').hide()
  else
    $('.extension-install.chrome a').on 'click', ->
      chrome.webstore.install('https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca', ->
        console.log('Installed', arguments)
      , ->
        console.log('Unable to install', arguments)
      )
      return false
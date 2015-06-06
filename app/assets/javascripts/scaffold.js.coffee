ColorCampSubscriber = ->
  this.enabled = true
  this.dispatcher = null
  this.channel_name = 'all_users'
  this.subscribed_channel = null
  this.channel_svg = false
  this.reconnectIntv = null
  this.canvas = {
    step_z : 1
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
      console.log(data)
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
    incrX = Math.ceil(Math.random() * 100) - 50
    incrY = Math.ceil(Math.random() * 100) - 50

    $.map colors, (n,i)->
      n.x = startX + (incrX * i) if !n.x
      n.y = startY + (incrY * i) if !n.y
      return this

    colors

  #
  dataLoadColors : (colors)->
    colors = this.dataAssignCoords(colors, this.colors.length)
    $.each colors, ((i,v) ->
      this.colors[i] = v
    ).bind(this)

    this.canvasUpdateColors() if this.canvas.scene

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
    this.canvas.camera = new THREE.PerspectiveCamera( 70, window.innerWidth / window.innerHeight, .1, 100000 )
    this.canvas.renderer = new THREE.WebGLRenderer({ alpha: true, canvas: this.canvas.element.get(0) })
    this.canvas.mouse = new THREE.Vector2()

    this.canvas.geometry = new THREE.BoxGeometry( 100, 75, 1 )
    this.canvas.geometry.computeBoundingBox()
    this.canvas.geometry.width = this.canvas.geometry.boundingBox.max.x - this.canvas.geometry.boundingBox.min.x
    this.canvas.geometry.height = this.canvas.geometry.boundingBox.max.y - this.canvas.geometry.boundingBox.min.y
    this.canvas.geometry.depth = this.canvas.geometry.boundingBox.max.z - this.canvas.geometry.boundingBox.min.z

    this.canvas.camera.position.y = 0
    this.canvas.camera.position.z = 0

    this.canvasUpdateColors()

    this.canvas.renderer.setSize( window.innerWidth, window.innerHeight )
    document.body.appendChild( this.canvas.renderer.domElement )

    $(document)
      .on 'mousemove', this.canvasEventMousemove.bind(this)
      .on 'keydown', this.canvasEventKeypress.bind(this)
    $(window).on 'resize', this.canvasResize.bind(this)

    this.canvasAnimate()

  #
  canvasUninitialize : ->
    try 
      $(document)
        .off 'mousemove', this.canvasEventMousemove.bind(this)
        .off 'keydown', this.canvasEventKeypress.bind(this)
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
    this.canvas.renderer.render this.canvas.scene, this.canvas.camera
    TWEEN.update()

  #
  canvasResize : (e)->
    this.canvas.camera.aspect = window.innerWidth / window.innerHeight
    this.canvas.camera.updateProjectionMatrix()
    this.canvas.renderer.setSize( window.innerWidth, window.innerHeight )

  #
  canvasUpdateColors : ->
    # Items
    this.canvas.scene.remove this.canvas.queue
    this.canvas.queue = new THREE.Group()
    this.canvasDrawColor(n,i) for i,n of this.colors
    this.canvas.camera.position.z = -this.canvas.step_z * this.canvas.step_index

    this.canvas.scene.add this.canvas.queue

    # Timeline
    # this.canvas.scene.remove this.canvas.timeline
    # this.canvas.timeline = new THREE.Group()
    # # DRAW TIMELINE
    # this.canvas.scene.add this.canvas.timeline

    # this.changeBackground() if this.colors.length > 0
   
  #
  canvasDrawColor : (color,i)->
    # Set and load material
    hexColor = parseInt(color.color.hex, 16)
    material = new THREE.MeshBasicMaterial {color: hexColor, transparent: false}
    geometry = new THREE.BoxGeometry( 10, 10, .1 )

    colorMesh = new THREE.Mesh geometry, material
    # colorMesh.id = color.id
    colorMesh.position.set color.x, color.y, ( -this.canvas.step_z * (i + 1) )
    colorMesh.matrixAutoUpdate = false
    colorMesh.updateMatrix()

    # Add to canvas
    this.canvas.queue.add colorMesh

  #
  canvasEventMousemove : (e)->
    e.preventDefault()
    this.canvas.mouse.x = ( e.clientX / window.innerWidth ) * 2 - 1
    this.canvas.mouse.y = - ( e.clientY / window.innerHeight ) * 2 + 1

  #
  canvasEventKeypress : (e)->
    if e.keyCode == 38 || e.keyCode == 40 # Up
      e.preventDefault()
      this.canvasMoveZ e

  #
  canvasMoveZ : (e) ->
    i = 1
    i = 10 if e.shiftKey # Skip 10 at time if shiftkey pressed
    oldStep = this.canvas.step_index + 0

    if e.keyCode == 38 # Up
      this.canvas.step_index += i if (this.colors.length - 1) > this.canvas.step_index
    else if e.keyCode == 40
      this.canvas.step_index -= i if this.canvas.step_index > 0

    # Normalize
    this.canvas.step_index = Math.min((this.colors.length - 1), Math.max(0, this.canvas.step_index))

    z = -this.canvas.step_z * this.canvas.step_index
    y = this.colors[this.canvas.step_index].y
    x = this.colors[this.canvas.step_index].x

    # this.changeBackground() unless oldStep == this.canvas.step_index

    new TWEEN.Tween( this.canvas.camera.position ).to( { z: z, x : x, y : y }, 250 ).start();
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
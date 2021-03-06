@ColorCampScreenshot = ->
  this.format = 'image/png'
  this.canvas = null
  this.context = null
  this.rendered = false
  this.retries = 0
  this.padding = 
    top : 64
    bottom : 72
    left : 64
    right : 64
  this.framing = 
    top : 54
    bottom : 96
    left : 0
    right : 0
  this.minWidth = 1024
  this.minHeight = 768
  this.fontName = 'Oscine, Arial'


  return this


jQuery.extend true, ColorCampScreenshot.prototype, {

  generate : (content, channel, date)->
    # Setup the canvas
    this.canvas = document.createElement 'canvas'
    this.context = this.canvas.getContext '2d'
    this.canvas.width = content.width
    this.canvas.height = content.height

    # Add background
    this.addImageContent content

    # Trim, resize, scale
    this.trim()

    # Add context
    this.addTextContent(date, channel)

    return this

  setFormat : (format)->
    this.format = format

  open : (callback)->
    # Retry if not rendered
    unless this.rendered
      return if this.retries < (15 / .25)
        this.retries++
        setTimeout( (->
          this.open callback
        ).bind(this), 250 )
      else
        alert 'Sorry, this image took longer than expected to generate. Please try again.'
        callback.call() if callback

    image = this.canvas.toDataURL()
    win = window.open image, '_blank'
    win.focus()
    callback.call() if callback
    
  download : (fname, callback)->
    # Retry if not rendered
    unless this.rendered
      return if this.retries < (15 / .25)
        this.retries++
        setTimeout( (->
          this.download fname, callback
        ).bind(this), 250 )
      else
        alert 'Sorry, this image took longer than expected to generate. Please try again.'
        callback.call() if callback

    # Get blob, then send as attachment
    this.canvas.toBlobHD( ((blob)->
      saveAs(blob, fname)
      callback.call() if callback
    ).bind(this), this.format )

  addImageContent : (content)->
    this.context.drawImage content, 0, 0, this.canvas.width, this.canvas.height

  addTextContent : (date, channel)->
    extraOffset = 0

    this.context.fillStyle = '#1E1E1E'
    this.context.textAlign = 'right'

    if channel.sites && channel.pages
      extraOffset = 30
      this.context.fillStyle = '#1E1E1E'
      this.context.textAlign = 'right'
      this.context.font =  '24px ' + this.fontName
      this.context.fillText channel.pages + '  /  ' + channel.sites, this.canvas.width - this.padding.right, this.canvas.height - this.padding.bottom

    this.context.font = 'bold 24px Arial'
    this.context.fillText date, this.canvas.width - this.padding.right, this.canvas.height - this.padding.bottom - extraOffset

    this.context.font = '20px ' + this.fontName
    this.context.textAlign = 'right'
    this.context.fillStyle = 'rgba(20,20,20,0.82)'
    this.context.fillText 'https://mycolor.today', this.canvas.width - this.padding.right, this.canvas.height - this.padding.bottom + 42

    # Add channel name, avatar, and watermark
    leftOffset = 0
    if channel.avatar
      imgWidth = 64
      leftOffset = imgWidth + 18
      this.context.fillStyle = 'rgba(20,20,20,0.3)'
      this.context.fillRect this.padding.left, this.canvas.height - this.padding.bottom - imgWidth, imgWidth, imgWidth
      _t = this
      img = new Image()
      img.onload = ->
        _t.context.drawImage this, _t.padding.left, _t.canvas.height - _t.padding.bottom - imgWidth, imgWidth, imgWidth
        _t.rendered = true
      img.onerror = ->
        _t.rendered = true
      img.src = channel.avatar
    else
      this.rendered = true

    this.context.font = 'bold 42px ' + this.fontName
    this.context.fillStyle = '#1E1E1E'
    this.context.textAlign = 'left'
    this.context.fillText channel.name.toLowerCase(), this.padding.left + leftOffset, this.canvas.height - this.padding.bottom - 20

  trim : ->
    pix =
      x : []
      y : []

    # Trim transparent area
    imageData = this.context.getImageData 0, 0, this.canvas.width, this.canvas.height
    for y in [0...this.canvas.height]
      for x in [0...this.canvas.width]
        index = (y * this.canvas.width + x) * 4;
        if imageData.data[index + 3] > 0
          pix.x.push x
          pix.y.push y

    pix.x.sort (a,b)-> a-b
    pix.y.sort (a,b)-> a-b
    n = pix.x.length - 1

    w = pix.x[n] - pix.x[0]
    h = pix.y[n] - pix.y[0]
    cut = this.context.getImageData pix.x[0], pix.y[0], w, h

    # Resize canvas with padding, put trimmed area onto canvas, ensure at least min width and height
    this.canvas.width = Math.max this.minWidth, w + this.padding.left + this.padding.right + this.framing.left + this.framing.right
    this.canvas.height = Math.max this.minHeight, h + this.padding.top + this.padding.bottom + this.framing.top + this.framing.bottom
    mx = (this.canvas.width - w) / 2
    my = (this.canvas.height - h) / 3.3
    this.context.putImageData cut, mx, my

    # Add background
    this.context.globalCompositeOperation = 'destination-over'
    this.context.fillStyle = '#FFFFFF'
    this.context.fillRect 0, 0, this.canvas.width, this.canvas.height
    this.context.globalCompositeOperation = 'source-over'

}
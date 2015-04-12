ColorCampSubscriber = ->
  this.dispatcher = null
  this.subscribed_channel = null
  this.channel_svg = false
  this.reconnectIntv = null

  if window.location.hostname == 'color.camp'
    this.url = window.location.hostname + '/websocket/'
  else
    this.url = window.location.hostname + ':3001/websocket/'

  this.connect()

  return this

jQuery.extend true, ColorCampSubscriber.prototype, {
  connect : ->
    _t = this

    _t.dispatcher = new WebSocketRails(_t.url);

    _t.dispatcher.bind 'connection_closed', ->
      clearTimeout _t.reconnectIntv
      _t.reconnectIntv = setTimeout ->
        _t.dispatcher.reconnect()
      , 10000

    _t.dispatcher.on_open = ->
      _t.channelSubscribe()

  channelSubscribe : ->
    _t = this

    if $('#page-colors-list[data-channel]').size() > 0
      _t.channel_svg = $('#page-colors-list').get(0).tagName == 'svg'

      _t.subscribed_channel = _t.dispatcher.subscribe( $('#page-colors-list[data-channel]').attr('data-channel') )
      _t.subscribed_channel.bind 'new_color', (data)->
        return unless data.id

        unless $('.color[data-uuid="' + data.id + '"]').size() > 0
          if _t.channel_svg
            el = $('<stop/>').attr('stop-color', '#' + data.color.hex)

          else
            eli = $('<div></div>').addClass('color-info').html(data.page.domain_tld + ' -  #' + data.color.hex)
            el = $('<li></li>')
            el.append(eli)

          el.addClass('color').attr('data-rgb-color', data.color.rgb).attr('data-uuid', data.id).attr('data-url', data.page.url).attr('title', data.page.url)
          if channel_svg
            $('#page-color-gradient').prepend(el)
          else
            $('#page-colors-list').prepend(el)

          $(window).trigger 'color:update'

}

$ ->

  window.colorCamp = new ColorCampSubscriber


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

$ ->

  if window.location.hostname == 'color.camp'
    window.colorWebSocket = new WebSocketRails( window.location.hostname + '/websocket' )
  else
    window.colorWebSocket = new WebSocketRails( window.location.hostname + ':3001/websocket' )

  if $('#page-colors-list[data-channel]').size() > 0
    channel = window.colorWebSocket.subscribe( $('#page-colors-list[data-channel]').attr('data-channel') )
    channel_svg = $('#page-colors-list').get(0).tagName == 'svg'

    channel.bind 'new_color', (data)->
      return unless data.id

      unless $('.color[data-uuid="' + data.id + '"]').size() > 0
        if channel_svg
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


  # Set color
  $(window).on 'color:update', ->
    if $('svg#page-colors-list').size() > 0
      p = $('svg#page-colors-list')
      ct = p.find('stop.color').size()
      $('stop.color').each (i)->
        $(this).attr('offset', (100 * (i / (ct - 1))) + '%')
      p.parent().html(p.parent().html())
    else
      $('.color[data-rgb-color]').each ->
        $(this).css 'background-color', 'rgb(' + $(this).data('rgb-color') + ')'
  .trigger 'color:update'
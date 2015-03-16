
$ ->

  window.colorWebSocket = new WebSocketRails( window.location.hostname + ':3001/websocket' )

  if $('#page-colors-list[data-channel]').size() > 0
    channel = window.colorWebSocket.subscribe( $('#page-colors-list[data-channel]').attr('data-channel') )
    channel.bind 'new_color', (data)->
      return unless data.id

      unless $('.color[data-uuid="' + data.id + '"]').size() > 0
        el = $('<li></li>').addClass('color').attr('data-rgb-color', data.color.rgb).attr('data-uuid', data.id).attr('data-url', data.page.url).attr('title', data.page.url)
        eli = $('<div></div>').addClass('color-info').html(data.page.domain_tld + ' -  #' + data.color.hex)
        $('#page-colors-list').prepend(el.append(eli))

        $(window).trigger 'color:update'


  # Set color
  $(window).on 'color:update', ->
    $('.color[data-rgb-color]').each ->
      $(this).css 'background-color', 'rgb(' + $(this).data('rgb-color') + ')'
  .trigger 'color:update'
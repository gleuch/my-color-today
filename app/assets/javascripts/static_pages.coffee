
$ ->

  window.colorWebSocket = new WebSocketRails( window.location.hostname + ':3001/websocket')

  if $('#web-site-page-colors').size() > 0
    channel = window.colorWebSocket.subscribe('all_users')
    channel.bind 'new_color', (data)->
      return unless data.id

      unless $('.color[data-uuid="' + data.id + '"]').size() > 0
        el = $('<div></div>').addClass('color').attr('data-rgb-color', data.color.rgb).attr('data-uuid', data.id).attr('data-url', data.page.url).html(data.page.domain_tld)
        $('#web-site-page-colors').prepend(el)

        $(window).trigger 'color:update'


  # Set color
  $(window).on 'color:update', ->
    $('.color[data-rgb-color]').each ->
      $(this).css 'background-color', 'rgb(' + $(this).data('rgb-color') + ')'
  .trigger 'color:update'
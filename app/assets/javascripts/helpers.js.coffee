String.prototype.possessiveify = ->
  if this.match(/s$/)
    this + "'"
  else
    this + "'s"



Number.prototype.delimited = (d)->
  n = this + ''
  d = d || ','
  s = n.split '.'
  s[0] = s[0].replace /(\d)(?=(\d\d\d)+(?!\d))/g, '$1' + d
  s.join '.'


@TrackEvent =
  track : (a,b,c,d)->
    (e)->
      ga 'send', 'event', a, b, c, d
  link : (a,b)->
    (e)->
      ga 'send', 'event', 'OutboundLink', a, e.currentTarget.href, b

@TrackPageView = React.createClass
  render : ->
    try
      ga('send', 'pageview', this.props.page) if this.props.page
    catch e
      #
    null

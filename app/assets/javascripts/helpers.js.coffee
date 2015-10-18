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
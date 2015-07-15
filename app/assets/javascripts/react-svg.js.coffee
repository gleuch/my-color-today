# Simple hack to fetch and store SVGs in an object for quick caching
@ColorCampSvgs =
  add : (key,src,target)->
    _t = this
    obj = {}

    if this[src]
      obj[key] = this[src]
      target.setState obj
    else
      $.ajax src,
        success : ((d,s,x)->
          if d && d.documentElement
            this[src] = $(d).find('svg').get(0).outerHTML 
            obj[key] = this[src]
            target.setState obj
        ).bind(this)
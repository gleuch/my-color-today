@ColorCanvasUserDetail = React.createClass
  render : ->
    React.DOM.section {id : 'user-profile', className : 'details-container'},
      React.DOM.div { className : 'avatar' },
        React.DOM.img {src: this.props.user.avatar_medium_url, alt: '', title: this.props.user.name}
      React.DOM.div { className : 'info' },
        React.DOM.h3 { }, this.props.user.name
    

@ColorCanvasUserContent = React.createClass
  render : ->
    unless this.props.user.profile_private
      React.DOM.section { },
        React.DOM.h3 { }, 'Today: XXX pages (#HEX)'
    else
      React.DOM.section { },
        React.DOM.div { className : 'well'},
          React.DOM.p { className : 'text-center' }, 'This user has made their account private.'


@ColorCanvasSiteDetail = React.createClass
  render : ->
    React.DOM.section { id : 'site-profile', className : 'details-container' },
      React.DOM.div { className : 'avatar' },
        '[icon]'
        # React.DOM.img {src: this.props.site.avatar_medium_url, alt: '', title: this.props.user.name}
      React.DOM.div { className : 'info' },
        React.DOM.h3 { }, this.props.site.name


@ColorCanvasEveryoneDetail = React.createClass
  render : ->
    React.DOM.section { },
      React.DOM.div { className : 'info' },
        React.DOM.h3 { }, 'Everyone'


@ColorCanvas = React.createClass
  getInitialState : ->
    {
      channel :     this.props.channel
      channelInfo : this.props.channelInfo
      url :         this.props.url
      viewType :    this.props.viewType
    }

  componentDidMount : ->
    $(window).bind 'colorcamp:channel', this.handleEvent
    $(window).trigger 'colorcamp:colorcanvas:mounted', {}

    if this.state.url
      this.getChannelData()
    else
      document.colorCamp.disable()

  componentWillUnmount : ->
    $(window).unbind 'colorcamp:channel', this.handleEvent

  componentWillUpdate : ->
    #

  componentDidUpdate : (p,s)->
    if s.url != this.state.url
      this.getChannelData()

  handleEvent : (e,data)->
    this.setState {viewType : data.viewType, url : data.url, channel : data.channel}

  getChannelData : ->
    $.ajax this.state.url, {
      dataType : 'json'
      method : 'GET'
      success : ((d,s,x)->
        if d && !d.errors
          this.setState {
            channel : d.channel,
            channelInfo : d.channelInfo
            url : d.url
            viewType : d.viewType
          }

          if d.viewType == 'user' && d.channelInfo.profile_private
            document.colorCamp.disable()
          else
            document.colorCamp.enable()
            if this.state.viewType == 'everyone'
              document.colorCamp.channelName = this.state.channel
            else
              document.colorCamp.channelName = this.state.viewType + '-' + this.state.channel
            document.colorCamp.dataLoadColors d.colors
      ).bind(this)
      error : ((x,s,e) ->
        #
      ).bind(this)
    }

  render : ->
    unless this.state.channelInfo
      document.colorCamp.disable()
      return React.DOM.span {}, ''

    details = ''
    content = ''

    if this.state.viewType == 'user'
      details = `<ColorCanvasUserDetail user={this.state.channelInfo} />`
      content = `<ColorCanvasUserContent user={this.state.channelInfo} />`
    else if this.state.viewType == 'state'
      details = `<ColorCanvasSiteDetail site={this.state.channelInfo} />`
      # content = `<ColorCanvasSiteContent site={this.state.channelInfo} />`
    else if this.state.viewType == 'everyone'
      details = `<ColorCanvasEveryoneDetail />`

    React.DOM.div { }, 
      details
      content
      React.DOM.canvas {id: 'colorcamp-canvas'}, ''
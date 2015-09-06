@ColorChannelUserDetail = React.createClass
  render : ->
    img = '[icon]'
    if this.props.user.avatar_medium_url
      img = `<img src={this.props.user.avatar_medium_url} alt="" title={this.props.user.name} />`

    `<section className="details-container user-profile">
      <div className="avatar">
        {img}
      </div>
      <div className="info">
        <h3>{this.props.user.name}</h3>
      </div>
    </section>`
    

@ColorChannelUserContent = React.createClass
  render : ->
    unless this.props.user.profile_private
      `<section>
        <h3>Today: XXX pages (#HEX)</h3>
      </section>`
    else
      `<section>
        <div className="well">
          <p className="text-center">This user has made their account private.</p>
        </div>
      </section>`


@ColorChannelSiteDetail = React.createClass
  render : ->
    img = '[icon]'
    # React.DOM.img {src: this.props.site.avatar_medium_url, alt: '', title: this.props.user.name}

    `<section className="details-container site-profile">
      <div className="avatar">
        {img}
      </div>
      <div className="info">
        <h3>{this.props.site.name}</h3>
      </div>
    </section>`


@ColorChannelEveryoneDetail = React.createClass
  render : ->
    `<section className="details-container everyone">
      <div className="info">
        <h3>Everyone</h3>
      </div>
    </section>`


@ColorChannelPagination = React.createClass
  render : ->
    nextLink = if this.props.nextUrl
      `<a className="paginate older" href={this.props.nextUrl} onClick={this.nextPage}>Older</a>`
    else
      `<span className="paginate older">Older</span>`

    prevLink = if this.props.prevUrl
      `<a className="paginate newer" href={this.props.prevPage} onClick={this.prevPage}>Newer</a>`
    else
      `<span className="paginate newer">Newer</span>`

    `<div className="timeline">
      <div className="timeline-content">
        {nextLink}
        <span> </span>
        {prevLink}
      </div>
    </div>`


  # --- HELPER METHODS ---

  prevPage : (e)->
    e.preventDefault()
    this.props.paginateCanvas(this.props.prevUrl)

  nextPage : (e)->
    e.preventDefault()
    this.props.paginateCanvas(this.props.nextUrl)


@ColorCanvas = React.createClass
  shouldComponentUpdate : (p,s)->
    false

  render : ->
    `<section className="colorcamp-canvas-area">
      <canvas className="colorcamp-canvas" />
    </section>`


@ColorUserChannel = React.createClass
  getInitialState : ->
    current_user : this.props.current_user
    channel:
      channel : this.props.params.id
      viewType : 'user'
      url : location.href

  render : ->
    `<ColorChannel {...this.state} />`


@ColorEveryoneChannel = React.createClass
  getInitialState : ->
    current_user : this.props.current_user
    channel:
      channel : 'all_users'
      viewType : 'everyone'
      url : location.href

  render : ->
    `<ColorChannel {...this.state} />`


@ColorChannelRaycastInfo = React.createClass
  getInitialState : ->
    raycast : null

  componentDidMount : ->
    $(window).on 'colorcamp:raycast:change', this.updateRaycastData

  render : ->
    return `<span />` unless this.state.raycast
    `<p>{this.state.raycast.site}</p>`

  # --- HELPER METHODS ---

  updateRaycastData : (e,data)->
    this.setState { raycast : data }



@ColorChannel = React.createClass
  getInitialState : ->
    {
      channel :     this.props.channel.channel
      channelInfo : this.props.channel.channelInfo
      url :         this.props.channel.url
      nextUrl :     null
      prevUrl :     null
      viewType :    this.props.channel.viewType
      visible :     true
    }

  getDefaultProps : ->
    channel : { }

  componentDidMount : ->
    if this.state.url
      this.getChannelData()

  componentWillUnmount : ->
    #

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    if s.url != this.state.url
      this.getChannelData()
    else if this.state.channelInfo && this.state.visible
      unless this.state.viewType == 'user' && this.state.channelInfo.profile_private
        document.colorCamp.enable()

  render : ->
    if !this.state.channelInfo || !this.state.visible
      document.colorCamp.disable()
      return `<span></span>`

    details = ''
    content = ''
    timeline = ''

    timeline = `<ColorChannelPagination prevUrl={this.state.prevUrl} nextUrl={this.state.nextUrl} paginateCanvas={this.paginateCanvas} />`

    if this.state.viewType == 'user'
      details = `<ColorChannelUserDetail user={this.state.channelInfo} />`
      content = `<ColorChannelUserContent user={this.state.channelInfo} />`
    else if this.state.viewType == 'state'
      details = `<ColorChannelSiteDetail site={this.state.channelInfo} />`
      # content = `<ColorChannelSiteContent site={this.state.channelInfo} />`
    else if this.state.viewType == 'everyone'
      details = `<ColorChannelEveryoneDetail />`

    `<div>
      {details}
      {content}
      {timeline}
      <ColorChannelRaycastInfo />
      <ColorCanvas />
    </div>`


  # --- HELPER METHODS ---

  openChannel : (e,data)->
    this.setState { viewType : data.viewType, url : data.url, channel : data.channel, visible : true }

  closeChannel : (e,data)->
    unless data.except && data.except == 'channel'
      this.setState { visible : false }

  paginateCanvas : (url)->
    this.setState { url : url }

  getChannelData : (url)->
    this.setState {
      prevUrl : null
      nextUrl : null
    }

    $.ajax url || this.state.url, {
      dataType : 'json'
      method : 'GET'
      success : ((d,s,x)->
        if d && !d.errors
          try
            p = JSON.parse x.getResponseHeader('X-Pagination')
          catch
            p = { prev_url : null, next_url : null }

          this.setState {
            channel : d.channel,
            channelInfo : d.channelInfo
            prevUrl : p.prev_url
            nextUrl : p.next_url
            viewType : d.viewType
          }

          if d.viewType == 'user' && d.channelInfo.profile_private
            document.colorCamp.disable()

          else
            channelName = if this.state.viewType == 'everyone'
              this.state.channel
            else
              this.state.viewType + '-' + this.state.channel

            document.colorCamp.enable()
            document.colorCamp.setChannelName channelName
            document.colorCamp.dataLoadColors d.colorData

            # Listen for new colors via websocket if only if today
            today = (new Date()).toJSON().replace(/^(\d{4}\-\d{2}\-\d{2})(.*)$/, '$1')
            if today == d.date
              document.colorCamp.websocketInitialize()
            else
              document.colorCamp.websocketUninitialize()

      ).bind(this)
      error : ((x,s,e) ->
        #
      ).bind(this)
    }
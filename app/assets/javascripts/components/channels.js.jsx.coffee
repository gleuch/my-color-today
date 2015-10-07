@ColorChannelUserContent = React.createClass
  render : ->
    img = ''
    if this.props.user.avatar_medium_url
      img = `<span><img src={this.props.user.avatar_medium_url} alt="" title={this.props.user.name} /></span>`

    color = ''
    if this.props.report && this.props.report.hex
      style = { backgroundColor : '#' + this.props.report.hex }
      color = `<span>
        <span>&nbsp; / &nbsp;</span>
        <em><i className="color-block" style={style}></i> #{this.props.report.hex}</em>
      </span>`

    ago = ''
    agoPrefix = ''
    agoTime = moment(this.props.user.registered_date).fromNow(true)
    agoPrefix = 'over' if agoTime.match /day|month|year/i
    ago = `<h3>visualizing <span className="hidden-xs">their browsing history</span> for {agoPrefix} {agoTime}</h3>`

    `<header className="channel-heading">
      <h1>
        {img}
        <span>{this.props.user.name.toLowerCase()}</span>
        {color}
      </h1>
      {ago}
    </header>`
    

@ColorChannelSiteContent = React.createClass
  render : ->
    color = ''
    if this.props.report && this.props.report.hex
      style = { backgroundColor : '#' + this.props.report.hex }
      color = `<span>
        <span>&nbsp; / &nbsp;</span>
        <em><i className="color-block" style={style}></i> #{this.props.report.hex}</em>
      </span>`

    `<header className="channel-heading">
      <h1>
        <span>{this.props.site.name}'s color</span>
        {color}
      </h1>
    </header>`


@ColorChannelEveryoneContent = React.createClass
  render : ->
    color = ''
    if this.props.report && this.props.report.hex
      style = { backgroundColor : '#' + this.props.report.hex }
      color = `<span>
        <span>&nbsp; / &nbsp;</span>
        <em><i className="color-block" style={style}></i> #{this.props.report.hex}</em>
      </span>`

    link = if this.props.current_user
      `<ColorLink to={"/u/" + this.props.current_user.login}>see yours</ColorLink>`
    else
      `<ColorLink to="/signup">add yours!</ColorLink>`

    `<header className="channel-heading">
      <h1>
        <span>everyone's color</span>
        {color}
      </h1>
      <h3>a visual display of a collective browsing history. {link}</h3>
    </header>`


@ColorChannelDetail = React.createClass
  render : ->
    date = if this.props.date then new Date(this.props.date) else new Date()
    date = moment(date).format('ddd, DD MMM YYYY').toLowerCase()

    report = `<p>&nbsp;</p>`
    if this.props.report
      pages = this.props.report.pages_count + ' web page'
      pages = pages + 's' unless pages == 1
      sites = this.props.report.sites_count + ' web site'
      sites = sites + 's' unless sites == 1

      report = `<p>
        <span>{pages}</span>
        <span>&nbsp; / &nbsp;</span>
        <span>{sites}</span>
      </p>`


    `<section className="channel-details">
      <h3>{date}</h3>
      {report}
    </section>`


@ColorChannelPagination = React.createClass
  render : ->
    # nextLink = if this.props.nextUrl
    #   `<a className="paginate older" href={this.props.nextUrl} onClick={this.nextPage}>Older</a>`
    # else
    #   `<span className="paginate older">Older</span>`

    # prevLink = if this.props.prevUrl
    #   `<a className="paginate newer" href={this.props.prevPage} onClick={this.prevPage}>Newer</a>`
    # else
    #   `<span className="paginate newer">Newer</span>`

    nextLink = ''
    prevLink = ''
    options = `<a href="javascript:;" onClick={this.props.screenshot}>png</a>`

    `<aside className="channel-options">
      {nextLink}
      {options}
      {prevLink}
    </aside>`


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


@ColorSiteChannel = React.createClass
  getInitialState : ->
    current_user : this.props.current_user
    channel:
      channel : this.props.params.id
      viewType : 'site'
      url : location.href

  render : ->
    `<ColorChannel {...this.state} />`


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


@ColorChannel = React.createClass
  getInitialState : ->
    {
      channel :     this.props.channel.channel
      channelInfo : this.props.channel.channelInfo
      date :        this.props.date
      url :         this.props.channel.url
      report :      this.props.report
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

    content = ''
    canvas = `<ColorCanvas />`
    details = `<ColorChannelDetail {...this.state} />`
    options = `<ColorChannelPagination screenshot={this.onScreenshot} prevUrl={this.state.prevUrl} nextUrl={this.state.nextUrl} paginateCanvas={this.paginateCanvas} />`

    if this.state.viewType == 'user'
      content = `<ColorChannelUserContent {...this.state} user={this.state.channelInfo} />`
      if this.state.channelInfo.profile_private
        content = `<ColorChannelUserContent user={this.state.channelInfo} />`
        details = ''
        canvas = `<section>
          <div className="well">
            <p className="text-center">This user has made their account private.</p>
          </div>
        </section>`
    else if this.state.viewType == 'site'
      content = `<ColorChannelSiteContent {...this.state} site={this.state.channelInfo} />`
    else if this.state.viewType == 'everyone'
      content = `<ColorChannelEveryoneContent {...this.state} />`

    `<article className="channel">
      {details}
      {content}
      {options}
      {canvas}
    </article>`


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

    jsonUrl = url || this.state.url
    if this.state.channel == 'all_users'
      jsonUrl = jsonUrl + 'everyone'

    $.ajax( jsonUrl + '.json', {
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
            date : d.date
            prevUrl : p.prev_url
            nextUrl : p.next_url
            viewType : d.viewType
            report : d.report
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
    })

  onScreenshot : (e)->
    e.preventDefault()

    visible = this.state.visible
    date = 'today'

    channel = 
      name : ''
      avatar : null
      color : null
      sites : 0
      pages : 0

    switch this.state.viewType
      when 'everyone'
        channel.name = 'Everyone'
        fname = 'everyone-' + date + '.png'

      when 'user'
        visible = false if this.state.channelInfo.profile_private

        channel.name = this.state.channelInfo.name
        channel.avatar = this.state.channelInfo.avatar_small_url
        fname = this.state.channelInfo.login + '-' + date + '.png'

      # when 'site'
      #   channel.name = 'Site'
      #   fname = 'site-' + date + '.png'

      else
        visible = false # dunno what this is, so exports are not allowed

    unless visible
      alert 'This channel is not visible or is protected.'
      return

    screenshot = new window.ColorCampScreenshot
    screenshot.generate( document.colorCamp.canvasContext(), channel, date ).download fname
@ColorInitialProps ||= {}

@ColorApp = React.createClass
  contextTypes :
    router : React.PropTypes.func

  getInitialState : ->
    current_user : this.props.current_user || ColorInitialProps.current_user
    signin_providers : this.props.signin_providers || ColorInitialProps.signin_providers
    channel : this.props.channel || ColorInitialProps.channel

  getDefaultProps : ->
    current_user : ColorInitialProps.current_user
    signin_providers : ColorInitialProps.signin_providers
    channel : ColorInitialProps.channel

  componentDidMount : ->
    #

  componentWillUnmount : ->
    #

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    name = this.context.router.getCurrentPath()
    key = name.replace(/^\//, '').replace(/\//, '-') || 'root'

    getTheBook = ''
    getTheBook = `
      <aside className="get-the-book">
        <div>
          <p>
            Buy the book now!
            <br/>
            <a href={ColorInitialProps.links.books.lulu} target="_blank" className="book-link lulu" onClick={TrackEvent.track('PurchaseBook','Lulu','Layout:CornerBanner')}>Paperback</a> or <a href={ColorInitialProps.links.books.lulu_ebook} target="_blank" className="book-link lulu" onClick={TrackEvent.track('PurchaseBook','LuluEbook','Layout:CornerBanner')}>PDF</a>
          </p>
        </div>
      </aside>` unless this.props.current_user || key.match(/^about|signup|login$/)

    `<div className="container">
      <ColorHeader {...this.state} />
      {getTheBook}
      <div id="wrapper">
        <div id="container">
          <div id="content" className="container-fluid">
            <TimeoutTransitionGroup enterTimeout={500} leaveTimeout={500} transitionName="screen">
              <TrackPageView page={this.context.router.getCurrentPath()} />
              <ColorRouteHandler key={key} {...this.state} />
            </TimeoutTransitionGroup>
            <div className="clearfix"></div>
          </div>
        </div>
      </div>
    </div>`

  # --- HELPER METHODS ---

  #


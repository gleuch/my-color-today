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

    `<div className="container">
      <ColorHeader {...this.state} />
      <div id="wrapper">
        <div id="container">
          <div id="content" className="container-fluid">
            <TimeoutTransitionGroup enterTimeout={500} leaveTimeout={500} transitionName="screen">
              <ColorRouteHandler key={key} {...this.state} />
            </TimeoutTransitionGroup>
            <div className="clearfix"></div>
          </div>
        </div>
      </div>
    </div>`

  # --- HELPER METHODS ---

  #


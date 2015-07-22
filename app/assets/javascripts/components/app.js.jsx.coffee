@ColorInitialProps ||= {}


@ColorApp = React.createClass
  getInitialState : ->
    {
      current_user : this.props.current_user || ColorInitialProps.current_user
      signin_providers : this.props.signin_providers || ColorInitialProps.signin_providers
      channel : this.props.channel || ColorInitialProps.channel
    }

  getDefaultProps : ->
    {
      current_user : ColorInitialProps.current_user
      signin_providers : ColorInitialProps.signin_providers
      channel : ColorInitialProps.channel
    }

  componentDidMount : ->
    #

  componentWillUnmount : ->
    #

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    `<div className="container">
      <ColorHeader {...this.state} />
      <div id="wrapper">
        <div id="container">
          <div id="content" className="container-fluid">
            <ColorRouteHandler {...this.state} />
            <div className="clearfix"></div>
          </div>
        </div>
      </div>
    </div>`

  # --- HELPER METHODS ---

  #


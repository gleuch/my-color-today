@ColorInitialProps ||= {}

@ColorApp = React.createClass
  getInitialState : ->
    {
      current_user : this.props.current_user || ColorInitialProps.current_user
      signup_providers : this.props.signup_providers || ColorInitialProps.signup_providers
      channel : this.props.channel || ColorInitialProps.channel
    }

  getDefaultProps : ->
    {
      current_user : ColorInitialProps.current_user
      signup_providers : ColorInitialProps.signup_providers
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
            <ColorCanvas />
            <div className="clearfix"></div>
          </div>
        </div>
      </div>
    </div>`

  # --- HELPER METHODS ---

  #

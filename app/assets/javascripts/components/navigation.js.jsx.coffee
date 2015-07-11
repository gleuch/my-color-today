@Header = React.createClass
  getInitialState : ->
    current_user : this.props.current_user

  componentDidMount : ->
    $(window).bind 'colorcamp:current_user:change', this.currentUserChange

  componentWillUnmount : ->
    $(window).unbind 'colorcamp:current_user:change', this.currentUserChange

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    links = []
    links.push( React.DOM.li { }, (React.DOM.a { href : '/', onClick : this.loadHome }, 'Color Camp') )

    # Logged-in user
    if this.state.current_user
      links.push( React.DOM.li null, (React.DOM.a { href : '/u/' + this.state.current_user.login, onClick : this.loadProfile }, 'Your Profile') )
      links.push( React.DOM.li null, (React.DOM.a { href : '/settings', onClick : this.loadSettings }, 'Settings') )

    # Guest user
    else
      links.push( React.DOM.li null, (React.DOM.a { href : '/signup' }, 'Signup') )
      links.push( React.DOM.li null, (React.DOM.a { href : '/login' }, 'Login') )

    # Chrome install URL
    links.push( React.DOM.li { className : 'extension-install chrome'}, (React.DOM.a { href : 'https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca', target : '_blank' }, 'Install') )
    
    # Return HTML
    React.DOM.header { id : 'header' }, 
      React.DOM.ul {}, {links}


  # --- HELPER METHODS ---

  loadHome : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:channel', { viewType: 'everyone', url: '/', channel: 'all_users' }

  loadProfile : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:channel', { viewType: 'user', url: '/u/' + this.state.current_user.login, channel: this.state.current_user.id }

  loadSettings : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:settings:open', {}

  loadLogin : (e)->
    #

  loadSignup : (e)->
    #

  currentUserChange : (e,data)-> 
    this.setState { current_user : data.current_user }

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
    links.push( React.DOM.li { }, (React.DOM.a { href : '/', onClick : this.loadHomeChannel }, 'Color Camp') )

    # Logged-in user
    if this.state.current_user
      links.push( React.DOM.li null, (React.DOM.a { href : '/u/' + this.state.current_user.login, onClick : this.loadProfileChannel }, 'Your Profile') )
      links.push( React.DOM.li null, (React.DOM.a { href : '/settings', onClick : this.loadSettingsModal }, 'Settings') )

    # Guest user
    else
      links.push( React.DOM.li null, (React.DOM.a { href : '/signup', onClick : this.loadSignupModal }, 'Signup') )
      links.push( React.DOM.li null, (React.DOM.a { href : '/login', onClick : this.loadLoginModal }, 'Login') )

    # Chrome install URL
    links.push( React.DOM.li { className : 'extension-install chrome'}, (React.DOM.a { href : 'https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca', target : '_blank' }, 'Install') )
    
    # Return HTML
    React.DOM.header { id : 'header' }, 
      React.DOM.ul {}, {links}


  # --- HELPER METHODS ---

  loadHomeChannel : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:channel', { viewType: 'everyone', url: '/', channel: 'all_users' }

  loadProfileChannel : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:channel', { viewType: 'user', url: '/u/' + this.state.current_user.login, channel: this.state.current_user.id }

  loadSettingsModal : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:settings:open', {}

  loadLoginModal : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:signuplogin:open', { signup : false }

  loadSignupModal : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:signuplogin:open', { signup : true }

  currentUserChange : (e,data)-> 
    this.setState { current_user : data.current_user }

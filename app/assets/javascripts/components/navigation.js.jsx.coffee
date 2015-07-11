@Header = React.createClass
  getInitialState : ->
    current_user : this.props.current_user

  render : ->
    links = []

    # Logged-in
    if this.state.current_user
      links.push( React.DOM.li null, (React.DOM.a { href : '/u/' + this.state.current_user.login }, 'Your Profile') )
      links.push( React.DOM.li null, (React.DOM.a { href : '/settings' }, 'Settings') )

    # Guest
    else
      links.push( React.DOM.li null, (React.DOM.a { href : '/signup' }, 'Signup') )
      links.push( React.DOM.li null, (React.DOM.a { href : '/login' }, 'Login') )

    # Chrome install URL
    links.push( React.DOM.li { className : 'extension-install chrome'}, (React.DOM.a { href : 'https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca', target : '_blank' }, 'Install') )
    
    # Return HTML
    React.DOM.header { id : 'header' }, 
      React.DOM.ul {}, {links}

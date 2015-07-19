@ColorHeader = React.createClass
  render : ->
    links = [
      `<li><ColorLink to="/">Color Camp</ColorLink></li>`
    ]

    # Logged-in user
    if this.props.current_user
      links.push `<li><ColorLink to={'/u/' + this.props.current_user.login}>Your Profile</ColorLink></li>`
      links.push `<li><ColorLink to="/settings">Settings</ColorLink></li>`

    # Guest user
    else
      links.push `<li><ColorLink to="/signup">Signup</ColorLink></li>`
      links.push `<li><ColorLink to="/login">Login</ColorLink></li>`

    # Chrome install URL
    links.push( React.DOM.li { className : 'extension-install chrome'}, (React.DOM.a { href : 'https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca', target : '_blank' }, 'Install') )
    
    # Return HTML
    `<header id="header">
      <ul>{links}</ul>
    </header>`

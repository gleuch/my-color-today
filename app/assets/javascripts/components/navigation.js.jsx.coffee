@ColorHeader = React.createClass
  getInitialState : ->
    visible : false

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
    links.push `<li><ColorLink to="/about">About</ColorLink></li>`
    links.push `<li className="extension-install chrome"><a href="https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca" target="_blank">Install</a></li>`

    visibleClassName = ''
    visibleClassName = 'opened' if this.state.visible

    # Return HTML
    `<header id="header">
      <div id="header-links" className={visibleClassName}>
        <a href="javascript:;" className="toggle-menu" onClick={this.toggleVisibility}>
          ==
        </a>
        <ul>{links}</ul>
      </div>
    </header>`


  # --- HELPERS ---

  toggleVisibility : ->
    this.setState { visible : !this.state.visible }
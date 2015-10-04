@ColorHeader = React.createClass
  getInitialState : ->
    visible : false
    menuSvg : null

  componentDidMount : ->
    window.ColorCampSvgs.add('menuSvg', '/assets/menu.svg', this) unless this.state.menuSvg

  render : ->
    links = []

    links.push `<li key="install"><ColorLink onClick={this.closeMenu} to="/install">install</ColorLink></li>`
    links.push `<li key="about"><ColorLink onClick={this.closeMenu} to="/about">about</ColorLink></li>`

    # Logged-in user
    if this.props.current_user
      links.push `<li key="settings"><ColorLink onClick={this.closeMenu} to="/settings">settings</ColorLink></li>`
      links.push `<li key="profile"><ColorLink onClick={this.closeMenu} to={'/u/' + this.props.current_user.login}>your profile</ColorLink></li>`

    # Guest user
    else
      links.push `<li key="signup"><ColorLink onClick={this.closeMenu} to="/signup">signup / login</ColorLink></li>`

    # Home
    links.push `<li key="home"><ColorLink onClick={this.closeMenu} to="/">everyone's colors</ColorLink></li>`

    visibleClassName = ''
    visibleClassName = 'opened' if this.state.visible

    menuSvg = ''
    if this.state.menuSvg
      menuSvg = `<span dangerouslySetInnerHTML={{__html : this.state.menuSvg }} />`

    # Return HTML
    `<header id="header">
      <h1><ColorLink to="/">what color is your internet?</ColorLink></h1>
      <nav id="header-links" className={visibleClassName}>
        <a href="javascript:;" className="toggle-menu" onClick={this.toggleVisibility}>{menuSvg}</a>
        <ul>{links}</ul>
      </nav>
    </header>`


  # --- HELPERS ---

  closeMenu : ->
    this.setState { visible : false }

  toggleVisibility : ->
    this.setState { visible : !this.state.visible }
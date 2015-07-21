@ColorStaticPageDisplay = React.createClass
  getInitialState : ->
    { }

  componentDidMount : ->
    #

  componentWillUnmount : ->
    #

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    `<div className={'static-page ' + this.props.pageName}>
      <div className="static-page-content">
        {this.props.content}
      </div>
    </div>`


  # --- HELPER METHODS ---    

  handleClose : (e)->
    e.preventDefault()
    # $(window).trigger 'colorcamp:modals:close', { }


@ColorSignupPage = React.createClass
  render : ->
    `<ColorSignupLogin {...this.props} signup={true} />`

@ColorLoginPage = React.createClass
  render : ->
    `<ColorSignupLogin {...this.props} signup={false} />`

@ColorSignupLogin = React.createClass
  getInitialState : ->
    { }

  componentDidMount : ->
    #

  componentWillUnmount : ->
    #

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    html = if this.props.current_user
      `<div>
        <p>You are currently logged in as {this.props.current_user.name}. <ColorLink to={'/u/' + this.props.current_user.login}>Click here to view your profile</ColorLink></p>
      </div>`
    else
      signin_providers = []
      this.props.signin_providers.map (provider)->
        signin_providers.push `<a href={provider.url} className="btn btn-default">{provider.name}</a>`

      title = if this.props.signup
        `<div>
          <h1>Sign Up</h1>
          <p>Some welcome info for getting started.</p>
        </div>`
      else
        `<div>
           <h1>Login</h1>
         </div>`

      `<div>
        {title}
        {signin_providers}
        <p>Some helper text here.</p>
      </div>`

    `<ColorStaticPageDisplay content={html} pageName="signup-login" />`


@ColorUserSettings = React.createClass
  getInitialState : ->
    current_user : this.props.current_user
    saving : false
    errors : null

  componentDidMount : ->
    #

  componentWillUnmount : ->
    #

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    unless this.state.current_user
      return `<span></span>`

    disabled = !this.valid()
    savingText = ''
    if this.state.saving
      savingText = `<span>Updating...</span>`
      disabled = true

    html = `<div>
      <h1>Settings</h1>
      <form onSubmit={this.handleSubmit}>
        <div className="input string required user_name">
          <label className="string required" htmlFor="user_name">
            <abbr title="required">*</abbr>
            Name
          </label>
          <input id="user_name" type="text" name="name" value={this.state.current_user.name} onChange={this.handleChange} />
        </div>
        <div className="input string required user_email">
          <label className="string required" htmlFor="user_email">
            <abbr title="required">*</abbr>
            Email
          </label>
          <input id="user_email" type="email" name="email" value={this.state.current_user.email} onChange={this.handleChange} />
        </div>
        <div className="input boolean optional user_profile_private">
          <input type="hidden" name="profile_private" value="0" />
          <label className="boolean optional checkbox" htmlFor="profile_private">
            <input id="profile_private" type="checkbox" name="profile_private" value="1" onChange={this.handleCheckboxChange} />
            Make your profile private?
          </label>
        </div>
        <p>
          <input className="btn" type="submit" value="Update Profile" disabled={disabled} />
          {savingText}
        </p>
      </form>
    </div>`

    `<ColorStaticPageDisplay content={html} pageName="user-settings" />`

  # --- HELPER METHODS ---

  currentUserChange : (e,data)-> 
    this.setState { current_user : data.current_user }

  valid : ->
    valid = true
    valid = false unless this.state.current_user.name
    valid = false if this.state.current_user.email && !this.state.current_user.email.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    valid

  handleChange : (e)->
    user = this.state.current_user
    user[ e.target.name ] = e.target.value
    this.setState { current_user : user }

  handleCheckboxChange : (e)->
    user = this.state.current_user
    user[ e.target.name ] = e.target.checked
    this.setState { current_user : user }

  handleSubmit : (e)->
    e.preventDefault()

    this.setState { saving : true }

    $.ajax '/settings', {
      dataType : 'json'
      data : { user : this.state.current_user }
      method : 'PUT'
      complete : (->
        this.setState { saving : false }
      ).bind(this),
      success : ((d,s,x)->
        if d && d.user
          $(window).trigger 'colorcamp:current_user:change', {current_user : d.user}
        else
          alert('some error')
      ).bind(this), 
      error :  ((x,s,e)->
        alert('errorz')
      ).bind(this)
    }


@ColorAboutPage = React.createClass

  render : ->
    # html = this.props.aboutHtml
    html = 'About page here'
    `<ColorStaticPageDisplay content={html} pageName="about" />`

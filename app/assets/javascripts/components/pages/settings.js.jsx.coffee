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

    title = 'Settings for ' + ColorInitialProps.default_title

    disabled = !this.valid()
    savingText = ''
    if this.state.saving
      savingText = `<span>Updating...</span>`
      disabled = true

    content = `<section>
      <h1>your settings</h1>
      <p>sdfsfs</p>
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
    </section>`

    `<DocumentTitle title={title}>
      <ColorStaticPageDisplay content={content} pageName="user-settings" />
    </DocumentTitle>`

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

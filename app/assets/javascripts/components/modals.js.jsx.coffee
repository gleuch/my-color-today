@ModalDisplay = React.createClass
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
    React.DOM.div { className : 'modal-wrapper' }, 
      React.DOM.div { className : 'modal-bg' }, null
      React.DOM.div { className : 'modal-content'}, 
        React.DOM.a { href : 'javascript:;', onClick : this.handleClose}, '×'
        this.props.content


  # --- HELPER METHODS ---    

  handleClose : (e)->
    e.preventDefault()
    $(window).trigger 'colorcamp:modals:close', { }


@SignupLoginModal = React.createClass
  getInitialState : ->
    visible : this.props.visible
    signup : this.props.signup
    providers : this.props.providers
    current_user : this.props.current_user

  componentDidMount : ->
    $(window).bind 'colorcamp:signuplogin:open', this.openDialog
    $(window).bind 'colorcamp:signuplogin:close colorcamp:modals:close', this.closeDialog
    $(window).bind 'colorcamp:current_user:change', this.currentUserChange
    $(window).trigger 'colorcamp:settings:mounted', {}

  componentWillUnmount : ->
    $(window).unbind 'colorcamp:signuplogin:open', this.openDialog
    $(window).unbind 'colorcamp:signuplogin:close colorcamp:modals:close', this.closeDialog
    $(window).unbind 'colorcamp:current_user:change', this.currentUserChange

  componentWillUpdate : (p,s)->
    #

  componentDidUpdate : (p,s)->
    #

  render : ->
    if this.state.current_user || !this.state.visible
      return React.DOM.span {}, ''


    providers = []
    this.state.providers.map (provider)->
      providers.push( React.DOM.a { href: provider.url, className : 'btn btn-default' }, provider.name )

    if this.state.signup
      title = React.DOM.div { }, 
        React.DOM.h1 { }, 'Sign Up'
        React.DOM.p { }, 'Some welcome info for getting started.'
    else
      title = React.DOM.div { },
         React.DOM.h1 { }, 'Login'

    html = React.DOM.div { }, 
      {title}
      {providers}
      React.DOM.p { }, 'Some helper text here.'

    `<ModalDisplay content={html} />`


  # --- HELPER METHODS ---

  openDialog : (e,data)->
    $(window).trigger 'colorcamp:modals:close', { except : 'signuplogin' }
    this.setState { visible : true, signup : data.signup }

  closeDialog : (e,data)->
    unless data.except && data.except == 'settings'
      this.setState { visible : false }

  currentUserChange : (e,data)-> 
    this.setState { current_user : data.current_user }


@SettingsModal = React.createClass
  getInitialState : ->
    current_user : this.props.current_user

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
      return React.DOM.span {}, ''

    disabled = !this.valid()

    # Return HTML
    html = React.DOM.div { },
      React.DOM.h1 { }, 'Settings'
      React.DOM.form { onSubmit : this.handleSubmit }, 
        React.DOM.div { className : 'input string required user_name' },
          React.DOM.label { className : 'string required', htmlFor : 'user_name' },
            React.DOM.abbr { title : 'required' }, '*'
            'Name'
          React.DOM.input { id : 'user_name', type : 'text', name : 'name', value : this.state.current_user.name, onChange : this.handleChange }
        React.DOM.div { className : 'input email required user_email' },
          React.DOM.label { className : 'email required', htmlFor : 'user_email' },
            React.DOM.abbr { title : 'required' }, '*'
            'Email'
          React.DOM.input { id : 'user_email', type : 'email', name : 'email', value : this.state.current_user.email, onChange : this.handleChange }
        React.DOM.div { className : 'input boolean optional user_profile_private'}, 
          React.DOM.input { type : 'hidden', name : 'profile_private', value: 0}
          React.DOM.label { className : 'boolean optional checkbox', htmlFor : 'profile_private'},
            React.DOM.input { id: 'profile_private', type : 'checkbox', name : 'profile_private', value : 1, onChange : this.handleCheckboxChange }
            'Make your profile private?'
        React.DOM.input { className : 'btn', type : 'submit', value : 'Update Profile', disabled : disabled}

    `<ModalDisplay content={html} />`

  # --- HELPER METHODS ---

  openDialog : (e,data)->
    $(window).trigger 'colorcamp:modals:close', { except : 'settings' }
    this.setState { visible : true }

  closeDialog : (e,data)->
    unless data.except && data.except == 'settings'
      this.setState { visible : false }

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

    $.ajax '/settings', {
      dataType : 'json'
      data : { user : this.state.current_user }
      method : 'PUT'
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

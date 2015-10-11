@DocumentTitle = React.createClass
  displayName : 'DocumentTitle'

  propTypes :
    title : React.PropTypes.string.isRequired

  componentDidMount : ->
    document.title = this.props.title || ''

  componentDidChange : ->
    document.title = this.props.title || ''

  render: ->
    if this.props.children
      React.Children.only this.props.children
    else
      null
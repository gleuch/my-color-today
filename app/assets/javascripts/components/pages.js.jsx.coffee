@ColorStaticPageDisplay = React.createClass
  render : ->
    hasGutter = if this.props.rightGutter then 'has-gutter' else ''

    `<article className={'static-page ' + this.props.pageName + ' ' + hasGutter}>
      <div className="static-page-container">
        <div className="static-page-content">{this.props.content}</div>
        <div className="static-page-gutter">{this.props.rightGutter}</div>
        <div className="clearfix" />
      </div>
    </article>
    `

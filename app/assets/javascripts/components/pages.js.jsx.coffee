@ColorStaticPageDisplay = React.createClass
  render : ->
    `<article className={'static-page ' + this.props.pageName}>
      <div className="static-page-content">{this.props.content}</div>
      <div className="static-page-gutter">{this.props.rightGutter}</div>
      <div className="clearfix" />
    </article>
    `

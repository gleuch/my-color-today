@ColorNotFoundPage = React.createClass
  render : ->
    html = 'Page not found. Sorry :('
    title = "Page Not Found"
    `<DocumentTitle title={title}>
      <ColorStaticPageDisplay content={html} pageName="not-found" />
    </DocumentTitle>`

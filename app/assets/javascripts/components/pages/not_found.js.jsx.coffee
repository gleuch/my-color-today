@ColorNotFoundPage = React.createClass
  render : ->
    html = 'Page not found. Sorry :('
    `<ColorStaticPageDisplay content={html} pageName="not-found" />`

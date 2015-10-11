@ColorNotFoundPage = React.createClass
  render : ->
    html = `<span>
      <section>
        <h1>not found</h1>
        <p>&nbsp;<br/>Sorry, but this page could not be found.<br />Please <ColorLink to="/">click here</ColorLink> to go back to the home page.</p>
      </section>
    </span>`
    title = 'Page Not Found'

    `<DocumentTitle title={title}>
      <ColorStaticPageDisplay content={html} pageName="not-found" />
    </DocumentTitle>`

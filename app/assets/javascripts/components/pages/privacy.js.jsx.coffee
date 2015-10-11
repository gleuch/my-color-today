@ColorPrivacyPage = React.createClass
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
    content = `<span>
      <section>
        <h1>privacy & terms</h1>
        <p>as part of the terms of service and privacy policy of this web site and associated applications, browser extensions, and/or content scripts, any user must agree to the following conditions. these conditions may be updated at any time without notice.</p>
        <p>your information is not sold or used for any other purpose but to visualize your browisng experience. afterall, this is only an art piece, not a unicorn startup failure.</p>
        <p>however, by regisering on this web site and/or downloading any application, browser extension, and/or content script developed for the use on this web site, you agree to share information about yourself and web sites you visit. any information you publish will be shared publicly for others to see, and such information cannot and will not be deleted upon request. additionally, your information may be used in other features for this art piece or future works of art in this series by <a href="https://gleu.ch">Greg Leuch</a>.</p>
        <p><em>last updated 04 october, 2014</em></p>
      </section>
    </span>`

    title = "Privacy & Terms"

    `<DocumentTitle title={title}>
      <ColorStaticPageDisplay content={content} pageName="signup-login" />
    </DocumentTitle>`

@ColorInstallPage = React.createClass
  render : ->
    title = 'Install ' + ColorInitialProps.default_title

    signupOrOther = `<p>all it takes to make your own browsing history visualization is downloading the extension and signing up for an account using an existing social media login.</p>`
    signupOrOther = `<p>you are already signed in as <u>{this.props.current_user.login}</u>, so all you need to do is download the extension and get started!</p>` if this.props.current_user

    content = `<span>
      <section>
        <h1>install</h1>
        <p>mycolor.today works by monitoring your browsing behavior and looking at your screen, but not in a creepy way. we use existing methods take what you see and turn it into a single pixel color. with that color, mycolor.today is able to produce a unique and interesting visualization of your browsing history.</p>
        {signupOrOther}
        <ul className="buttons">
          <li key="chrome">
            <a onClick={this.installChromeExtension} className="btn btn-default btn-lg btn-google" target="_blank" href="https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca">get for google chrome</a>
          </li>
        </ul>
        <p className="disclaimer">* safari, firefox, and internet explorer extensions coming soon. if you are interested in contributing to mycolor.today, <a href={'mailto:' + ColorInitialProps.links.email} onClick={TrackEvent.link('Install:Footer')}>let us know</a>!</p>
      </section>
    </span>`

    `<DocumentTitle title={title}>
      <ColorStaticPageDisplay content={content} pageName="install" />
    </DocumentTitle>`


  installChromeExtension : (e)->
    TrackEvent.track('Extensions', 'Chrome', 'Install')
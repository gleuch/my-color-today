@ColorRoute = ReactRouter.Route
@ColorRouteHandler = ReactRouter.RouteHandler
@ColorDefaultRoute = ReactRouter.DefaultRoute
@ColorNotFoundRoute = ReactRouter.NotFoundRoute
@ColorLink = ReactRouter.Link


@ColorRoutes = (`
  <ColorRoute path='/' handler={ColorApp}>
    <ColorDefaultRoute handler={ColorHomepageChannel} />
    <ColorNotFoundRoute handler={ColorNotFoundPage} />

    <ColorRoute handler={ColorAboutPage} path='about' />
    <ColorRoute handler={ColorInstallPage} path='install' />
    <ColorRoute handler={ColorSignupPage} path='signup' />
    <ColorRoute handler={ColorLoginPage} path='login' />
    <ColorRoute handler={ColorPrivacyPage} path='privacy' />
    <ColorRoute handler={ColorPrivacyPage} path='terms' />
    <ColorRoute handler={ColorUserSettings} path='settings' />
    <ColorRoute handler={ColorEveryoneChannel} path='everyone' />
    <ColorRoute handler={ColorUserChannel} path='u/:id' />
    <ColorRoute handler={ColorSiteChannel} path='s/:id' />
  </ColorRoute>
`)

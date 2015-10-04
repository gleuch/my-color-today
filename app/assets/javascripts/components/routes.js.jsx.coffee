@ColorRoute = ReactRouter.Route
@ColorRouteHandler = ReactRouter.RouteHandler
@ColorDefaultRoute = ReactRouter.DefaultRoute
@ColorNotFoundRoute = ReactRouter.NotFoundRoute
@ColorLink = ReactRouter.Link


@ColorRoutes = (`
  <ColorRoute path='/' handler={ColorApp}>
    <ColorDefaultRoute handler={ColorEveryoneChannel} />
    <ColorNotFoundRoute handler={ColorNotFoundPage} />

    <ColorRoute handler={ColorAboutPage} path='about' />
    <ColorRoute handler={ColorInstallPage} path='install' />
    <ColorRoute handler={ColorSignupPage} path='signup' />
    <ColorRoute handler={ColorLoginPage} path='login' />
    <ColorRoute handler={ColorUserSettings} path='settings' />
    <ColorRoute handler={ColorUserChannel} path='u/:id' />
  </ColorRoute>
`)

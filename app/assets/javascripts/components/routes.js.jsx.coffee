@ColorRoute = ReactRouter.Route
@ColorRouteHandler = ReactRouter.RouteHandler
@ColorNotFoundRoute = ReactRouter.NotFoundRoute
@ColorLink = ReactRouter.Link


@ColorRoutes = (`
  <ColorRoute handler={ColorApp}>
    <ColorRoute handler={ColorAboutPage} path='/about' />

    <ColorRoute handler={ColorSignupPage} path='/signup' />
    <ColorRoute handler={ColorLoginPage} path='/login' />

    <ColorRoute handler={ColorUserSettings} path='/settings' />
    <ColorRoute handler={ColorUserChannel} path='/u/:id' />

    <ColorRoute handler={ColorEveryoneChannel} path='/' />
  </ColorRoute>
`)

@ColorRoute = ReactRouter.Route
@ColorRouteHandler = ReactRouter.RouteHandler
@ColorNotFoundRoute = ReactRouter.NotFoundRoute
@ColorLink = ReactRouter.Link


@ColorRoutes = (`
  <ColorRoute handler={ColorApp}>
    <ColorRoute handler={SettingsModal} path='/settings' />
    <ColorRoute handler={ColorUserChannel} path='/u/:id' />
    <ColorRoute handler={ColorEveryoneChannel} path='/' />
  </ColorRoute>
`)

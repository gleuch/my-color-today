# /**
#  * The CSSTransitionGroup component uses the 'transitionend' event, which
#  * browsers will not send for any number of reasons, including the
#  * transitioning node not being painted or in an unfocused tab.
#  *
#  * This TimeoutTransitionGroup instead uses a user-defined timeout to determine
#  * when it is a good time to remove the component. Currently there is only one
#  * timeout specified, but in the future it would be nice to be able to specify
#  * separate timeouts for enter and leave, in case the timeouts for those
#  * animations differ. Even nicer would be some sort of inspection of the CSS to
#  * automatically determine the duration of the animation or transition.
#  *
#  * This is adapted from Facebook's CSSTransitionGroup which is in the React
#  * addons and under the Apache 2.0 License.
#  */

# via https://github.com/Khan/react-components/blob/master/js/timeout-transition-group.jsx

@ReactTransitionGroup = React.addons.TransitionGroup;

TICK = 17;

# /**
#  * EVENT_NAME_MAP is used to determine which event fired when a
#  * transition/animation ends, based on the style property used to
#  * define that event.
#  */

EVENT_NAME_MAP =
  transitionend:
    'transition' : 'transitionend',
    'WebkitTransition' : 'webkitTransitionEnd',
    'MozTransition' : 'mozTransitionEnd',
    'OTransition' : 'oTransitionEnd',
    'msTransition' : 'MSTransitionEnd'
  animationend :
    'animation': 'animationend',
    'WebkitAnimation': 'webkitAnimationEnd',
    'MozAnimation': 'mozAnimationEnd',
    'OAnimation': 'oAnimationEnd',
    'msAnimation': 'MSAnimationEnd'

endEvents = []

(detectEvents = ->
  return if typeof window == "undefined"

  testEl = document.createElement 'div'
  styles = Object.keys testEl.style

  # On some platforms, in particular some releases of Android 4.x, the
  # un-prefixed "animation" and "transition" properties are defined on the
  # style object but the events that fire will still be prefixed, so we need
  # to check if the un-prefixed events are useable, and if not remove them
  # from the map
  delete EVENT_NAME_MAP.animationend.animation unless window.AnimationEvent
  delete EVENT_NAME_MAP.transitionend.transition unless window.TransitionEvent

  for baseEventName, baseEvents of EVENT_NAME_MAP
    if EVENT_NAME_MAP.hasOwnProperty baseEventName
      for styleName, styleValue of baseEvents
        if styles.indexOf(styleName) >= 0
          endEvents.push styleValue
          break
)()

animationSupported = ->
  endEvents.length != 0


# /**
#  * Functions for element class management to replace dependency on jQuery
#  * addClass, removeClass and hasClass
#  */
addClass = (element, className)->
  if element.classList
    element.classList.add className
  else if !hasClass element, className
    element.className = element.className + ' ' + className
  element

removeClass = (element, className)->
  if hasClass className
    if element.classList
      element.classList.remove className
    else
      element.className = (' ' + element.className + ' ').replace(' ' + className + ' ', ' ').trim()
  element

hasClass = (element, className)->
  if element.classList
    return element.classList.contains className
  else
    return (' ' + element.className + ' ').indexOf(' ' + className + ' ') > -1


@TimeoutTransitionGroupChild = React.createClass
  transition : (animationType, finishCallback)->
    node = this.getDOMNode()
    className = this.props.name + '-' + animationType
    activeClassName = className + '-active'
    hiddenClassName = className + '-hidden'

    endListener = ->
      removeClass node, className
      removeClass node, activeClassName
      removeClass node, hiddenClassName
      finishCallback() if finishCallback

    unless animationSupported()
      endListener()
    else
      if animationType == "enter"
        enterListener = ->
          removeClass node, hiddenClassName
          this.queueClass activeClassName
          this.animationTimeout = setTimeout endListener.bind(this), this.props.enterTimeout

        addClass node, className
        addClass node, hiddenClassName
        this.animationTimeout = setTimeout enterListener.bind(this), this.props.leaveTimeout
        return

      else if animationType == "leave"
        this.animationTimeout = setTimeout endListener.bind(this), this.props.leaveTimeout

    addClass node, className
    this.queueClass activeClassName

  queueClass : (className)->
    this.classNameQueue.push className
    unless this.timeout
      this.timeout = setTimeout this.flushClassNameQueue, TICK

  flushClassNameQueue : ->
    if this.isMounted()
      for i,name of this.classNameQueue
        addClass this.getDOMNode(), name

    this.classNameQueue.length = 0
    this.timeout = null

  componentWillMount : ->
    this.classNameQueue = []

  componentWillUnmount : ->
    if this.timeout
      clearTimeout this.timeout
    if this.animationTimeout
      clearTimeout this.animationTimeout

  componentWillEnter : (done)->
    if this.props.enter
      this.transition 'enter', done
    else
      done()

  componentWillLeave : (done)->
    if this.props.leave
      this.transition 'leave', done
    else
      done()

  render : ->
    React.Children.only this.props.children


@TimeoutTransitionGroup = React.createClass
  propTypes :
    enterTimeout: React.PropTypes.number.isRequired
    leaveTimeout: React.PropTypes.number.isRequired
    transitionName: React.PropTypes.string.isRequired
    transitionEnter: React.PropTypes.bool
    transitionLeave: React.PropTypes.bool

  getDefaultProps : ->
    transitionEnter: true
    transitionLeave: true

  _wrapChild : (child)->
    `<TimeoutTransitionGroupChild enterTimeout={this.props.enterTimeout} leaveTimeout={this.props.leaveTimeout} name={this.props.transitionName} enter={this.props.transitionEnter} leave={this.props.transitionLeave}>
      {child}
    </TimeoutTransitionGroupChild>`

  render : ->
    `<ReactTransitionGroup {...this.props} childFactory={this._wrapChild} />`
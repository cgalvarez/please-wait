((root, factory) ->
  if typeof exports is "object"
    # CommonJS
    factory exports
  else if typeof define is "function" and define.amd
    # AMD. Register as an anonymous module.
    define ["exports"], factory
  else
    # Browser globals
    factory root
  return
) this, (exports) ->
  elm = document.createElement('fakeelement')
  animationSupport = false
  transitionSupport = false
  animationEvent = 'animationend'
  transitionEvent = null
  domPrefixes = 'Webkit Moz O ms'.split(' ')
  transEndEventNames =
    'transition' : 'transitionend'
    'WebkitTransition' : 'webkitTransitionEnd'
    'MozTransition' : 'transitionend'
    'OTransition' : 'oTransitionEnd'
    'msTransition' : 'MSTransitionEnd'

  for key, val of transEndEventNames
    if elm.style[key]?
      transitionEvent = val
      transitionSupport = true
      break

  if elm.style.animationName? then animationSupport = true

  if !animationSupport
    for pfx in domPrefixes
      if elm.style["#{pfx}AnimationName"]?
        switch pfx
          when 'Webkit'
            animationEvent = 'webkitAnimationEnd'
          when 'Moz'
            animationEvent = 'animationend'
          when 'O'
            animationEvent = 'oanimationend'
          when 'ms'
            animationEvent = 'MSAnimationEnd'
        animationSupport = true
        break

  # Helpers to add/remove classes, since we don't have our friend jQuery
  addClass = (classname, elem) ->
    if elem.classList
      elem.classList.add(classname)
    else
      elem.className += " #{classname}"

  removeClass = (classname, elem) ->
    if elem.classList
      elem.classList.remove(classname)
    else
      elem.className = elem.className.replace(classname, "").trim()

  # Helpers to add styles to document head.
  addCss = (css, append=false) ->
    # Set an ID for the styles to reuse it on future calls.
    id = 'please-wait-styles'
    s = document.getElementById(id)
    if !s # Create style element if not exists.
      head = document.getElementsByTagName('head')[0]
      s = document.createElement('style')
      s.id = id
      s.setAttribute('type', 'text/css')
      head.appendChild(s)
    if append # Append styles
      if (s.styleSheet) then s.styleSheet.cssText += css # IE.
      #else s.innerText = css # The rest.
      else s.appendChild(document.createTextNode(css)) # The rest.
    else # Set styles.
      if (s.styleSheet) then s.styleSheet.cssText = css # IE.
      else s.innerText = css # The rest.

  # Helpers for SpinKit spinners.
  Spinner =
    'chasing-dots': """
      <div class="sk-child sk-dot1"></div>
      <div class="sk-child sk-dot2"></div>
    """
    circle: """
      <div class="sk-circle1 sk-child"></div>
      <div class="sk-circle2 sk-child"></div>
      <div class="sk-circle3 sk-child"></div>
      <div class="sk-circle4 sk-child"></div>
      <div class="sk-circle5 sk-child"></div>
      <div class="sk-circle6 sk-child"></div>
      <div class="sk-circle7 sk-child"></div>
      <div class="sk-circle8 sk-child"></div>
      <div class="sk-circle9 sk-child"></div>
      <div class="sk-circle10 sk-child"></div>
      <div class="sk-circle11 sk-child"></div>
      <div class="sk-circle12 sk-child"></div>
    """
    'cube-grid': """
      <div class="sk-cube sk-cube1"></div>
      <div class="sk-cube sk-cube2"></div>
      <div class="sk-cube sk-cube3"></div>
      <div class="sk-cube sk-cube4"></div>
      <div class="sk-cube sk-cube5"></div>
      <div class="sk-cube sk-cube6"></div>
      <div class="sk-cube sk-cube7"></div>
      <div class="sk-cube sk-cube8"></div>
      <div class="sk-cube sk-cube9"></div>
    """
    'double-bounce': """
      <div class="sk-child sk-double-bounce1"></div>
      <div class="sk-child sk-double-bounce2"></div>
    """
    'fading-circle': """
      <div class="sk-circle1 sk-circle"></div>
      <div class="sk-circle2 sk-circle"></div>
      <div class="sk-circle3 sk-circle"></div>
      <div class="sk-circle4 sk-circle"></div>
      <div class="sk-circle5 sk-circle"></div>
      <div class="sk-circle6 sk-circle"></div>
      <div class="sk-circle7 sk-circle"></div>
      <div class="sk-circle8 sk-circle"></div>
      <div class="sk-circle9 sk-circle"></div>
      <div class="sk-circle10 sk-circle"></div>
      <div class="sk-circle11 sk-circle"></div>
      <div class="sk-circle12 sk-circle"></div>
    """
    'folding-cube': """
      <div class="sk-cube1 sk-cube"></div>
      <div class="sk-cube2 sk-cube"></div>
      <div class="sk-cube4 sk-cube"></div>
      <div class="sk-cube3 sk-cube"></div>
    """
    pulse: ''
    'rotating-plane': ''
    'three-bounce': """
      <div class="sk-child sk-bounce1"></div>
      <div class="sk-child sk-bounce2"></div>
      <div class="sk-child sk-bounce3"></div>
    """
    'wandering-cubes': """
      <div class="sk-cube sk-cube1"></div>
      <div class="sk-cube sk-cube2"></div>
    """
    wave: """
      <div class="sk-rect sk-rect1"></div>
      <div class="sk-rect sk-rect2"></div>
      <div class="sk-rect sk-rect3"></div>
      <div class="sk-rect sk-rect4"></div>
      <div class="sk-rect sk-rect5"></div>
    """
  Class =
    ELLIPSIS: 'ellipsis'
    LOADED: 'pg-loaded'
    LOADING: 'pg-loading'
    LOADING_HTML: 'pg-loading-html'
    LOADING_LOGO: 'pg-loading-logo'
    LOADING_SCREEN: 'pg-loading-screen'
    LOADING_MESSAGE: 'pg-loading-message'
    REMOVING: 'pg-removing'
    SPINNER_BEFORE: 'spinner-before'
    SPINNER_AFTER: 'spinner-after'


  class PleaseWait
    @_defaultOptions:
      # Whether to animate the changed option (tipically fade out/in) or change it immediately.
      animateOptionUpdate: false
      # Whether to append animated ellipsis inside `.pg-loading-message` or not.
      appendAnimatedEllipsis: true
      backgroundColor: null
      # The HTML element which the loading screen will be appended to.
      container: document.body
      loadingHtml: null
      loadingMessage: null
      logo: null
      logoMaxSize: null
      # Whether to place a SpinKit spinner before/after `.pg-loading-message` or not.
      # `false` means no spinner will be inserted; `true` defaults to `` SpinKit spinner;
      # you can provide any of the SpinKit's bundled presets as string and the required
      # HTML structured will be inserted automagically. Example: 'wanderingCubes'.
      spinnerBefore: false
      spinnerAfter: null
      spinnerColor: null
      # User is not required to provide a logo, so `template` will be used in that case
      # and `templateLogo` otherwise.
      template: """
        <div class="pg-loading-inner">
          <div class="pg-loading-center-outer">
            <div class="pg-loading-center-middle">
              <h1 class="pg-loading-logo-header"></h1>
              <div class="pg-loading-html"></div>
            </div>
          </div>
        </div>
      """
      onLoadedCallback: null

    constructor: (options) ->
      defaultOptions = @constructor._defaultOptions
      @options = {}
      @loaded = false
      @finishing = false

      # Set initial options, merging given options with the defaults
      for k, v of defaultOptions
        @options[k] = if options[k]? then options[k] else v

      # Create an empty styles tag.
      styles = ''

      # Create the loading screen element
      @_loadingElem = document.createElement('div')
      # Create an empty array to store the potential list of loading HTML (messages, spinners, etc)
      # we'll be displaying to the screen
      @_loadingHtmlToDisplay = []
      # Add a global class for easy styling
      @_loadingElem.className = Class.LOADING_SCREEN
      # Set the background color of the loading screen, if supplied
      @_loadingElem.style.backgroundColor = @options.backgroundColor if @options.backgroundColor?
      # Initialize the loading screen's HTML with the defined template. The default can be overwritten via options
      @_loadingElem.innerHTML = @options.template
      if @options.logo
        logo = document.createElement('img')
        logo.className = Class.LOADING_LOGO
        logoHeader = @_loadingElem.getElementsByClassName('pg-loading-logo-header')[0]
        logoHeader.insertBefore(logo, logoHeader.firstChild)
        if @options.logoMaxSize
          if typeof @options.logoMaxSize is 'string' || @options.logoMaxSize instanceof String
            styles += ".pg-loading-screen .pg-loading-logo-header img { max-height: #{@options.logoMaxSize}; max-width: #{@options.logoMaxSize}; }"
          else
            styles += ".pg-loading-screen .pg-loading-logo-header img { max-height: #{@options.logoMaxSize[1]}; max-width: #{@options.logoMaxSize[0]}; }"

      # Find the element that will contain the loading HTML displayed to the user (typically a spinner/message)
      # This can be changed via updateLoadingHtml
      @_loadingHtmlElem = @_loadingElem.getElementsByClassName(Class.LOADING_HTML)[0]
      if @_loadingHtmlElem
        # Set the initial loading HTML, if supplied
        @_loadingHtmlElem.innerHTML = @options.loadingHtml if @options.loadingHtml
        # Set the initial message string, if supplied
        @_loadingHtmlElem.innerHTML = "<div class=\"#{Class.LOADING_MESSAGE}\">#{@options.loadingMessage}</div>" if @options.loadingMessage

      # Prepend/append the requested spinner/ellipsis when and where appropriate.
      @_loadingMsg = @_loadingHtmlElem.getElementsByClassName(Class.LOADING_MESSAGE)[0]
      addClass(Class.ELLIPSIS, @_loadingMsg) if (@_loadingMsg? && @options.appendAnimatedEllipsis)
      if (@options.spinnerBefore || @options.spinnerAfter) && @_loadingMsg?
        @_loadingMsgParent = @_loadingMsg.parentNode
        spinner = document.createElement('div')
        spinnerClassnames = @options.spinnerBefore || @options.spinnerAfter
        spinner.innerHTML = Spinner[ spinnerClassnames ]
        spinner.className = (if spinnerClassnames == 'pulse' then 'sk-spinner sk-spinner-' else 'sk-') + spinnerClassnames
        # Set custom spinner color when provided.
        if @options.spinnerColor
          selectors = spinner.className.split(' ')
          selectors[i] = ".#{selectors[i]}" for i in [selectors.length-1..0]
          selector = selectors.join('')
          rule = "background-color: #{@options.spinnerColor} !important;"
          switch spinnerClassnames
            when 'pulse', 'rotating-plane' then styles += "#{selector} { #{rule} }"
            when 'circle', 'fading-circle', 'folding-cube' then styles += "#{selector} > div::before { #{rule} }"
            else styles += "#{selector} > div { #{rule} }"
#          switch spinnerClassnames
#            when 'pulse', 'rotating-plane' then addCss("#{selector} { #{rule} }")
#            when 'circle', 'fading-circle', 'folding-cube' then addCss("#{selector} > div::before { #{rule} }")
#            else addCss("#{selector} > div { #{rule} }")
        # Place spinner where requested.
        if @options.spinnerBefore
          addClass(Class.SPINNER_BEFORE, @_loadingHtmlElem)
          @_loadingMsgParent.insertBefore(spinner, @_loadingMsgParent.firstChild)
        else
          addClass(Class.SPINNER_AFTER, @_loadingHtmlElem)
          @_loadingMsgParent.appendChild(spinner)

      # Set a flag that lets us know if the transitioning between loading HTML elements is finished.
      # If true, we can transition immediately to a new message/HTML
      @_readyToShowLoadingHtml = false

      # Find the element that displays the loading logo and set the src if supplied
      if @options.logo?
        @_logoElem = @_loadingElem.getElementsByClassName(Class.LOADING_LOGO)[0]
        @_logoElem.src = @options.logo if @_logoElem?
      # Add the loading screen to the body
      removeClass(Class.LOADED, @options.container)
      addClass(Class.LOADING, @options.container)
      @options.container.appendChild(@_loadingElem)
      # Add the CSS class that will trigger the initial transitions of the logo/loading HTML
      addClass(Class.LOADING, @_loadingElem)
      # Register a callback to invoke when the loading screen is finished
      @_onLoadedCallback = @options.onLoadedCallback

      # Append styles if customized any way.
      addCss(styles) if '' != styles

      # Define a listener to look for any new loading HTML that needs to be displayed after the intiial transition finishes
      listener = (evt) =>
        @loaded = true
        @_readyToShowLoadingHtml = true
        addClass(Class.LOADED, @_loadingHtmlElem)
        if animationSupport then @_loadingHtmlElem.removeEventListener(animationEvent, listener)
        if @_loadingHtmlToDisplay.length > 0 then @_changeLoadingHtml()
        if @finishing
          # If we reach here, it means @finish() was called while we were animating in, so we should
          # call @_finish() immediately. This registers a new event listener, which will fire
          # immediately, instead of waiting for the *next* animation to end. We stop propagation now
          # to prevent this conflict
          evt?.stopPropagation()
          @_finish()

      if @_loadingHtmlElem?
        # Detect CSS animation support. If not found, we'll call the listener immediately. Otherwise, we'll wait
        if animationSupport
          @_loadingHtmlElem.addEventListener(animationEvent, listener)
        else
          listener()

        # Define listeners for the transtioning out and in of new loading HTML/messages
        @_loadingHtmlListener = =>
          # New loading HTML has fully transitioned in. We're now ready to show a new message/HTML
          @_readyToShowLoadingHtml = true
          # Remove the CSS class that triggered the fade in animation
          removeClass(Class.LOADING, @_loadingHtmlElem)
          if transitionSupport then @_loadingHtmlElem.removeEventListener(transitionEvent, @_loadingHtmlListener)
          # Check if there's still HTML left in the queue to display. If so, let's show it
          if @_loadingHtmlToDisplay.length > 0 then @_changeLoadingHtml()

        @_removingHtmlListener = =>
          # Last loading HTML to display has fully transitioned out. Time to transition the new in
          @_loadingHtmlElem.innerHTML = @_loadingHtmlToDisplay.shift()
          # Add the CSS class to trigger the fade in animation
          removeClass(Class.REMOVING, @_loadingHtmlElem)
          addClass(Class.LOADING, @_loadingHtmlElem)
          if transitionSupport
            @_loadingHtmlElem.removeEventListener(transitionEvent, @_removingHtmlListener)
            @_loadingHtmlElem.addEventListener(transitionEvent, @_loadingHtmlListener)
          else
            @_loadingHtmlListener()

    finish: (immediately = false, onLoadedCallback) ->
      # Our nice CSS animations won't run until the window is visible. This is a problem when the
      # site is loading in a background tab, since the loading screen won't animate out until the
      # window regains focus, which makes it look like the site takes forever to load! On browsers
      # that support it (IE10+), use the visibility API to immediately hide the loading screen if
      # the window is hidden
      if window.document.hidden then immediately = true

      # NOTE: if @loaded is false, the screen is still initializing. In that case, set @finishing to
      # true and let the existing listener handle calling @_finish for us. Otherwise, we can call
      # @_finish now to start the dismiss animation
      @finishing = true
      if onLoadedCallback? then @updateOption('onLoadedCallback', onLoadedCallback)
      if @loaded || immediately
        # Screen has fully initialized, so we are ready to close
        @_finish(immediately)

    updateMessage: (message) ->
      #return if !@_loadingMsg?
      @_loadingMsg.innerHTML = message if @_loadingMsg? # + ('<div class="ellipsis"></div>' if @options.appendAnimatedEllipsis)
      #newLoadingMsg =
      #@_loadingMsgParent.replaceChild(@_loadingMsg)

    updateOption: (option, value, animate, immediately=false) ->
      switch option
        when 'backgroundColor'
          @_loadingElem.style.backgroundColor = value
        when 'logo'
          @_logoElem.src = value
        when 'loadingHtml'
          @updateLoadingHtml(value, animate, immediately)
        when 'onLoadedCallback'
          @_onLoadedCallback = value
        else
          throw new Error("Unknown option '#{option}'")

    updateOptions: (options={}) ->
      for k, v of options
        @updateOption(k, v)

    updateLoadingHtml: (loadingHtml, animate, immediately=false) ->
      unless @_loadingHtmlElem? then throw new Error('The loading template does not have an element of class "pg-loading-html"')
      if immediately
        # Ignore any loading HTML that may be queued up. Show this immediately
        @_loadingHtmlToDisplay = [loadingHtml]
        @_readyToShowLoadingHtml = true
      else
        # Add to an array of HTML to display to the user
        @_loadingHtmlToDisplay.push(loadingHtml)
      # If ready, let's display the new loading HTML
      if @_readyToShowLoadingHtml then @_changeLoadingHtml(animate)

    # Private method to immediately change the loading HTML displayed
    _changeLoadingHtml: (animate=@options.animateOptionUpdate) ->
      @_readyToShowLoadingHtml = false
      # Remove any old event listeners that may still be attached to the DOM
      @_loadingHtmlElem.removeEventListener(transitionEvent, @_loadingHtmlListener)
      @_loadingHtmlElem.removeEventListener(transitionEvent, @_removingHtmlListener)
      # Remove any old CSS transition classes that may still be on the element
      removeClass(Class.LOADING, @_loadingHtmlElem)
      removeClass(Class.REMOVING, @_loadingHtmlElem)

      animate = false if !animate?
      if transitionSupport && animate
        # Add the CSS class that will cause the HTML to fade out
        addClass(Class.REMOVING, @_loadingHtmlElem)
        @_loadingHtmlElem.addEventListener(transitionEvent, @_removingHtmlListener)
      else
        @_removingHtmlListener()

    _finish: (immediately = false) ->
      return unless @_loadingElem?
      # Add a class to the body to signal that the loading screen has finished and the app is ready.
      # We do this here so that the user can display their HTML behind PleaseWait before it is
      # fully transitioned out. Otherwise, the HTML flashes oddly, since there's a brief moment
      # of time where there is no loading screen and no HTML
      addClass(Class.LOADED, @options.container)
      if typeof @_onLoadedCallback == 'function' then @_onLoadedCallback.apply(this)

      # Again, define a listener to run once the loading screen has fully transitioned out
      listener = =>
        # Remove the loading screen from the body
        @options.container.removeChild(@_loadingElem)
        # Remove the pg-loading class since we're done here
        removeClass(Class.LOADING, @options.container)
        if animationSupport then @_loadingElem.removeEventListener(animationEvent, listener)
        # Reset the loading screen element since it's no longer attached to the DOM
        @_loadingElem = null

      # Detect CSS animation support. If not found, we'll call the listener immediately. Otherwise, we'll wait
      if !immediately && animationSupport
        # Set a class on the loading screen to trigger a fadeout animation
        addClass(Class.LOADED, @_loadingElem)
        # When the loading screen is finished fading out, we'll remove it from the DOM
        @_loadingElem.addEventListener(animationEvent, listener)
      else
        listener()

  pleaseWait = (options = {}) ->
    new PleaseWait(options)

  exports.pleaseWait = pleaseWait
  return pleaseWait

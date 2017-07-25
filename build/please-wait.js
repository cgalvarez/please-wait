/**
* please-wait
* Display a nice loading screen while your app loads

* @author Pathgather <tech@pathgather.com>
* @copyright Pathgather 2017
* @license MIT <http://opensource.org/licenses/mit-license.php>
* @link https://github.com/Pathgather/please-wait
* @module please-wait
* @version 0.1.0
*/
(function(root, factory) {
  if (typeof exports === "object") {
    factory(exports);
  } else if (typeof define === "function" && define.amd) {
    define(["exports"], factory);
  } else {
    factory(root);
  }
})(this, function(exports) {
  var Class, PleaseWait, Spinner, addClass, addCss, animationEvent, animationSupport, domPrefixes, elm, key, pfx, pleaseWait, removeClass, transEndEventNames, transitionEvent, transitionSupport, val, _i, _len;
  elm = document.createElement('fakeelement');
  animationSupport = false;
  transitionSupport = false;
  animationEvent = 'animationend';
  transitionEvent = null;
  domPrefixes = 'Webkit Moz O ms'.split(' ');
  transEndEventNames = {
    'transition': 'transitionend',
    'WebkitTransition': 'webkitTransitionEnd',
    'MozTransition': 'transitionend',
    'OTransition': 'oTransitionEnd',
    'msTransition': 'MSTransitionEnd'
  };
  for (key in transEndEventNames) {
    val = transEndEventNames[key];
    if (elm.style[key] != null) {
      transitionEvent = val;
      transitionSupport = true;
      break;
    }
  }
  if (elm.style.animationName != null) {
    animationSupport = true;
  }
  if (!animationSupport) {
    for (_i = 0, _len = domPrefixes.length; _i < _len; _i++) {
      pfx = domPrefixes[_i];
      if (elm.style["" + pfx + "AnimationName"] != null) {
        switch (pfx) {
          case 'Webkit':
            animationEvent = 'webkitAnimationEnd';
            break;
          case 'Moz':
            animationEvent = 'animationend';
            break;
          case 'O':
            animationEvent = 'oanimationend';
            break;
          case 'ms':
            animationEvent = 'MSAnimationEnd';
        }
        animationSupport = true;
        break;
      }
    }
  }
  addClass = function(classname, elem) {
    if (elem.classList) {
      return elem.classList.add(classname);
    } else {
      return elem.className += " " + classname;
    }
  };
  removeClass = function(classname, elem) {
    if (elem.classList) {
      return elem.classList.remove(classname);
    } else {
      return elem.className = elem.className.replace(classname, "").trim();
    }
  };
  addCss = function(css, append) {
    var head, id, s;
    if (append == null) {
      append = false;
    }
    id = 'please-wait-styles';
    s = document.getElementById(id);
    if (!s) {
      head = document.getElementsByTagName('head')[0];
      s = document.createElement('style');
      s.id = id;
      s.setAttribute('type', 'text/css');
      head.appendChild(s);
    }
    if (append) {
      if (s.styleSheet) {
        return s.styleSheet.cssText += css;
      } else {
        return s.appendChild(document.createTextNode(css));
      }
    } else {
      if (s.styleSheet) {
        return s.styleSheet.cssText = css;
      } else {
        return s.innerText = css;
      }
    }
  };
  Spinner = {
    'chasing-dots': "<div class=\"sk-child sk-dot1\"></div>\n<div class=\"sk-child sk-dot2\"></div>",
    circle: "<div class=\"sk-circle1 sk-child\"></div>\n<div class=\"sk-circle2 sk-child\"></div>\n<div class=\"sk-circle3 sk-child\"></div>\n<div class=\"sk-circle4 sk-child\"></div>\n<div class=\"sk-circle5 sk-child\"></div>\n<div class=\"sk-circle6 sk-child\"></div>\n<div class=\"sk-circle7 sk-child\"></div>\n<div class=\"sk-circle8 sk-child\"></div>\n<div class=\"sk-circle9 sk-child\"></div>\n<div class=\"sk-circle10 sk-child\"></div>\n<div class=\"sk-circle11 sk-child\"></div>\n<div class=\"sk-circle12 sk-child\"></div>",
    'cube-grid': "<div class=\"sk-cube sk-cube1\"></div>\n<div class=\"sk-cube sk-cube2\"></div>\n<div class=\"sk-cube sk-cube3\"></div>\n<div class=\"sk-cube sk-cube4\"></div>\n<div class=\"sk-cube sk-cube5\"></div>\n<div class=\"sk-cube sk-cube6\"></div>\n<div class=\"sk-cube sk-cube7\"></div>\n<div class=\"sk-cube sk-cube8\"></div>\n<div class=\"sk-cube sk-cube9\"></div>",
    'double-bounce': "<div class=\"sk-child sk-double-bounce1\"></div>\n<div class=\"sk-child sk-double-bounce2\"></div>",
    'fading-circle': "<div class=\"sk-circle1 sk-circle\"></div>\n<div class=\"sk-circle2 sk-circle\"></div>\n<div class=\"sk-circle3 sk-circle\"></div>\n<div class=\"sk-circle4 sk-circle\"></div>\n<div class=\"sk-circle5 sk-circle\"></div>\n<div class=\"sk-circle6 sk-circle\"></div>\n<div class=\"sk-circle7 sk-circle\"></div>\n<div class=\"sk-circle8 sk-circle\"></div>\n<div class=\"sk-circle9 sk-circle\"></div>\n<div class=\"sk-circle10 sk-circle\"></div>\n<div class=\"sk-circle11 sk-circle\"></div>\n<div class=\"sk-circle12 sk-circle\"></div>",
    'folding-cube': "<div class=\"sk-cube1 sk-cube\"></div>\n<div class=\"sk-cube2 sk-cube\"></div>\n<div class=\"sk-cube4 sk-cube\"></div>\n<div class=\"sk-cube3 sk-cube\"></div>",
    pulse: '',
    'rotating-plane': '',
    'three-bounce': "<div class=\"sk-child sk-bounce1\"></div>\n<div class=\"sk-child sk-bounce2\"></div>\n<div class=\"sk-child sk-bounce3\"></div>",
    'wandering-cubes': "<div class=\"sk-cube sk-cube1\"></div>\n<div class=\"sk-cube sk-cube2\"></div>",
    wave: "<div class=\"sk-rect sk-rect1\"></div>\n<div class=\"sk-rect sk-rect2\"></div>\n<div class=\"sk-rect sk-rect3\"></div>\n<div class=\"sk-rect sk-rect4\"></div>\n<div class=\"sk-rect sk-rect5\"></div>"
  };
  Class = {
    ELLIPSIS: 'ellipsis',
    LOADED: 'pg-loaded',
    LOADING: 'pg-loading',
    LOADING_HTML: 'pg-loading-html',
    LOADING_LOGO: 'pg-loading-logo',
    LOADING_SCREEN: 'pg-loading-screen',
    LOADING_MESSAGE: 'pg-loading-message',
    REMOVING: 'pg-removing',
    SPINNER_BEFORE: 'spinner-before',
    SPINNER_AFTER: 'spinner-after'
  };
  PleaseWait = (function() {
    PleaseWait._defaultOptions = {
      animateOptionUpdate: false,
      appendAnimatedEllipsis: true,
      backgroundColor: null,
      container: document.body,
      loadingHtml: null,
      loadingMessage: null,
      logo: null,
      logoMaxSize: null,
      spinnerBefore: false,
      spinnerAfter: null,
      spinnerColor: null,
      template: "<div class=\"pg-loading-inner\">\n  <div class=\"pg-loading-center-outer\">\n    <div class=\"pg-loading-center-middle\">\n      <h1 class=\"pg-loading-logo-header\"></h1>\n      <div class=\"pg-loading-html\"></div>\n    </div>\n  </div>\n</div>",
      onLoadedCallback: null
    };

    function PleaseWait(options) {
      var defaultOptions, i, k, listener, logo, logoHeader, rule, selector, selectors, spinner, spinnerClassnames, styles, v, _j, _ref;
      defaultOptions = this.constructor._defaultOptions;
      this.options = {};
      this.loaded = false;
      this.finishing = false;
      for (k in defaultOptions) {
        v = defaultOptions[k];
        this.options[k] = options[k] != null ? options[k] : v;
      }
      styles = '';
      this._loadingElem = document.createElement('div');
      this._loadingHtmlToDisplay = [];
      this._loadingElem.className = Class.LOADING_SCREEN;
      if (this.options.backgroundColor != null) {
        this._loadingElem.style.backgroundColor = this.options.backgroundColor;
      }
      this._loadingElem.innerHTML = this.options.template;
      if (this.options.logo) {
        logo = document.createElement('img');
        logo.className = Class.LOADING_LOGO;
        logoHeader = this._loadingElem.getElementsByClassName('pg-loading-logo-header')[0];
        logoHeader.insertBefore(logo, logoHeader.firstChild);
        if (this.options.logoMaxSize) {
          if (typeof this.options.logoMaxSize === 'string' || this.options.logoMaxSize instanceof String) {
            styles += ".pg-loading-screen .pg-loading-logo-header img { max-height: " + this.options.logoMaxSize + "; max-width: " + this.options.logoMaxSize + "; }";
          } else {
            styles += ".pg-loading-screen .pg-loading-logo-header img { max-height: " + this.options.logoMaxSize[1] + "; max-width: " + this.options.logoMaxSize[0] + "; }";
          }
        }
      }
      this._loadingHtmlElem = this._loadingElem.getElementsByClassName(Class.LOADING_HTML)[0];
      if (this._loadingHtmlElem) {
        if (this.options.loadingHtml) {
          this._loadingHtmlElem.innerHTML = this.options.loadingHtml;
        }
        if (this.options.loadingMessage) {
          this._loadingHtmlElem.innerHTML = "<div class=\"" + Class.LOADING_MESSAGE + "\">" + this.options.loadingMessage + "</div>";
        }
      }
      this._loadingMsg = this._loadingHtmlElem.getElementsByClassName(Class.LOADING_MESSAGE)[0];
      if ((this._loadingMsg != null) && this.options.appendAnimatedEllipsis) {
        addClass(Class.ELLIPSIS, this._loadingMsg);
      }
      if ((this.options.spinnerBefore || this.options.spinnerAfter) && (this._loadingMsg != null)) {
        this._loadingMsgParent = this._loadingMsg.parentNode;
        spinner = document.createElement('div');
        spinnerClassnames = this.options.spinnerBefore || this.options.spinnerAfter;
        spinner.innerHTML = Spinner[spinnerClassnames];
        spinner.className = (spinnerClassnames === 'pulse' ? 'sk-spinner sk-spinner-' : 'sk-') + spinnerClassnames;
        if (this.options.spinnerColor) {
          selectors = spinner.className.split(' ');
          for (i = _j = _ref = selectors.length - 1; _ref <= 0 ? _j <= 0 : _j >= 0; i = _ref <= 0 ? ++_j : --_j) {
            selectors[i] = "." + selectors[i];
          }
          selector = selectors.join('');
          rule = "background-color: " + this.options.spinnerColor + " !important;";
          switch (spinnerClassnames) {
            case 'pulse':
            case 'rotating-plane':
              styles += "" + selector + " { " + rule + " }";
              break;
            case 'circle':
            case 'fading-circle':
            case 'folding-cube':
              styles += "" + selector + " > div::before { " + rule + " }";
              break;
            default:
              styles += "" + selector + " > div { " + rule + " }";
          }
        }
        if (this.options.spinnerBefore) {
          addClass(Class.SPINNER_BEFORE, this._loadingHtmlElem);
          this._loadingMsgParent.insertBefore(spinner, this._loadingMsgParent.firstChild);
        } else {
          addClass(Class.SPINNER_AFTER, this._loadingHtmlElem);
          this._loadingMsgParent.appendChild(spinner);
        }
      }
      this._readyToShowLoadingHtml = false;
      if (this.options.logo != null) {
        this._logoElem = this._loadingElem.getElementsByClassName(Class.LOADING_LOGO)[0];
        if (this._logoElem != null) {
          this._logoElem.src = this.options.logo;
        }
      }
      removeClass(Class.LOADED, this.options.container);
      addClass(Class.LOADING, this.options.container);
      this.options.container.appendChild(this._loadingElem);
      addClass(Class.LOADING, this._loadingElem);
      this._onLoadedCallback = this.options.onLoadedCallback;
      if ('' !== styles) {
        addCss(styles);
      }
      listener = (function(_this) {
        return function(evt) {
          _this.loaded = true;
          _this._readyToShowLoadingHtml = true;
          addClass(Class.LOADED, _this._loadingHtmlElem);
          if (animationSupport) {
            _this._loadingHtmlElem.removeEventListener(animationEvent, listener);
          }
          if (_this._loadingHtmlToDisplay.length > 0) {
            _this._changeLoadingHtml();
          }
          if (_this.finishing) {
            if (evt != null) {
              evt.stopPropagation();
            }
            return _this._finish();
          }
        };
      })(this);
      if (this._loadingHtmlElem != null) {
        if (animationSupport) {
          this._loadingHtmlElem.addEventListener(animationEvent, listener);
        } else {
          listener();
        }
        this._loadingHtmlListener = (function(_this) {
          return function() {
            _this._readyToShowLoadingHtml = true;
            removeClass(Class.LOADING, _this._loadingHtmlElem);
            if (transitionSupport) {
              _this._loadingHtmlElem.removeEventListener(transitionEvent, _this._loadingHtmlListener);
            }
            if (_this._loadingHtmlToDisplay.length > 0) {
              return _this._changeLoadingHtml();
            }
          };
        })(this);
        this._removingHtmlListener = (function(_this) {
          return function() {
            _this._loadingHtmlElem.innerHTML = _this._loadingHtmlToDisplay.shift();
            removeClass(Class.REMOVING, _this._loadingHtmlElem);
            addClass(Class.LOADING, _this._loadingHtmlElem);
            if (transitionSupport) {
              _this._loadingHtmlElem.removeEventListener(transitionEvent, _this._removingHtmlListener);
              return _this._loadingHtmlElem.addEventListener(transitionEvent, _this._loadingHtmlListener);
            } else {
              return _this._loadingHtmlListener();
            }
          };
        })(this);
      }
    }

    PleaseWait.prototype.finish = function(immediately, onLoadedCallback) {
      if (immediately == null) {
        immediately = false;
      }
      if (window.document.hidden) {
        immediately = true;
      }
      this.finishing = true;
      if (onLoadedCallback != null) {
        this.updateOption('onLoadedCallback', onLoadedCallback);
      }
      if (this.loaded || immediately) {
        return this._finish(immediately);
      }
    };

    PleaseWait.prototype.updateMessage = function(message) {
      if (this._loadingMsg != null) {
        return this._loadingMsg.innerHTML = message;
      }
    };

    PleaseWait.prototype.updateOption = function(option, value, animate, immediately) {
      if (immediately == null) {
        immediately = false;
      }
      switch (option) {
        case 'backgroundColor':
          return this._loadingElem.style.backgroundColor = value;
        case 'logo':
          return this._logoElem.src = value;
        case 'loadingHtml':
          return this.updateLoadingHtml(value, animate, immediately);
        case 'onLoadedCallback':
          return this._onLoadedCallback = value;
        default:
          throw new Error("Unknown option '" + option + "'");
      }
    };

    PleaseWait.prototype.updateOptions = function(options) {
      var k, v, _results;
      if (options == null) {
        options = {};
      }
      _results = [];
      for (k in options) {
        v = options[k];
        _results.push(this.updateOption(k, v));
      }
      return _results;
    };

    PleaseWait.prototype.updateLoadingHtml = function(loadingHtml, animate, immediately) {
      if (immediately == null) {
        immediately = false;
      }
      if (this._loadingHtmlElem == null) {
        throw new Error('The loading template does not have an element of class "pg-loading-html"');
      }
      if (immediately) {
        this._loadingHtmlToDisplay = [loadingHtml];
        this._readyToShowLoadingHtml = true;
      } else {
        this._loadingHtmlToDisplay.push(loadingHtml);
      }
      if (this._readyToShowLoadingHtml) {
        return this._changeLoadingHtml(animate);
      }
    };

    PleaseWait.prototype._changeLoadingHtml = function(animate) {
      if (animate == null) {
        animate = this.options.animateOptionUpdate;
      }
      this._readyToShowLoadingHtml = false;
      this._loadingHtmlElem.removeEventListener(transitionEvent, this._loadingHtmlListener);
      this._loadingHtmlElem.removeEventListener(transitionEvent, this._removingHtmlListener);
      removeClass(Class.LOADING, this._loadingHtmlElem);
      removeClass(Class.REMOVING, this._loadingHtmlElem);
      if (animate == null) {
        animate = false;
      }
      if (transitionSupport && animate) {
        addClass(Class.REMOVING, this._loadingHtmlElem);
        return this._loadingHtmlElem.addEventListener(transitionEvent, this._removingHtmlListener);
      } else {
        return this._removingHtmlListener();
      }
    };

    PleaseWait.prototype._finish = function(immediately) {
      var listener;
      if (immediately == null) {
        immediately = false;
      }
      if (this._loadingElem == null) {
        return;
      }
      addClass(Class.LOADED, this.options.container);
      if (typeof this._onLoadedCallback === 'function') {
        this._onLoadedCallback.apply(this);
      }
      listener = (function(_this) {
        return function() {
          _this.options.container.removeChild(_this._loadingElem);
          removeClass(Class.LOADING, _this.options.container);
          if (animationSupport) {
            _this._loadingElem.removeEventListener(animationEvent, listener);
          }
          return _this._loadingElem = null;
        };
      })(this);
      if (!immediately && animationSupport) {
        addClass(Class.LOADED, this._loadingElem);
        return this._loadingElem.addEventListener(animationEvent, listener);
      } else {
        return listener();
      }
    };

    return PleaseWait;

  })();
  pleaseWait = function(options) {
    if (options == null) {
      options = {};
    }
    return new PleaseWait(options);
  };
  exports.pleaseWait = pleaseWait;
  return pleaseWait;
});

(function() {
  var Logger, console, defaults, extend, fake, glob, l, loggerInstances, method, methods, noop, unformatableMethods, _defineMethods, _formatLabels, _getStyles, _i, _labelsMatchOne, _len, _ref,
    __slice = [].slice;

  methods = ['assert', 'debug', 'dirxml', 'error', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'warn'];

  unformatableMethods = ['clear', 'count', 'dir', 'exception', 'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeStamp', 'timeEnd', 'trace'];

  noop = function() {};

  glob = typeof global !== "undefined" && global !== null ? global : window;

  console = (glob.console = glob.console || {});

  fake = {};

  _ref = methods.concat(unformatableMethods);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    method = _ref[_i];
    if (!console[method]) {
      console[method] = noop;
    }
    fake[method] = noop;
  }

  if (!Array.isArray) {
    Array.isArray = function(vArg) {
      return Object.prototype.toString.call(vArg) === "[object Array]";
    };
  }

  extend = function() {
    var args, destObj, key, obj, value, _j, _len1;
    destObj = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_j = 0, _len1 = args.length; _j < _len1; _j++) {
      obj = args[_j];
      for (key in obj) {
        value = obj[key];
        if (obj.hasOwnProperty(key)) {
          destObj[key] = value;
        }
      }
    }
    return destObj;
  };

  defaults = {
    enabled: true,
    styled: true
  };

  _formatLabels = function() {
    var l, n, outup, _label;
    _label = function(l) {
      if (l.label) {
        return "" + (l.__style && l.__settings.styled ? '%c' : '') + l.label;
      } else {
        return '';
      }
    };
    l = this;
    outup = [];
    if ((n = _label(l)) !== '') {
      outup.push(n);
    }
    while (l = l.__parent) {
      if ((n = _label(l)) !== '') {
        outup.unshift(n);
      }
    }
    if (outup.length) {
      return outup.join('');
    } else {
      return void 0;
    }
  };

  _getStyles = function() {
    var l, styles, _style;
    _style = function(s) {
      var k, v;
      return ((function() {
        var _results;
        _results = [];
        for (k in s) {
          v = s[k];
          _results.push(s.hasOwnProperty(k) ? "" + k + ":" + v + ";" : void 0);
        }
        return _results;
      })()).join('');
    };
    l = this;
    styles = l.__style && l.__settings.styled ? [_style(l.__style)] : [];
    while (l = l.__parent) {
      if (l.__style) {
        styles.unshift(_style(l.__style));
      }
    }
    return styles;
  };

  _labelsMatchOne = function(strs) {
    var l, str, _j, _len1, _ref1, _ref2;
    for (_j = 0, _len1 = strs.length; _j < _len1; _j++) {
      str = strs[_j];
      l = this;
      if ((_ref1 = l.label) != null ? _ref1.match(str) : void 0) {
        return true;
      }
      while (l = l.__parent) {
        if ((_ref2 = l.label) != null ? _ref2.match(str) : void 0) {
          return true;
        }
      }
    }
    return false;
  };

  _defineMethods = function() {
    var args, label, meth, styles, _j, _k, _len1, _len2, _ref1, _results;
    this.__out = this.__settings.enabled ? console : fake;
    if (this.__filters.only.length && !_labelsMatchOne.bind(this)(this.__filters.only)) {
      this.__out = fake;
    }
    if (this.__filters.exclude.length && _labelsMatchOne.bind(this)(this.__filters.exclude)) {
      this.__out = fake;
    }
    for (_j = 0, _len1 = unformatableMethods.length; _j < _len1; _j++) {
      meth = unformatableMethods[_j];
      this[meth] = this.__out[meth].bind(this.__out);
    }
    label = _formatLabels.bind(this)();
    styles = _getStyles.bind(this)();
    args = label ? [label].concat(__slice.call(styles)) : [];
    _results = [];
    for (_k = 0, _len2 = methods.length; _k < _len2; _k++) {
      meth = methods[_k];
      _results.push(this[meth] = (_ref1 = this.__out[meth]).bind.apply(_ref1, [this.__out].concat(__slice.call(args))));
    }
    return _results;
  };

  Logger = (function() {
    function Logger(label, __style, __parent) {
      this.label = label;
      this.__style = __style != null ? __style : null;
      this.__parent = __parent != null ? __parent : null;
      this.__settings = this.__parent ? this.__parent.__settings : defaults;
      this.__filters = this.__parent ? this.__parent.__filters : {
        only: [],
        exclude: []
      };
      _defineMethods.bind(this)();
    }

    Logger.prototype.parent = function() {
      return this.__parent;
    };

    Logger.prototype.child = function(label, style, closure) {
      var ret;
      ret = new Logger(label, style, this);
      loggerInstances.push(ret);
      if (typeof closure === 'function') {
        closure(ret);
      }
      return ret;
    };

    return Logger;

  })();

  l = new Logger;

  loggerInstances = [l];

  l.config = function(conf) {
    var instance, _j, _len1;
    if (typeof conf !== 'object') {
      return this.__settings;
    }
    for (_j = 0, _len1 = loggerInstances.length; _j < _len1; _j++) {
      instance = loggerInstances[_j];
      instance.__settings = extend({}, defaults, conf);
      _defineMethods.bind(instance)();
    }
  };

  l.filter = function() {
    return {
      only: function(labels) {
        var instance, _j, _len1;
        if (typeof labels === 'string') {
          labels = [labels];
        }
        if (!Array.isArray(labels)) {
          return;
        }
        for (_j = 0, _len1 = loggerInstances.length; _j < _len1; _j++) {
          instance = loggerInstances[_j];
          instance.__filters.only = labels;
          _defineMethods.bind(instance)();
        }
      },
      exclude: function(labels) {
        var instance, _j, _len1;
        if (typeof labels === 'string') {
          labels = [labels];
        }
        if (!Array.isArray(labels)) {
          return;
        }
        for (_j = 0, _len1 = loggerInstances.length; _j < _len1; _j++) {
          instance = loggerInstances[_j];
          instance.__filters.exclude = labels;
          _defineMethods.bind(instance)();
        }
      }
    };
  };

  (typeof exports !== "undefined" && exports !== null ? exports : window).logger = l;

}).call(this);

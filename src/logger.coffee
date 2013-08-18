methods = [
	'assert', 'debug', 'dirxml', 'error', 'group',
	'groupCollapsed', 'groupEnd', 'info', 'log', 'warn'
]
unformatableMethods = [
	'clear', 'count', 'dir', 'exception', 'markTimeline', 'profile', 'profileEnd',
	'table', 'time', 'timeStamp', 'timeEnd', 'trace'
]

# Add compat console object if not available
noop = ->
glob = (global ? window)
console = (glob.console = glob.console or {})
fake = {}
for method in methods.concat unformatableMethods
	(console[method] = noop if not console[method])
	fake[method] = noop

if !Array.isArray
	Array.isArray = (vArg) -> Object::toString.call(vArg) is "[object Array]"

extend = (destObj, args...) ->
	for obj in args
		(destObj[key] = value if obj.hasOwnProperty key) for key, value of obj
	return destObj

defaults =
	enabled: yes
	styled:  yes

_formatLabels = () ->
	_label = (l) -> if l.label then "#{if l.__style and l.__settings.styled then '%c' else ''}#{l.label}" else ''
	l = @
	outup = []
	outup.push(n) if (n = _label l) isnt ''
	while l = l.__parent
		outup.unshift(n) if (n = _label l) isnt ''
	return if outup.length then outup.join '' else undefined

_getStyles = () ->
	_style = (s) -> (("#{k}:#{v};" if s.hasOwnProperty k) for k, v of s).join ''
	l = @
	styles = if l.__style and l.__settings.styled then [_style l.__style] else []
	while l = l.__parent
		styles.unshift(_style l.__style) if l.__style
	return styles

_labelsMatchOne = (strs) ->
	for str in strs
		l = @
		return yes if l.label?.match str
		while l = l.__parent
			return yes if l.label?.match str
	return no

_defineMethods = () ->
	@__out = if @__settings.enabled then console else fake

	# Filter output according to __filter arrays
	if @__filters.only.length and not _labelsMatchOne.bind(@) @__filters.only
		@__out = fake
	if @__filters.exclude.length and _labelsMatchOne.bind(@) @__filters.exclude
		@__out = fake

	# some console method doesn't support styles and multiple params
	# fallback to normal call in this case
	for meth in unformatableMethods
		@[meth] = @__out[meth].bind @__out

	label = _formatLabels.bind(@)()
	styles = _getStyles.bind(@)()
	args = if label then [label, styles...] else []
	for meth in methods
		@[meth] = @__out[meth].bind @__out, args...


class Logger

	constructor: (@label, @__style=null, @__parent=null) ->
		@__settings = if @__parent then @__parent.__settings else defaults
		@__filters  = if @__parent then @__parent.__filters else only: [], exclude: []
		_defineMethods.bind(@)()

	parent: () -> @__parent

	child: (label, style, closure) ->
		ret = new Logger label, style, @
		loggerInstances.push ret
		closure(ret) if typeof closure is 'function'
		return ret

l = new Logger
loggerInstances = [l]
l.config = (conf) ->
	# without parameter, return current conf
	if typeof conf isnt 'object'
		return @__settings

	# otherwise, update conf
	for instance in loggerInstances
		instance.__settings = extend {}, defaults, conf
		_defineMethods.bind(instance)()
	return

l.filter = () ->
	only: (labels) ->
		labels = [labels] if typeof labels is 'string'
		return if not Array.isArray labels

		for instance in loggerInstances
			instance.__filters.only = labels
			_defineMethods.bind(instance)()
		return

	exclude: (labels) ->
		labels = [labels] if typeof labels is 'string'
		return if not Array.isArray labels

		for instance in loggerInstances
			instance.__filters.exclude = labels
			_defineMethods.bind(instance)()
		return

(exports ? window).logger = l


chai = require 'chai'
sinon = require 'sinon'

expect = chai.expect

logger = require('../src/logger').logger

defaultConf =
	enabled: yes
	styled:  yes

describe 'logger', ->

	it 'should be defined', ->
		expect(logger).not.to.equal undefined


	describe 'logger.config', ->

		it 'should be function', ->
			expect(logger).itself.to.respondTo 'config'

		it 'should return default config object', ->
			conf = logger.config()
			expect(conf).to.be.an 'object'
			expect(conf).to.have.property 'enabled', defaultConf.enabled
			expect(conf).to.have.property 'styled', defaultConf.styled

		it 'should allow to define config', ->
			logger.config
				enabled: no
				styled:  no
			conf = logger.config()
			expect(conf).to.have.property 'enabled', no
			expect(conf).to.have.property 'styled', no

		after ->
			logger.config defaultConf


	child1 = {
		name: 'child1'
		style: {color:'white', background:'blue'},
		cName: "%cchild1"
		cSytle: "color:white;background:blue;"
		instance: null
	}
	child2 = {
		name: 'child2'
		style: {color:'white', background:'green'},
		cName: "%cchild2"
		cSytle: "color:white;background:green;"
		instance: null
	}

	describe 'logger.child', ->

		it 'should be function', ->
			expect(logger).to.respondTo 'child'

		it 'should return another logger', ->
			child1.instance = logger.child child1.name, child1.style
			expect(child1.instance).to.be.an 'object'
			expect(child1.instance).to.respondTo 'child'
			child2.instance = child1.instance.child child2.name, child2.style
			expect(child2.instance).to.be.an 'object'

	describe 'logger.parent', ->

		it 'should be a function', ->
			expect(logger).to.respondTo 'parent'
		it 'should return null when called on logger', ->
			expect(logger.parent()).to.be.null
		it 'should return parent object when called on child', ->
			expect(child1.instance.parent()).to.be.equal(logger)
			expect(child2.instance.parent()).to.be.equal(child1.instance)


	describe 'console API:', ->
		methods = [
			'log', 'assert', 'debug', 'dirxml', 'error', 'group',
			'groupCollapsed', 'groupEnd', 'info', 'warn'
		]
		unformatableMethods = [
			'clear', 'count', 'dir', 'exception', 'markTimeline', 'profile',
			'profileEnd', 'table', 'time', 'timeStamp', 'timeEnd', 'trace'
		]

		realConsole = console
		spyConsoleCallWithArgs = (loggerInstance, conf, method, args, closure) ->
			sinon.spy(console, method)
			# the config method redefines console bindings
			# We need to call it here for the spy to be called
			logger.config conf

			# this one makes test output really messy,
			# but the test is OK so...
			loggerInstance[method] args...

			closure()
			# restore the original console method
			console[method].restore()
			logger.config defaultConf

		for method in methods
			do (method) ->

				describe method, ->
					it "logger.#{method} should be function", ->
						expect(logger).to.respondTo method

					it "child1.#{method} should be function", ->
						expect(child1.instance).to.respondTo method

					it "child2.#{method} should be a function", ->
						expect(child2.instance).to.respondTo method

					it "logger.#{method} should call console.#{method} with the exact same parameters", ->
						args = ['hello', 1234, {key1: 'value', key2: 0}, true]

						spyConsoleCallWithArgs logger, defaultConf, method, args, ->
							expect(console[method].calledOnce).to.be.true
							expect(console[method].calledWithExactly args...).to.be.true

					it "child1.#{method} should call console.#{method} with extra parameters", ->
							args = ['hello', 1234, {key1: 'value', key2: 0}, true]

							spyConsoleCallWithArgs child1.instance, defaultConf, method, args, ->
								expect(console[method].calledOnce).to.be.true
								expect(console[method].calledWithExactly child1.cName, child1.cSytle, args...).to.be.true

					it "child2.#{method} should call console.#{method} with extra parameters", ->
							args = ['hello', 1234, {key1: 'value', key2: 0}, true]

							spyConsoleCallWithArgs child2.instance, defaultConf, method, args, ->
								expect(console[method].calledOnce).to.be.true
								expect(console[method].calledWithExactly "#{[child1.cName,child2.cName].join('')}", child1.cSytle, child2.cSytle, args...).to.be.true

					it "logger.#{method} shouldn't call console when disabled", ->
						args = ['hello', 1234, {key1: 'value', key2: 0}, true]

						conf = enabled: no
						spyConsoleCallWithArgs logger, conf, method, args, ->
							expect(console[method].called).to.be.false

					it "child1.#{method} shouldn't call console when disabled", ->
						args = ['hello', 1234, {key1: 'value', key2: 0}, true]

						conf = enabled: no
						spyConsoleCallWithArgs child1.instance, conf, method, args, ->
							expect(console[method].called).to.be.false

					it "child2.#{method} shouldn't call console when disabled", ->
						args = ['hello', 1234, {key1: 'value', key2: 0}, true]

						conf = enabled: no
						spyConsoleCallWithArgs child2.instance, conf, method, args, ->
							expect(console[method].called).to.be.false



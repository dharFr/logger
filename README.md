# Not maintained anymore...

*logger.js* is not maintained anymore. It was an experimental proof-of-concept project and has been replaced with [dharFr/badgee](//github.com/dharFr/badgee).

# logger.js

browser console improved

## What is `logger`?

It's an add-on to the browser console, created to improve readability and flexibility. It provides the same API than your brower console, adding the folling features :
 - enabling/disabling logs
 - categorizing logs : logs categorizes are given a name and style
 - filtering logs by category

## Compatibility

Work pretty well in Chrome and Firebug. Safari and Firefox Web Console doesn't support styling output

## Install

Not published on bower yet... I guess I need to find a better name before publish it ^^

For now, you'll have to `git clone` the repo, run `npm install && grunt` in your terminal to build CoffeeScript source and open `test/index.html` in your browser.

## API

### `logger.config(settings)`

 - `settings`
   Type: Object
   A set of key/value pairs to configure the loggers
   
   - `enabled` (default: `true`)  
     Type: boolean  
     If set to `false`, logs will no longer be displayed to the console. Otherwise logs are displayed as usual

   - `styled` (default: `true`)  
      Type: boolean  
      If set to `false`, label prefixes will be displayed with default output style. Otherwise, label prefixes will be formated as defined by `style` property (see ).

### `logger.child(label, style, [closure])`

 - `label`  
   Type: String  
   The name of the logger
   
 - `style`  
   Type: Object  
   A set of key/value pairs to configure the style of the label, mostly CSS keys/values
   
 - `closure`  
   Type: Function (Logger logger)  
   A callback function to be called when the new named logger is created. The function gets passed the newly created logger as a parameter.

The `child` function creates and returns a new logger instance, for which every output will be prefixed with the provided `label`, formated according to provided `style` definition.

### `logger.filter().only(labels)`

 - `labels`  
   Type: String | Array  
   
### `logger.filter().exclude(labels)`

 - `labels`  
   Type: String | Array  
   

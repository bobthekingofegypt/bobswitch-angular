# bobswitch-angular 
[![Build Status](https://travis-ci.org/bobthekingofegypt/bobswitch-angular.png?branch=master)](https://travis-ci.org/bobthekingofegypt/bobswitch-angular)
[![Coverage Status](https://coveralls.io/repos/bobthekingofegypt/bobswitch-angular/badge.png?branch=master)](https://coveralls.io/r/bobthekingofegypt/bobswitch-angular?branch=master)
## About

Bobswitch is an implementation of the simple card game switch and this is a font end created with angular that connects to the bobswitch-python socket server.

## Compile bobswitch-angular 
You have options.

1. `grunt build` - will compile the app preserving individual files (when run, files will be loaded on-demand)
2. `grunt` or `grunt dev` - same as `grunt` but will watch for file changes and recompile on-the-fly
3. `grunt prod` - will compile using optimizations.  This will create one JavaScript file and one CSS file to demonstrate the power of [r.js](http://requirejs.org/docs/optimization.html), the build optimization tool for RequireJS.  And take a look at the index.html file.  Yep - it's minified too.
4. `grunt test` - will compile the app and run all unit tests

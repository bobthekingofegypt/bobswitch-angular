class Directive
    constructor: ($timeout) ->
        scope = { trigger: "@focusMe" }

        link = (scope, element) ->
            scope.$watch 'trigger', (value) ->
                console.log "triggered", value
                if value == "true"
                    $timeout ->
                        element[0].focus()
    
        return {
            link
            scope
        }

angular.module('app').directive 'focusMe', ['$timeout', Directive]

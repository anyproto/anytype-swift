enum CodeLanguage: String, CaseIterable {
    case abap
    case arduino
    case bash
    case basic
    case c
    case csharp
    case cpp
    case clojure
    case coffeescript
    case css
    case dart
    case diff
    case docker
    case elixir
    case elm
    case erlang
    case flow
    case fortran
    case fsharp
    case gherkin
    case graphql
    case groovy
    case go
    case haskell
    case html
    case json
    case javascript
    case java
    case kotlin
    case latex
    case less
    case lisp
    case livescript
    case lua
    case markup
    case markdown
    case makefile
    case matlab
    case nginx
    case objc
    case ocaml
    case pascal
    case perl
    case php
    case powershell
    case plain
    case prolog
    case python
    case reason
    case ruby
    case rust
    case r
    case sass
    case scala
    case scheme
    case scss
    case shell
    case sql
    case swift
    case typescript
    case vbnet
    case verilog
    case vhdl
    case vb
    case wasm
    case wolfram
    case xml
    case yaml
    
    var title: String {
        switch self {
        case .abap:
            return "ABAP"
        case .arduino:
            return "Arduino"
        case .bash:
            return "Bash"
        case .basic:
            return "BASIC"
        case .c:
            return "C"
        case .csharp:
            return "C#"
        case .cpp:
            return "C++"
        case .clojure:
            return "Clojure"
        case .coffeescript:
            return "CoffeeScript"
        case .css:
            return "CSS"
        case .dart:
            return "Dart"
        case .diff:
            return "Diff"
        case .docker:
            return "Docker"
        case .elixir:
            return "Elixir"
        case .elm:
            return "Elm"
        case .erlang:
            return "Erlang"
        case .flow:
            return "Flow"
        case .fortran:
            return "Fortran"
        case .fsharp:
            return "F#"
        case .gherkin:
            return "Gherkin"
        case .graphql:
            return "GraphQL"
        case .groovy:
            return "Groovy"
        case .go:
            return "Go"
        case .haskell:
            return "Haskell"
        case .html:
            return "HTML"
        case .json:
            return "JSON"
        case .javascript:
            return "JavaScript"
        case .java:
            return "Java"
        case .kotlin:
            return "Kotlin"
        case .latex:
            return "LaTeX"
        case .less:
            return "Less"
        case .lisp:
            return "Lisp"
        case .livescript:
            return "LiveScript"
        case .lua:
            return "Lua"
        case .markup:
            return "Markup"
        case .markdown:
            return "Markdown"
        case .makefile:
            return "Makefile"
        case .matlab:
            return "MATLAB"
        case .nginx:
            return "Nginx"
        case .objc:
            return "Objective-C"
        case .ocaml:
            return "OCaml"
        case .pascal:
            return "Pascal"
        case .perl:
            return "Perl"
        case .php:
            return "PHP"
        case .powershell:
            return "Power Shell"
        case .plain:
            return "Plain Text"
        case .prolog:
            return "Prolog"
        case .python:
            return "Python"
        case .reason:
            return "Reason"
        case .ruby:
            return "Ruby"
        case .rust:
            return "Rust"
        case .r:
            return "R"
        case .sass:
            return "Sass"
        case .scala:
            return "Scala"
        case .scheme:
            return "Scheme"
        case .scss:
            return "SСSS"
        case .shell:
            return "Shell"
        case .sql:
            return "SQL"
        case .swift:
            return "Swift"
        case .typescript:
            return "TypeScript"
        case .vbnet:
            return "Vb.Net"
        case .verilog:
            return "Verilog"
        case .vhdl:
            return "VHDL"
        case .vb:
            return "Visual Basic"
        case .wasm:
            return "WebAssembly"
        case .wolfram:
            return "Wolfram"
        case .xml:
            return "XML"
        case .yaml:
            return "YAML"
        }
    }
    
    var higlighterCode: String {
        switch self {
        case .abap:
            return "sql"
        case .flow:
            return "plaintext"
        case .markup:
            return "html"
        case .plain:
            return "plaintext"
        case .reason:
            return "reasonml"
        case .sass:
            return "sas"
        case .wolfram:
            return "c"
        default:
            return rawValue
        }
    }
    
    func toMiddleware() -> String {
        rawValue
    }
    
    static func create(middleware: String?) -> CodeLanguage {
        guard let middleware = middleware else {
            return .plain
        }

        return CodeLanguage(rawValue: middleware) ?? .plain
    }
}

enum CodeLanguage: String, CaseIterable {
    case arduino
    case bash
    case basic
    case cpp
    case clojure
    case coffeescript
    case css
    case dart
    case diff
    case dockerfile
    case elixir
    case elm
    case erlang
    case fortran
    case gherkin
    case groovy
    case go
    case haskell
    case json
    case javascript
    case java
    case kotlin
    case less
    case lisp
    case livescript
    case lua
    case markdown
    case makefile
    case matlab
    case nginx
    case objectivec
    case ocaml
    case perl
    case php
    case powershell
    case prolog
    case python
    case reasonml
    case ruby
    case rust
    case sas
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
    case xml
    case yaml
    
    func toMiddleware() -> String {
        switch self {
        case .dockerfile: return "docker"
        case .objectivec: return "objc"
        case .reasonml: return "reason"
        case .sas: return "sass"
        default: return self.rawValue
        }
    }
    
    static func create(middleware: String?) -> CodeLanguage {
        guard let middleware = middleware else {
            return .swift
        }
        
        switch middleware {
        case "docker": return .dockerfile
        case "objc": return .objectivec
        case "reason": return .reasonml
        case "sass": return .sas
        default: return CodeLanguage(rawValue: middleware) ?? .swift
        }
    }
}

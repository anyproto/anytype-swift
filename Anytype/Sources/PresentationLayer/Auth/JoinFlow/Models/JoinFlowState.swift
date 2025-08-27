import SwiftUI

final class JoinFlowState {
    var soul = ""
    var mnemonic = "" {
        didSet {
            keyShown = false
        }
    }
    var email = ""
    var keyShown = false
    
    var personaOptions = [InfoSelectionOption]()
    var useCaseOptions = [InfoSelectionOption]()
}

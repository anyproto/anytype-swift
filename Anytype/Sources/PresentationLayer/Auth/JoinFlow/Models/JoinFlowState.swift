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
}

import SwiftUI

final class JoinFlowState {
    var soul = ""
    var mnemonic = "" {
        didSet {
            keyShown = false
        }
    }
    var keyShown = false
}

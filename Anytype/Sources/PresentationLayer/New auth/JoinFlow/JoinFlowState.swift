import SwiftUI

final class JoinFlowState {
    var soul = ""
    var inviteCode = "elbrus" // temp, wait for the middle release
    var mnemonic = "" {
        didSet {
            keyShown = false
        }
    }
    var keyShown = false
}

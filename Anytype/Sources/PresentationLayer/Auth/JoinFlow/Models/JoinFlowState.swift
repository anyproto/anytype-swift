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
    
    // options
    var selectedPersonaOptions = [InfoSelectionOption]()
    var selectedUseCaseOptions = [InfoSelectionOption]()
    
    let personaOptions = JoinSelectionType.persona.personaOptions.shuffled() + JoinSelectionType.otherOptions
    let usecaseOptions = JoinSelectionType.useCase.useCaseOptions.shuffled() + JoinSelectionType.otherOptions
}

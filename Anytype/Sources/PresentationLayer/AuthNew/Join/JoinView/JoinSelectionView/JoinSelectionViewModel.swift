import SwiftUI
import Services

@MainActor
final class JoinSelectionViewModel: ObservableObject {
    
    @Published var selectedOptions = [InfoSelectionOption]()
    
    let type: JoinSelectionType
    private let state: JoinFlowState
    
    private weak var output: (any JoinBaseOutput)?

    
    init(type: JoinSelectionType, state: JoinFlowState, output: (any JoinBaseOutput)?) {
        self.type = type
        self.state = state
        
        switch type {
        case .persona:
            self.selectedOptions = state.selectedPersonaOptions
        case .useCase:
            self.selectedOptions = state.selectedUseCaseOptions
        }
        
        self.output = output
    }
    
    func onAppear() {
        switch type {
        case .persona:
            AnytypeAnalytics.instance().logScreenOnboarding(step: .persona)
        case .useCase:
            AnytypeAnalytics.instance().logScreenOnboarding(step: .useCase)
        }
    }
    
    func onSelectionChanged(_ option: InfoSelectionOption) {
        if selectedOptions.contains(option) {
            selectedOptions.removeAll { $0.id == option.id }
            removeOptionsFromState(option)
        } else {
            if type.isMultiSelection {
                selectedOptions.append(option)
            } else {
                selectedOptions = [option]
            }
            appendOptionsToState(option)
        }
    }
    
    func onNextAction() {
        guard selectedOptions.isNotEmpty else {
            return
        }        
        onSuccess()
    }
    
    func onSkipAction() {
        onSuccess()
    }
    
    func options() -> [InfoSelectionOption] {
        switch type {
        case .persona: return state.personaOptions
        case .useCase: return state.usecaseOptions
        }
    }
    
    private func onSuccess() {
        output?.onNext()
    }
    
    private func appendOptionsToState(_ option: InfoSelectionOption) {
        switch type {
        case .persona:
            if type.isMultiSelection {
                state.selectedPersonaOptions.append(option)
            } else {
                state.selectedPersonaOptions = [option]
            }
        case .useCase:
            if type.isMultiSelection {
                state.selectedUseCaseOptions.append(option)
            } else {
                state.selectedUseCaseOptions = [option]
            }
        }
    }
    
    private func removeOptionsFromState(_ option: InfoSelectionOption) {
        switch type {
        case .persona:
            state.selectedPersonaOptions.removeAll { $0.id == option.id }
        case .useCase:
            state.selectedUseCaseOptions.removeAll { $0.id == option.id }
        }
    }
}

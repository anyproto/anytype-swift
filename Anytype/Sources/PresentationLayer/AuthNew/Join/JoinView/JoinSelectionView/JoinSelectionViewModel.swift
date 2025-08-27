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
            self.selectedOptions = state.personaOptions
        case .useCase:
            self.selectedOptions = state.useCaseOptions
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
    
    private func onSuccess() {
        output?.onNext()
    }
    
    private func appendOptionsToState(_ option: InfoSelectionOption) {
        switch type {
        case .persona:
            if type.isMultiSelection {
                state.personaOptions.append(option)
            } else {
                state.personaOptions = [option]
            }
        case .useCase:
            if type.isMultiSelection {
                state.useCaseOptions.append(option)
            } else {
                state.useCaseOptions = [option]
            }
        }
    }
    
    private func removeOptionsFromState(_ option: InfoSelectionOption) {
        switch type {
        case .persona:
            state.personaOptions.removeAll { $0.id == option.id }
        case .useCase:
            state.useCaseOptions.removeAll { $0.id == option.id }
        }
    }
}

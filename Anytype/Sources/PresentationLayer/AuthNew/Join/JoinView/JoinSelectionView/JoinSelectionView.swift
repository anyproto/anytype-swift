import SwiftUI
import AnytypeCore

struct JoinSelectionView: View {
    
    @StateObject private var model: JoinSelectionViewModel
    
    init(type: JoinSelectionType, state: JoinFlowState, output: (any JoinBaseOutput)?) {
        _model = StateObject(wrappedValue: JoinSelectionViewModel(type: type, state: state, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            InfoSelectionView(
                title: model.type.title,
                description: model.type.description,
                options: model.type.oprions,
                selectedOptions: model.selectedOptions,
                onSelect: { option in
                    model.onSelectionChanged(option)
                }
            )
            
            Spacer()
            
            buttons
        }
        .onAppear {
            model.onAppear()
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 8) {
            StandardButton(
                Loc.continue,
                style: .primaryOvalLarge,
                action: {
                    model.onNextAction()
                }
            )
            .disabled(model.selectedOptions.isEmpty)
            
            StandardButton(
                Loc.skip,
                style: .linkLarge,
                action: {
                    model.onSkipAction()
                }
            )
        }
    }
}

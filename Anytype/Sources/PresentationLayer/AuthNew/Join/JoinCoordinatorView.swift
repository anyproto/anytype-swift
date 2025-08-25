import SwiftUI

struct JoinCoordinatorView: View {
    
    @StateObject private var model: JoinCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(state: JoinFlowState) {
        self._model = StateObject(wrappedValue: JoinCoordinatorViewModel(state: state))
    }
    
    var body: some View {
        content
            .toolbar(.hidden)
    }
    
    private var content: some View {
        JoinView(state: model.state)
    }
}

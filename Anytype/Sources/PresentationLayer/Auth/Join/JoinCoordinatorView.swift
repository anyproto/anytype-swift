import SwiftUI

struct JoinCoordinatorView: View {

    @State private var model: JoinCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss

    init(state: JoinFlowState) {
        _model = State(initialValue: JoinCoordinatorViewModel(state: state))
    }
    
    var body: some View {
        content
            .toolbar(.hidden)
    }
    
    private var content: some View {
        JoinView(state: model.state)
    }
}

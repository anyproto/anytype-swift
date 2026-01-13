import SwiftUI
import AnytypeCore


struct SetPropertiesCoordinatorView: View {
    @State private var model: SetPropertiesCoordinatorViewModel

    init(setDocument: some SetDocumentProtocol, viewId: String) {
        _model = State(initialValue: SetPropertiesCoordinatorViewModel(setDocument: setDocument, viewId: viewId))
    }
    
    var body: some View {
        SetPropertiesView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.relationsSearchData) { data in
            PropertyCreationView(data: data)
        }
    }
}

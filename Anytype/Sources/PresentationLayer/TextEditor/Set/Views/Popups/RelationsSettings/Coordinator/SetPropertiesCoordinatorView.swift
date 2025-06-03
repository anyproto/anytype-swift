import SwiftUI
import AnytypeCore


struct SetPropertiesCoordinatorView: View {
    @StateObject private var model: SetPropertiesCoordinatorViewModel
    
    init(setDocument: some SetDocumentProtocol, viewId: String) {
        _model = StateObject(wrappedValue: SetPropertiesCoordinatorViewModel(setDocument: setDocument, viewId: viewId))
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

import SwiftUI

struct SetRelationsCoordinatorView: View {
    @StateObject private var model: SetRelationsCoordinatorViewModel
    
    init(setDocument: SetDocumentProtocol, viewId: String) {
        _model = StateObject(wrappedValue: SetRelationsCoordinatorViewModel(setDocument: setDocument, viewId: viewId))
    }
    
    var body: some View {
        SetRelationsView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.relationsSearchData) { data in
            RelationsSearchCoordinatorView(data: data)
        }
    }
}

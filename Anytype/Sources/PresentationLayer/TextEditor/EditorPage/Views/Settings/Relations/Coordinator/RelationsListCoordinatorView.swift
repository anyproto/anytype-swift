import Foundation
import SwiftUI

struct RelationsListCoordinatorView: View {
    
    @StateObject private var model: RelationsListCoordinatorViewModel
    
    init(document: BaseDocumentProtocol, output: RelationValueCoordinatorOutput?) {
        _model = StateObject(wrappedValue: RelationsListCoordinatorViewModel(document: document, output: output))
    }
    
    var body: some View {
        RelationsListView(
            document: model.document,
            output: model
        )
        .sheet(item: $model.relationValueData) { data in
            RelationValueCoordinatorView(data: data, output: model)
        }
        .sheet(item: $model.relationsSearchData) {
            RelationsSearchCoordinatorView(data: $0)
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
}

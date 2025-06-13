import Foundation
import Services
import SwiftUI
import AnytypeCore


struct PropertiesListCoordinatorView: View {
    
    @StateObject private var model: PropertiesListCoordinatorViewModel
    
    init(document: some BaseDocumentProtocol, output: (any PropertyValueCoordinatorOutput)?) {
        _model = StateObject(wrappedValue: PropertiesListCoordinatorViewModel(document: document, output: output))
    }
    
    var body: some View {
        ObjectPropertiesView(
            document: model.document,
            output: model
        )
        .sheet(item: $model.relationValueData) { data in
            PropertyValueCoordinatorView(data: data, output: model)
        }
        .sheet(item: $model.relationsSearchData) {
            PropertyCreationView(data: $0)
        }
        .sheet(item: $model.objectTypeData) {
            TypePropertiesView(data: $0)
        }
        .sheet(isPresented: $model.showTypePicker) {
            ObjectTypeSearchView(
                title: Loc.changeType,
                spaceId: model.document.spaceId,
                settings: .editorChangeType
            ) { type in
                model.onTypeSelected(type)
            }
        }
    }
}

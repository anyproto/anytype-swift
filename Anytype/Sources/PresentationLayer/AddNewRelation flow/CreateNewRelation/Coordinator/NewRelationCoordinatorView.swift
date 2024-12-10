import SwiftUI

struct NewRelationData: Identifiable {
    let id = UUID()
    let name: String
    let objectId: String
    let spaceId: String
    let target: RelationsModuleTarget
}

struct NewRelationCoordinatorView: View {
    
    @StateObject private var model: NewRelationCoordinatorViewModel
    
    init(data: NewRelationData, output: (any NewRelationCoordinatorViewOutput)?) {
        _model = StateObject(wrappedValue: NewRelationCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        NewRelationView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.relationFormatsData) {
            RelationFormatsListView(
                selectedFormat: $0.format,
                onFormatSelect: $0.onSelect
            )
        }
        .sheet(item: $model.searchData) {
            ObjectTypesLimitedSearchView(data: $0)
        }
    }
}

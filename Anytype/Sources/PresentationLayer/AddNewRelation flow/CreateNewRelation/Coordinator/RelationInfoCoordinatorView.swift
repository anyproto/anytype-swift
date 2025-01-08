import SwiftUI


struct RelationInfoCoordinatorView: View {
    
    @StateObject private var model: RelationInfoCoordinatorViewModel
    
    init(data: RelationInfoData, output: (any RelationInfoCoordinatorViewOutput)?) {
        _model = StateObject(wrappedValue: RelationInfoCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        RelationInfoView(
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

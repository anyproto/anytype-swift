import SwiftUI

struct PropertyInfoCoordinatorView: View {

    @State private var model: PropertyInfoCoordinatorViewModel

    init(data: PropertyInfoData, output: (any PropertyInfoCoordinatorViewOutput)?) {
        _model = State(initialValue: PropertyInfoCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        PropertyInfoView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.propertyFormatsData) {
            PropertyFormatsListView(
                selectedFormat: $0.format,
                onFormatSelect: $0.onSelect
            )
        }
        .sheet(item: $model.searchData) {
            ObjectTypesLimitedSearchView(data: $0)
        }
    }
}

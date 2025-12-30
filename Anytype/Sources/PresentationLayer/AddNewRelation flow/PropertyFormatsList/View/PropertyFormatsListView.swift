import SwiftUI

struct PropertyFormatsListView: View {

    @State private var viewModel: PropertyFormatsListViewModel
    @Environment(\.dismiss) private var dismiss

    init(selectedFormat: SupportedPropertyFormat, onFormatSelect: @escaping (SupportedPropertyFormat) -> Void) {
        _viewModel = State(initialValue: PropertyFormatsListViewModel(selectedFormat: selectedFormat, onFormatSelect: onFormatSelect))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.selectRelationType)
            list
        }
    }
    
    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.supportedFormatModels) { model in
                    Button {
                        viewModel.didSelectFormat(id: model.id)
                        dismiss()
                    } label: {
                        PropertyFormatListCell(model: model)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

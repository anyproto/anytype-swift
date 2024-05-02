import SwiftUI

struct RelationFormatsListView: View {
    
    @StateObject private var viewModel: RelationFormatsListViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(selectedFormat: SupportedRelationFormat, onFormatSelect: @escaping (SupportedRelationFormat) -> Void) {
        _viewModel = StateObject(wrappedValue: RelationFormatsListViewModel(selectedFormat: selectedFormat, onFormatSelect: onFormatSelect))
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
                        RelationFormatListCell(model: model)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

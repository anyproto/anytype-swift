import SwiftUI

struct RelationFormatsListView: View {
    
    @StateObject private var viewModel: RelationFormatsListViewModel
    
    init(selectedFormat: SupportedRelationFormat, output: RelationFormatsListModuleOutput?) {
        _viewModel = StateObject(wrappedValue: RelationFormatsListViewModel(selectedFormat: selectedFormat, output: output))
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
                    } label: {
                        RelationFormatListCell(model: model)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

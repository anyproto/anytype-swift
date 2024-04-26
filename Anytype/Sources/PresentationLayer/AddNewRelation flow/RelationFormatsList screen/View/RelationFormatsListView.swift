import SwiftUI

struct RelationFormatsListView: View {
    
    @ObservedObject var viewModel: RelationFormatsListViewModel
    
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

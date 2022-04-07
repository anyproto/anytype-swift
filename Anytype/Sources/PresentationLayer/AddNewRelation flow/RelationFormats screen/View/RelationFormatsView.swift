import SwiftUI

struct RelationFormatsView: View {
    
    @ObservedObject var viewModel: RelationFormatsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Connect with".localized)
            list
        }
    }
    
    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.supportedFormatModels) { model in
                    Button {
                        viewModel.didSelectFormat(id: model.id)
                    } label: {
                        RelationFormatCell(model: model)
                    }
                }
            }
        }
    }
}

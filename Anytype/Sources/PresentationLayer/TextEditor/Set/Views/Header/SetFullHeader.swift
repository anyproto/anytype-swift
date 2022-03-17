import SwiftUI
import Kingfisher

struct SetFullHeader: View {
    @State private var width: CGFloat = .zero
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    private let bigCover: CGFloat = 230
    private let smallCover: CGFloat = 150
    
    var body: some View {
        header
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            
            AnytypeText(model.details.title, style: .title, color: .textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
            
            description
            
            Spacer.fixedHeight(8)
            
            featuredRelations
        }
        .readSize { width = $0.width }
    }
    
    private var description: some View {
        Group {
            if model.details.description.isNotEmpty {
                Spacer.fixedHeight(6)
                AnytypeText(model.details.description, style: .relation2Regular, color: .textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
            } else {
                EmptyView()
            }
        }
    }
    
    private var featuredRelations: some View {
        FlowRelationsView(
            viewModel: FlowRelationsViewModel(
                relations: model.featuredRelations,
                onRelationTap: { relation in
                    model.router.showRelationValueEditingView(key: relation.id, source: .object)
                }
            )
        )
            .padding(.horizontal, 20)
    }
    
    private var cover: some View {
        Group {
            switch model.headerModel.header {
            case .empty(let data):
                Button(action: data.onTap) {
                    Color.backgroundPrimary
                        .frame(height: smallCover)
                }
            case .filled(let state):
                ObjectHeaderFilledContentSwitfUIView(
                    configuration: ObjectHeaderFilledConfiguration(state: state, width: width)
                )
                    .frame(height: bigCover)
            }
        }
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader()
    }
}

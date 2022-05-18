import SwiftUI
import Kingfisher

struct SetFullHeader: View {
    @State private var width: CGFloat = .zero
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    private let minimizedHeaderHeight = ObjectHeaderConstants.minimizedHeaderHeight + UIApplication.shared.mainWindowInsets.top
    
    var body: some View {
        header
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().foregroundColor(.backgroundPrimary)
                .frame(height: minimizedHeaderHeight)
            
            cover
            
            model.details.flatMap {
                AnytypeText($0.title, style: .title, color: .textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
            }
            
            description
            
            Spacer.fixedHeight(8)
            
            featuredRelations
        }
        .readSize { width = $0.width }
    }
    
    private var description: some View {
        Group {
            if let description = model.details?.description, description.isNotEmpty {
                Spacer.fixedHeight(6)
                AnytypeText(description, style: .relation2Regular, color: .textPrimary)
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
                    AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
                    
                    model.showRelationValueEditingView(key: relation.id, source: .object)
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
                        .frame(height: ObjectHeaderConstants.emptyViewHeight)
                }
            case .filled(let state):
                ObjectHeaderFilledContentSwitfUIView(
                    configuration: ObjectHeaderFilledConfiguration(
                        state: state,
                        width: width,
                        topAdjustedContentInset: minimizedHeaderHeight
                    )
                )
                    .frame(height: ObjectHeaderConstants.height)
            default:
                EmptyView()
            }

        }
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader()
    }
}

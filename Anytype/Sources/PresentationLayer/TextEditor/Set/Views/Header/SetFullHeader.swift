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
            cover
            flowRelationsHeader
        }
        .readSize { width = $0.width }
    }
    
    private var cover: some View {
        Group {
            switch model.headerModel.header {
            case .empty(let data, _):
                Button(action: data.onTap) {
                    Color.backgroundPrimary
                        .frame(height: ObjectHeaderConstants.emptyViewHeight)
                }
            case .filled(let state, _):
                ObjectHeaderFilledContentSwitfUIView(
                    configuration: ObjectHeaderFilledConfiguration(
                        state: state,
                        isShimmering: false,
                        width: width
                    )
                )
                .frame(height: ObjectHeaderConstants.coverFullHeight)
            default:
                EmptyView()
            }

        }
    }
    
    private var flowRelationsHeader: some View {
        FlowRelationsView(viewModel: model.flowRelationsViewModel)
            .padding(.horizontal, 20)
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader()
    }
}

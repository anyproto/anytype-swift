import SwiftUI
import Kingfisher

struct SetFullHeader: View {
    @State private var width: CGFloat = .zero
    @State var textEditorHeight: CGFloat = 20

    @EnvironmentObject private var model: EditorSetViewModel
    
    private let minimizedHeaderHeight = ObjectHeaderConstants.minimizedHeaderHeight + UIApplication.shared.mainWindowInsets.top
    
    var body: some View {
        header
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            VStack(alignment: .leading, spacing: 8) {
                titleView
                description
                flowRelations
            }
            .padding([.leading], 20)
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
}

extension SetFullHeader {
    private var description: some View {
        Group {
            if let description = model.details?.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: .relation2Regular,
                    color: .textPrimary
                )
                .fixedSize(horizontal: false, vertical: true)
            } else {
                EmptyView()
            }
        }
    }

    private var titleView: some View {
        ZStack(alignment: .leading) {
            Text(model.titleString)
                .frame(alignment: .leading)
                .foregroundColor(Color.clear)
                .font(AnytypeFontBuilder.font(anytypeFont: .title))
                .padding(.horizontal, 6.2)
                .readSize { size in
                    textEditorHeight = size.height
                }
            AutofocusedTextEditor(
                text: $model.titleString,
                shouldSkipFocusOnFilled: true
            )
            .font(AnytypeFontBuilder.font(anytypeFont: .title))
            .frame(height: textEditorHeight)
            .offset(x: -6.2)
            .placeholder(when: model.titleString.isEmpty) {
                AnytypeText(Loc.untitled, style: .title, color: .textTertiary)
            }
        }
    }

    private var flowRelations: some View {
        FlowLayout(
            items: model.featuredRelationValues,
            alignment: .leading,
            spacing: .init(width: 6, height: 4),
            cell: { item, index in
                HStack(spacing: 0) {
                    RelationValueView(
                        relation: RelationItemModel(relationValue: item),
                        style: .featuredRelationBlock(allowMultiLine: false)
                    ) { [weak model] in
                        UIApplication.shared.hideKeyboard()
                        model?.onRelationTap(relationValue: item)
                    }

                    if model.featuredRelationValues.count - 1 > index {
                        dotImage
                    }
                }
            }
        )
    }

    private var dotImage: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.textSecondary)
            .frame(width: 3, height: 3)
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader()
    }
}

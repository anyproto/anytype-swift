import SwiftUI
import Kingfisher

struct SetFullHeader: View {
    @State private var width: CGFloat = .zero

    @ObservedObject var model: EditorSetViewModel
    
    var body: some View {
        Group {
            if model.hasTargetObjectId {
                inlineHeader
            } else {
                header
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            VStack(alignment: .leading, spacing: 8) {
                titleView
                description
                featuredRelationsView
            }
            .padding([.leading], 20)
        }
        .readSize { width = $0.width }
    }
    
    private var inlineHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            emptyCover
            VStack(alignment: .leading, spacing: 8) {
                iconWithTitle
                featuredRelationsView
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
                    emptyCover
                }
            case .filled(let state, _):
                ObjectHeaderFilledContentSwitfUIView(
                    configuration: ObjectHeaderFilledConfiguration(
                        state: state,
                        isShimmering: false,
                        sizeConfiguration: .editorSizeConfiguration(width: width)
                    )
                )
            default:
                EmptyView()
            }
        }
    }
    
    private var emptyCover: some View {
        Color.Background.primary
            .frame(height: ObjectHeaderConstants.emptyViewHeight)
    }
}

extension SetFullHeader {
    private var description: some View {
        Group {
            if let description = model.details?.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: .relation1Regular,
                    color: .Text.primary
                )
                .fixedSize(horizontal: false, vertical: true)
            } else {
                EmptyView()
            }
        }
    }
    
    private var iconWithTitle: some View {
        HStack(spacing: 8) {
            iconView
            titleView
        }
    }
    
    private var iconView: some View {
        Group {
            if model.hasTargetObjectId, let iconImage = model.details?.objectIconImage {
                IconView(icon: iconImage)
                .frame(
                    width: 32,
                    height: 32
                )
                .padding(.top, 1)
                .onTapGesture {
                    model.showIconPicker()
                }
            }
        }
    }

    private var titleView: some View {
        AutofocusedTextField(
            placeholder: Loc.Object.Title.placeholder,
            placeholderFont: .title,
            shouldSkipFocusOnFilled: true,
            text: $model.titleString
        )
        .padding([.trailing], 20)
        .font(AnytypeFontBuilder.font(anytypeFont: .title))
        .disableAutocorrection(true)
    }

    private var featuredRelationsView: some View {
        FeaturedRelationsView(
            relations: model.featuredRelations,
            view: { relation in
                relationContent(for: relation)
            }
        )
    }
    
    @ViewBuilder
    private func relationContent(for relation: Relation) -> some View {
        let item = RelationItemModel(relation: relation)
        let style = RelationStyle.featuredRelationBlock(
            FeaturedRelationSettings(
                allowMultiLine: false,
                prefix: relation.setOfPrefix,
                showIcon: relation.showIcon,
                error: item.isErrorState, 
                links: relation.links
            )
        )
        let contextMenuItems = model.contextMenuItems(for: relation)
        let mode: RelationValueViewModel.Mode = contextMenuItems.isNotEmpty ? .contextMenu(contextMenuItems) : .button(action: { [weak model] in
            UIApplication.shared.hideKeyboard()
            model?.onRelationTap(relation: relation)
        })
        RelationValueView(
            model: RelationValueViewModel(
                relation: item,
                style: style,
                mode: mode
            )
        )
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader(model: EditorSetViewModel.emptyPreview)
    }
}

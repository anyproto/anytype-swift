import SwiftUI
import AnytypeCore

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
        .background(Color.Background.primary)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            VStack(alignment: .leading, spacing: 8) {
                titleView
                headerBlocks
            }
            .padding([.leading], 20)
        }
        .readSize { width = $0.width }
    }
    
    @ViewBuilder
    private var headerBlocks: some View {
        description
        
        if model.details?.isObjectType ?? false {
            Spacer.fixedHeight(10)
            typeButtons
        } else {
            featuredRelationsView
        }
    }
    
    private var inlineHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            emptyCover(presentationStyle: .full)
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
            case .empty(let data, _, _):
                Button(action: data.onTap) {
                    emptyCover(presentationStyle: data.presentationStyle)
                }
            case let .filled(state, showPublishingBanner, _):
                ObjectHeaderFilledContentSwitfUIView(
                    configuration: ObjectHeaderFilledConfiguration(
                        state: state,
                        isShimmering: false,
                        sizeConfiguration: .editorSizeConfiguration(
                            width: width,
                            showPublishingBanner: showPublishingBanner
                        )
                    )
                )
            default:
                EmptyView()
            }
        }
    }
    
    private func emptyCover(presentationStyle: ObjectHeaderEmptyUsecase) -> some View {
        Color.Background.primary
            .frame(height: presentationStyle == .full ? ObjectHeaderConstants.emptyViewHeight : ObjectHeaderConstants.emptyViewHeightCompact)
    }
    
    private var typeButtons: some View {
        HStack(spacing: 8) {
            
            if (model.details?.recommendedLayoutValue.isEditorLayout ?? false) && model.setDocument.document.permissions.canEditDetails {
                StandardButton(
                    .textWithBadge(text: Loc.layout, badge: (model.details?.recommendedLayoutValue?.title ?? "")),
                    style: .secondarySmall
                ) {
                    model.onObjectTypeLayoutTap()
                }.minimumScaleFactor(0.5)
            }

            if model.showProperties {
                StandardButton(
                    .textWithBadge(text: Loc.fields, badge: "\(model.relationsCount)"),
                    style: .secondarySmall
                ) {
                    model.onObjectTypePropertiesTap()
                }.minimumScaleFactor(0.5)
            }
            
            if model.showObjectTypeTemplates {
                StandardButton(
                    .textWithBadge(text: Loc.templates, badge: "\(model.templatesCount)"),
                    style: .secondarySmall
                ) {
                    model.onObjectTypeTemplatesTap()
                }.minimumScaleFactor(0.5)
            }

            
            Spacer()
        }
    }
}

extension SetFullHeader {
    private var description: some View {
        Group {
            if model.showDescription {
                AnytypeTextField(
                    placeholder: Loc.BlockText.ContentType.Description.placeholder,
                    font: .relation1Regular,
                    text: $model.descriptionString
                )
                .padding([.trailing], 20)
                .foregroundStyle(Color.Text.primary) 
                .disabled(!model.setDocument.setPermissions.canEditDescription)
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

    @ViewBuilder
    private var titleView: some View {
        if model.details?.isObjectType ?? false {
            Button {
                model.onTypeTitleTap()
            } label: {
                AnytypeText(model.titleString.isNotEmpty ? model.titleString : Loc.untitled, style: .title)
                    .padding([.trailing], 20)
            }.disabled(!model.setDocument.setPermissions.canEditTitle)
        } else {
            AutofocusedTextField(
                placeholder: Loc.untitled,
                font: .title,
                shouldSkipFocusOnFilled: true,
                text: $model.titleString
            )
            .padding([.trailing], 20)
            .foregroundStyle(Color.Text.primary)
            .disableAutocorrection(true)
            .disabled(!model.setDocument.setPermissions.canEditTitle)
        }
    }

    private var featuredRelationsView: some View {
        FeaturedPropertiesView(
            relations: model.featuredRelations,
            view: { relation in
                relationContent(for: relation)
            }
        )
    }
    
    @ViewBuilder
    private func relationContent(for relation: Property) -> some View {
        let item = PropertyItemModel(property: relation)
        let style = PropertyStyle.featuredBlock(
            FeaturedPropertySettings(
                allowMultiLine: false,
                prefix: relation.setOfPrefix,
                showIcon: relation.showIcon,
                error: item.isErrorState, 
                links: relation.links
            )
        )
        let contextMenuItems = model.contextMenuItems(for: relation)
        let mode: PropertyValueViewModel.Mode = contextMenuItems.isNotEmpty ? .contextMenu(contextMenuItems) : .button(action: { [weak model] in
            UIApplication.shared.hideKeyboard()
            model?.onRelationTap(relation: relation)
        })
        PropertyValueView(
            model: PropertyValueViewModel(
                property: item,
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

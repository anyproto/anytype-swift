import SwiftUI

struct ObjectTypeView: View {
    @StateObject private var model: ObjectTypeViewModel
    
    init(data: EditorTypeObject) {
        _model = StateObject(wrappedValue: ObjectTypeViewModel(data: data))
    }
    
    var body: some View {
        content
            .animation(.default, value: model.state)
            .task { await model.setupSubscriptions() }
        
            .onChange(of: model.typeName) {
                model.onTypeNameChange(name: $0)
            }
        
            .anytypeSheet(isPresented: $model.state.showSyncStatusInfo) {
                SyncStatusInfoView(spaceId: model.data.spaceId)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.layoutPickerObjectId) {
                ObjectLayoutPicker(mode: .type, objectId: $0.value, spaceId: model.data.spaceId)
            }
            .sheet(isPresented: $model.showFields) {
                TypeFieldsView(document: model.document, output: model)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
    
    private var content: some View {
        VStack {
            navbar
            Spacer.fixedHeight(32)
            header.padding(.horizontal, 20)
            Spacer.fixedHeight(24)
            buttonsRow.padding(.horizontal, 20)
            Spacer.fixedHeight(32)
            templates
            // TBD: List of objects
            Spacer()
        }
    }
    
    private var navbar: some View {
        HStack(alignment: .center, spacing: 14) {
            SwiftUIEditorSyncStatusItem(
                statusData: model.state.syncStatusData,
                itemState: .initial,
                onTap: { model.onSyncStatusTap() }
            )
            .frame(width: 28, height: 28)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Button(action: {
                model.onIconTap()
            }, label: {
                IconView(icon: model.state.details?.objectIconImage).frame(width: 32, height: 32)
            })
            TextField(Loc.BlockText.Content.placeholder, text: $model.typeName)
                .foregroundColor(.Text.primary)
                .font(AnytypeFontBuilder.font(anytypeFont: .title))
            Spacer()
        }
    }
    
    private var buttonsRow: some View {
        HStack(spacing: 12) {
            if model.state.isEditorLayout {
                StandardButton(
                    .textWithBadge(text: Loc.layout, badge: (model.state.details?.recommendedLayoutValue?.title ?? "")),
                    style: .secondarySmall
                ) {
                    model.onLayoutTap()
                }
            }
            
            StandardButton(
                .textWithBadge(text: Loc.relations, badge: "\(model.state.relationsCount)"),
                style: .secondarySmall
            ) {
                model.onFieldsTap()
            }
            
            Spacer()
        }
    }
    
    private var templates: some View {
        VStack {
            HStack(spacing: 8) {
                AnytypeText(Loc.templates, style: .subheading)
                AnytypeText("\(model.state.templates.count)", style: .previewTitle1Regular)
                    .foregroundColor(Color.Text.secondary)
                Spacer()
            }.padding(10).padding(.horizontal, 10)
            templatesList
        }
    }
    
    private var templatesList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.state.templates) { template in
                    EditableView<TemplatePreview>(
                        content: TemplatePreview(viewModel: template),
                        onTap: { model.onTemplateTap(model: template.model) },
                        canBeEdited: false,
                        isEditing: .constant(false)
                    )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 232)
        }
    }
}

#Preview {
    ObjectTypeView(data: EditorTypeObject(objectId: "", spaceId: ""))
}

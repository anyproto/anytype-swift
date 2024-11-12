import SwiftUI

struct ObjectTypeView: View {
    @StateObject private var model: ObjectTypeViewModel
    
    init(data: EditorTypeObject) {
        _model = StateObject(wrappedValue: ObjectTypeViewModel(data: data))
    }
    
    var body: some View {
        content
            .animation(.default, value: model.templates)
            .task { await model.setupSubscriptions() }
        
            .anytypeSheet(isPresented: $model.showSyncStatusInfo) {
                SyncStatusInfoView(spaceId: model.data.spaceId)
            }
    }
    
    private var content: some View {
        VStack {
            navbar
            Spacer.fixedHeight(32)
            header.padding(.horizontal, 20)
            templates
            // TBD: List of objects
            Spacer()
        }
    }
    
    private var navbar: some View {
        HStack(alignment: .center, spacing: 14) {
            SwiftUIEditorSyncStatusItem(
                statusData: model.syncStatusData,
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
            ObjectIconView(icon: model.icon).frame(width: 32, height: 32)
            AnytypeText(model.title, style: .title)
            Spacer()
            StandardButton(Loc.edit, style: .secondarySmall) {
                // TBD;
            }.disabled(true)
        }
    }
    
    private var templates: some View {
        VStack {
            HStack(spacing: 8) {
                AnytypeText(Loc.templates, style: .subheading)
                AnytypeText("\(model.templates.count)", style: .previewTitle1Regular)
                    .foregroundColor(Color.Text.secondary)
                Spacer()
            }.padding(10)
            templatesList
        }
    }
    
    private var templatesList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.templates) { item in
                    EditableView<TemplatePreview>(
                        content: TemplatePreview(viewModel: item),
                        onTap: { model.onTemplateTap(model: item.model) },
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

import SwiftUI

struct ObjectTypeView: View {
    @StateObject private var model: ObjectTypeViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(document: any BaseDocumentProtocol, output: any ObjectTypeViewModelOutput) {
        _model = StateObject(wrappedValue: ObjectTypeViewModel(document: document, output: output))
    }
    
    var body: some View {
        content
            .onAppear { model.setDismissHandler(dismiss: dismiss) }
            .onAppear { model.onAppear() }
            .task { await model.setupSubscriptions() }
        
            .onChange(of: model.typeName) {
                model.onTypeNameChange(name: $0)
            }
        
            .anytypeSheet(isPresented: $model.showDeleteConfirmation) {
                TypeDeleteAlert {
                    try await model.onDeleteConfirm()
                }
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                navbar
                Spacer.fixedHeight(32)
                header.padding(.horizontal, 20)
                if model.canEditDetails {
                    Spacer.fixedHeight(24)
                    buttonsRow.padding(.horizontal, 20)
                    Spacer.fixedHeight(32)
                }
                if model.showTemplates { templates }
                Spacer.fixedHeight(32)
                ObjectTypeObjectsListView(typeDocument: model.document, output: model.output)
            }
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
            
            if model.canArchive {
                Menu {
                    Button(Loc.delete, role: .destructive) {
                        model.onDeleteTap()
                    }
                } label: {
                    IconView(asset: .X24.more).frame(width: 24, height: 24)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Button(action: {
                model.onIconTap()
            }, label: {
                IconView(icon: model.details?.objectIconImage).frame(width: 32, height: 32)
            }).disabled(!model.canEditDetails)
            if model.canEditDetails {
                TextField(Loc.BlockText.Content.placeholder, text: $model.typeName)
                    .foregroundColor(.Text.primary)
                    .font(AnytypeFontBuilder.font(anytypeFont: .title))
            } else {
                AnytypeText(model.typeName, style: .title)
                    .foregroundColor(.Text.primary)
            }
            Spacer()
        }
    }
    
    private var buttonsRow: some View {
        HStack(spacing: 12) {
            if model.isEditorLayout {
                StandardButton(
                    .textWithBadge(text: Loc.layout, badge: (model.details?.recommendedLayoutValue?.title ?? "")),
                    style: .secondarySmall
                ) {
                    model.onLayoutTap()
                }
            }
            
            StandardButton(
                .textWithBadge(text: Loc.fields, badge: "\(model.relationsCount)"),
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
                AnytypeText("\(model.templatesCount)", style: .previewTitle1Regular)
                    .foregroundColor(Color.Text.secondary)
                Spacer()
                
                Button(action: {
                    model.onAddTemplateTap()
                }, label: {
                    IconView(asset: .X24.plus).frame(width: 24, height: 24)
                })
            }.padding(10).padding(.horizontal, 10)
            templatesList
        }
    }
    
    private var templatesList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.templates) { template in
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

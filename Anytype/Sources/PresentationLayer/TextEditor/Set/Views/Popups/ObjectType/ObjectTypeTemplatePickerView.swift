import SwiftUI

struct ObjectTypeTemplatePickerView: View {
    @StateObject private var model: ObjectTypeTemplatePickerViewModel
    
    init(document: any BaseDocumentProtocol, output: any EditorSetModuleOutput) {
        _model = StateObject(
            wrappedValue: ObjectTypeTemplatePickerViewModel(document: document, output: output)
        )
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
            .onAppear { model.onAppear() }
    }
    
    private var content: some View {
        VStack {
            DragIndicator()
            templates
            Spacer.fixedHeight(22)
        }
        .background(Color.Background.secondary)
    }

    private var templates: some View {
        VStack {
            ZStack {
                HStack(spacing: 8) {
                    
                    Spacer()
                    
                    AnytypeText(Loc.templates, style: .subheading)
                    AnytypeText("\(model.templatesCount)", style: .previewTitle1Regular)
                        .foregroundColor(Color.Text.secondary)
                    
                    Spacer()

                    if model.canEdit {
                        Button(action: {
                            model.onAddTemplateTap()
                        }, label: {
                            IconView(asset: .X24.plus).frame(width: 24, height: 24)
                        })
                    }
                }
                
                HStack {
                    if model.canEdit {
                        Button {
                            model.onEditTap()
                        } label: {
                            AnytypeText(model.isEditing ? Loc.done : Loc.edit, style: .previewTitle1Regular)
                                .foregroundColor(Color.Text.secondary)
                        }
                    }
                    Spacer()
                }
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
                        canBeEdited: template.model.isEditable,
                        isEditing: $model.isEditing
                    )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 232)
        }
    }
}


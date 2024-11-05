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
    }
    
    private var content: some View {
        VStack {
            Rectangle().frame(height: 48).foregroundStyle(Color.Text.secondary) // Navbar placeholder
            VStack(spacing: 0) {
                Spacer.fixedHeight(32)
                header
                templates
                Spacer()
            }.padding(.horizontal, 20)
        }
    }
    
    private var header: some View {
        AnytypeText(model.title, style: .title)
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
                        canBeEdited: false, //item.model.isEditable,
                        isEditing: .constant(false) //$model.isEditingState
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

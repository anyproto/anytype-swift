import SwiftUI
import Services

struct TypeFieldsView: View {
    
    @StateObject private var model: TypeFieldsViewModel
    
    init(data: EditorTypeObject, output: (any RelationsListModuleOutput)?) {
        _model = StateObject(wrappedValue: TypeFieldsViewModel(data: data, output: output))
    }
    
    init(document: some BaseDocumentProtocol, output: (any RelationsListModuleOutput)?) {
        _model = StateObject(wrappedValue: TypeFieldsViewModel(document: document, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            banner
            relationsList
        }
    }
    
    private var navigationBar: some View {
        HStack {
            if !model.navigationBarButtonsDisabled {
                cancelButton
            }
            
            Spacer()
            AnytypeText(Loc.relations, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
            
            if !model.navigationBarButtonsDisabled {
                saveButton
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var cancelButton: some View {
        Button {
            // TBD;
        } label: {
            AnytypeText(Loc.cancel, style: .uxBodyRegular)
            .foregroundColor(.Text.secondary)
        }.disabled(true)
    }
    
    private var saveButton: some View {
        Button {
            // TBD;
        } label: {
            AnytypeText(Loc.save, style: .uxBodyRegular)
            .foregroundColor(.Text.secondary)
        }.disabled(true)
    }
    
    private var banner: some View {
        HStack(spacing: 0) {
            Spacer()
            AnytypeText(Loc.ObjectType.editingType, style: .previewTitle2Regular)
            Spacer.fixedWidth(8)
            IconView(icon: model.document.details?.objectIconImage).frame(width: 18, height: 18)
            Spacer.fixedWidth(5)
            AnytypeText(model.document.details?.title ?? "", style: .previewTitle2Medium)
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.Shape.tertiary)
    }
    
    private var relationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.sections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        Section(header: sectionHeader(title: section.title)) {
                            ForEach(section.relations) {
                                row(with: $0, addedToObject: section.addedToObject)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        ListSectionHeaderView(title: title)
    }
    
    private func row(with relation: Relation, addedToObject: Bool) -> some View {
        RelationsListRowView(
            editingMode: .constant(true),
            starButtonAvailable: !model.navigationBarButtonsDisabled,
            showLocks: false,
            addedToObject: addedToObject,
            relation: relation
        ) {
            model.removeRelation(relation: $0)
        } onStarTap: {
            model.changeRelationFeaturedState(relation: $0, addedToObject: addedToObject)
        } onEditTap: {
            model.handleTapOnRelation(relation: $0)
        }
    }
    
}

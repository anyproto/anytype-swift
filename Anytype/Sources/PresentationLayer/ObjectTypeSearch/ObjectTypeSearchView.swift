import SwiftUI
import Services
import WrappingHStack
import AnytypeCore


struct ObjectTypeSearchView: View {
    private typealias SectionData = ObjectTypeSearchViewModel.SectionData
    private typealias SectionType = ObjectTypeSearchViewModel.SectionType
    private typealias ObjectTypeData =  ObjectTypeSearchViewModel.ObjectTypeData
    
    let title: String
    @StateObject private var viewModel: ObjectTypeSearchViewModel
    
    init(
        title: String,
        spaceId: String,
        settings: ObjectTypeSearchViewSettings,
        onSelect: @escaping (TypeSelectionResult) -> Void
    ) {
        self.title = title
        _viewModel = StateObject(
            wrappedValue: ObjectTypeSearchViewModel(
                spaceId: spaceId,
                settings: settings,
                onSelect: onSelect
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: title)
            SearchBar(text: $viewModel.searchText, focused: false, placeholder: Loc.search)
            content
            pasteButton
        }
        .snackbar(toastBarData: $viewModel.toastData)
        .background(Color.Background.secondary)
        
        .onChange(of: viewModel.searchText) { viewModel.search(text: $0) }
        .task {
            viewModel.onAppear()
        }
        .task {
            await viewModel.subscribeOnParticipant()
        }
        .task {
            await viewModel.handlePasteboard()
        }
    }
    
    private var pasteButton: some View {
        Group {
            if viewModel.showPasteButton {
                Button {
                    viewModel.createObjectFromClipboard()
                } label: {
                    HStack(spacing: 6) {
                        Image(asset: .X24.clipboard).foregroundColor(.Control.active)
                        AnytypeText(Loc.createObjectFromClipboard, style: .caption1Medium)
                            .foregroundColor(.Text.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var content: some View {
        Group {
            switch viewModel.state {
            case .searchResults(let sectionsData):
                searchResults(sectionsData: sectionsData)
            case .emptyScreen:
                EmptyStateView(
                    title: Loc.nothingFound,
                    subtitle: Loc.noTypeFoundText(viewModel.searchText),
                    style: .plain,
                    buttonData: viewModel.participantCanEdit ? EmptyStateView.ButtonData(
                        title: Loc.createType,
                        action: { viewModel.createType(name: viewModel.searchText) }
                    ) : nil
                )
            }
        }
    }
    
    private func searchResults(sectionsData: [SectionData]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sectionsData) { sectionData in
                    Section(header: sectionHeader(sectionData.section)) {
                        typesView(section: sectionData.section, data: sectionData.types)
                    }
                    .id(sectionData.id)
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    private func sectionHeader(_ type: SectionType) -> some View {
        HStack(spacing: 0) {
            AnytypeText(type.name, style: .caption1Medium)
                .foregroundColor(.Text.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .padding(.bottom, 8)
    }
    
    private func typesView(section: SectionType, data: [ObjectTypeData]) -> some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 0) {
            ForEach(data, id: \.type.id) { typeData in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    viewModel.didSelectType(typeData.type, section: section)
                } label: {
                    HStack(spacing: 8) {
                        Group {
                            if let emoji = typeData.type.iconEmoji {
                                IconView(icon: .object(.emoji(emoji)))
                            } else {
                                IconView(icon: .object(.empty(.objectType)))
                            }
                        }
                        .frame(width: 18, height: 18)
                        
                        AnytypeText(typeData.type.name, style: .uxTitle2Medium)
                            .foregroundColor(.Text.primary)
                    }
                    .padding(.vertical, 15)
                    .padding(.leading, 14)
                    .padding(.trailing, 16)
                }
                .border(
                    12,
                    color: shouldHighlightType(typeData) ? .System.amber50 : .Shape.primary,
                    lineWidth: shouldHighlightType(typeData) ? 2 : 1
                )
                .background(Color.Background.secondary)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
                .contextMenu {
                    switch section {
                    case .pins, .objects, .lists:
                        contextMenu(section: section, data: typeData)
                    case .library:
                        EmptyView()
                    }
                }
                .padding(.bottom, 8)
                .id(typeData.type.id)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func shouldHighlightType(_ type: ObjectTypeData) -> Bool {
        type.isDefault && viewModel.settings.showPins
    }
    
    @ViewBuilder
    private func contextMenu(section: SectionType, data: ObjectTypeData) -> some View {
        if viewModel.settings.showPins {
            if section == .pins {
                Button(Loc.unpin) {
                    viewModel.removePinedType(data.type)
                }
            } else {
                Button(Loc.pinOnTop) {
                    viewModel.addPinedType(data.type)
                }
            }
        }
        
        let isNotListLayout = data.type.recommendedLayout.flatMap { !$0.isList } ?? false
        let canSetAsDefault = !data.isDefault && data.type.canCreateObjectOfThisType && isNotListLayout
        
        if  canSetAsDefault {
            Button(Loc.setAsDefault) {
                viewModel.setDefaultType(data.type)
            }
        }
        
        if !data.type.readonly {
            Button(Loc.delete, role: .destructive) {
                viewModel.deleteType(data.type)
            }
        }
    }
}

extension ObjectTypeSearchView {
    init(
        title: String,
        spaceId: String,
        settings: ObjectTypeSearchViewSettings,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) {
        self.init(title: title, spaceId: spaceId, settings: settings) { result in
            switch result {
            case .objectType(let type):
                onSelect(type)
            case .createFromPasteboard:
                anytypeAssertionFailure("Unsupported action createFromPasteboard")
            }
        }
    }
}

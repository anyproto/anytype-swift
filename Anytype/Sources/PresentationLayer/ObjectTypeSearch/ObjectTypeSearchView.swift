import SwiftUI
import Services
import WrappingHStack
import AnytypeCore

enum ObjectTypeSearchNavigationHeaderStyle {
    case sheet
    case navbar
}

struct ObjectTypeSearchView: View {
    private typealias SectionData = ObjectTypeSearchViewModel.SectionData
    private typealias SectionType = ObjectTypeSearchViewModel.SectionType
    private typealias ObjectTypeData =  ObjectTypeSearchViewModel.ObjectTypeData
    
    let title: String
    let style: ObjectTypeSearchNavigationHeaderStyle
    @StateObject private var viewModel: ObjectTypeSearchViewModel
    
    init(
        title: String,
        spaceId: String,
        settings: ObjectTypeSearchViewSettings,
        style: ObjectTypeSearchNavigationHeaderStyle = .sheet,
        onSelect: @escaping (TypeSelectionResult) -> Void
    ) {
        self.title = title
        self.style = style
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
            header
            SearchBar(text: $viewModel.searchText, focused: false, placeholder: Loc.search)
            content
            pasteButton
        }
        .background(Color.Background.secondary)
        
        .snackbar(toastBarData: $viewModel.toastData)
        .anytypeSheet(item: $viewModel.newTypeInfo) {
            ObjectTypeInfoView(info: $0, mode: .create) { info in
                viewModel.onCreateTypeSubmit(info: info)
            }
        }
        
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
    
    @ViewBuilder
    private var header: some View {
        switch style {
        case .sheet:
            DragIndicator()
            TitleView(title: title) {
                if viewModel.settings.showPlusButton {
                    Button {
                        viewModel.createType(name: "")
                    } label: {
                        Image(asset: .X32.plus)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        case .navbar:
            PageNavigationHeader(title: title) {
                if viewModel.settings.showPlusButton {
                    Button {
                        viewModel.createType(name: "")
                    } label: {
                        Image(asset: .X32.plus)
                            .frame(width: 32, height: 32)
                    }
                }
            }
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
                        IconView(object: typeData.type.icon).frame(width: 18, height: 18)
                        
                        AnytypeText(typeData.type.displayName, style: .uxTitle2Medium)
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
        
        if data.type.isDeletable {
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
        style: ObjectTypeSearchNavigationHeaderStyle = .sheet,
        onTypeSelect: @escaping (_ type: ObjectType) -> Void
    ) {
        self.init(title: title, spaceId: spaceId, settings: settings, style: style, onSelect: { result in
            switch result {
            case .objectType(let type):
                onTypeSelect(type)
            case .createFromPasteboard:
                anytypeAssertionFailure("Unsupported action createFromPasteboard")
            }
        })
    }
}

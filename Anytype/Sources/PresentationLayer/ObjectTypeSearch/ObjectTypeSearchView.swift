import SwiftUI
import Services
import WrappingHStack


struct ObjectTypeSearchView: View {
    private typealias SectionData = ObjectTypeSearchViewModel.SectionData
    private typealias SectionType = ObjectTypeSearchViewModel.SectionType
    private typealias ObjectTypeData =  ObjectTypeSearchViewModel.ObjectTypeData
    
    let title: String
    @StateObject var viewModel: ObjectTypeSearchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: title)
            SearchBar(text: $viewModel.searchText, focused: false, placeholder: Loc.search)
            content
            pasteButton
        }
        .background(Color.Background.secondary)
        
        .onChange(of: viewModel.searchText) { viewModel.search(text: $0) }
        .task {
            viewModel.onAppear()
        }
    }
    
    private var pasteButton: some View {
        Group {
            if viewModel.showPasteButton {
                Button {
                    viewModel.createObjectFromClipboard()
                } label: {
                    HStack(spacing: 6) {
                        Image(asset: .X24.clipboard).foregroundStyle(Color.Button.active)
                        AnytypeText(Loc.createObjectFromClipboard, style: .caption1Medium, color: .Text.secondary)
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
                    buttonData: EmptyStateView.ButtonData(
                        title: Loc.createType,
                        action: { viewModel.createType(name: viewModel.searchText) }
                    )
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
            AnytypeText(type.name, style: .caption1Medium, color: .Text.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .padding(.bottom, 8)
    }
    
    private func typesView(section: SectionType, data: [ObjectTypeData]) -> some View {
        WrappingHStack(data, spacing: .constant(8)) { typeData in
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                viewModel.didSelectType(typeData.type, section: section)
            } label: {
                HStack(spacing: 8) {
                    if let emoji = typeData.type.iconEmoji {
                        IconView(icon: .object(.emoji(emoji)))
                            .frame(width: 18, height: 18)
                    }
                    
                    AnytypeText(typeData.type.name, style: .uxTitle2Medium, color: .Text.primary)
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
        .padding(.horizontal, 20)
    }
    
    private func shouldHighlightType(_ type: ObjectTypeData) -> Bool {
        type.isDefault && viewModel.showPins
    }
    
    @ViewBuilder
    private func contextMenu(section: SectionType, data: ObjectTypeData) -> some View {
        if viewModel.showPins {
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
        if !data.isDefault {
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

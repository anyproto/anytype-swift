import SwiftUI
import Services
import WrappingHStack


struct ObjectTypeSearchView: View {
    private typealias SectionData = ObjectTypeSearchViewModel.SectionData
    private typealias SectionType = ObjectTypeSearchViewModel.SectionType
    private typealias ObjectTypeData =  ObjectTypeSearchViewModel.ObjectTypeData
    
    let title: String
    @StateObject var viewModel: ObjectTypeSearchViewModel

    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: title)
            SearchBar(text: $searchText, focused: true, placeholder: Loc.search)
            content
        }
        .background(Color.Background.secondary)
        
        .onChange(of: searchText) { viewModel.search(text: $0) }
        .onAppear { viewModel.search(text: searchText) }
    }
    
    private var content: some View {
        Group {
            switch viewModel.state {
            case .searchResults(let sectionsData):
                searchResults(sectionsData: sectionsData)
            case .emptyScreen:
                EmptyStateView(
                    title: Loc.nothingFound,
                    subtitle: Loc.noTypeFoundText(searchText),
                    actionText: Loc.createType
                ) {
                    viewModel.createType(name: searchText)
                }
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
            .contextMenu {
                contextMenu(section: section, data: typeData)
            }
            .border(
                12,
                color: typeData.isHighlighted ? .System.amber50 : .Shape.primary,
                lineWidth: typeData.isHighlighted ? 2 : 1
            )
            .padding(.bottom, 8)
            .id(typeData.type.id)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func contextMenu(section: SectionType, data: ObjectTypeData) -> some View {
        if section == .pins {
            Button(Loc.unpin) {
                viewModel.removePinedType(data.type, currentText: searchText)
            }
        } else {
            Button(Loc.pinOnTop) {
                viewModel.addPinedType(data.type, currentText: searchText)
            }
        }
    }
}

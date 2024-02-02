import SwiftUI
import Services
import WrappingHStack


struct ObjectTypeSearchView: View {
    private typealias SectionData = ObjectTypeSearchViewModel.SectionData
    private typealias SectionType = ObjectTypeSearchViewModel.SectionType
    
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
                NewSearchErrorView(error: .noTypeError(searchText: searchText))
            }
        }
    }
    
    private func searchResults(sectionsData: [SectionData]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sectionsData) { sectionData in
                    Section(header: sectionHeader(sectionData.section)) {
                        typesView(section: sectionData.section, types: sectionData.types)
                    }
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
    
    private func typesView(section: SectionType, types: [ObjectType]) -> some View {
        WrappingHStack(types, spacing: .constant(8)) { type in
            Button {
                viewModel.didSelectType(type, section: section)
            } label: {
                HStack(spacing: 8) {
                    if let emoji = type.iconEmoji {
                        IconView(icon: .object(.emoji(emoji)))
                            .frame(width: 18, height: 18)
                    }
                    
                    AnytypeText(type.name, style: .uxTitle2Medium, color: .Text.primary)
                }
                .padding(.vertical, 15)
                .padding(.leading, 14)
                .padding(.trailing, 16)
            }
            .border(12, color: .Stroke.primary)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
    }
}

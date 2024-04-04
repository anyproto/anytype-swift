import Foundation
import SwiftUI

struct GlobalSearchView: View {
    
    @StateObject private var model: GlobalSearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: GlobalSearchModuleData) {
        self._model = StateObject(wrappedValue: GlobalSearchViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $model.state.searchText, focused: true, placeholder: Loc.search)
            content
        }
        .background(Color.Background.secondary)
        .task(id: model.state) {
            await model.search()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if model.searchData.isEmpty {
            emptyState
        } else {
            searchResults
        }
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.searchData) { section in
                    Section {
                        ForEach(section.searchData) { data in
                            itemRow(for: data)
                        }
                    } header: {
                        sectionHeader(for: section)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(for section: GlobalSearchDataSection) -> some View {
        if let sectionConfig = section.sectionConfig {
            ListSectionHeaderView(title: sectionConfig.title) {
                Button {
                    model.clear()
                } label: {
                    AnytypeText(sectionConfig.buttonTitle, style: .caption1Regular, color: .Text.secondary)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func itemRow(for data: GlobalSearchData) -> some View {
        Button {
            dismiss()
            model.onSelect(searchData: data)
        } label: {
            GlobalSearchCell(data: data)
        }
        .if(data.backlinks.isNotEmpty) {
            $0.contextMenu {
                Button(Loc.Search.Backlinks.Show.title) {
                    model.showBacklinks(data)
                }
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: Loc.thereIsNoObjectNamed(model.state.searchText),
            subtitle: Loc.createANewOneOrSearchForSomethingElse
        )
    }
}

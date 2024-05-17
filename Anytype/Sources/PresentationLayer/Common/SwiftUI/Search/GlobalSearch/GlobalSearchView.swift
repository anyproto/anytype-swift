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
        .onAppear {
            model.onAppear()
        }
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
        PlainList {
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
        .scrollIndicators(.never)
    }
    
    @ViewBuilder
    private func sectionHeader(for section: GlobalSearchDataSection) -> some View {
        if let sectionConfig = section.sectionConfig {
            ListSectionHeaderView(title: sectionConfig.title, increasedTopPadding: false) {
                Button {
                    model.clear()
                } label: {
                    AnytypeText(sectionConfig.buttonTitle, style: .caption1Regular)
                        .foregroundColor(.Text.secondary)
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
        .if(data.relatedLinks.isNotEmpty) {
            $0.contextMenu {
                Button(Loc.Search.Links.Show.title) {
                    model.showRelatedObjects(data)
                }
            }
            .swipeActions {
                Button(Loc.Search.Links.Swipe.title) {
                    model.showRelatedObjects(data)
                }
                .tint(Color.Button.active)
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: Loc.nothingFound,
            subtitle: Loc.GlobalSearch.EmptyState.subtitle
        )
    }
}

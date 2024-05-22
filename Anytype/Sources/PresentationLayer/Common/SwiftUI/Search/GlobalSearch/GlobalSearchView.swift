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
        if model.state.isInitial {
            Spacer()
        } else if model.searchData.isEmpty {
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
                    sectionHeader(for: section.sectionConfig)
                }
            }
        }
        .scrollIndicators(.never)
        .id(model.state)
    }
    
    @ViewBuilder
    private func sectionHeader(for sectionConfig: GlobalSearchDataSection.SectionConfig?) -> some View {
        if let sectionConfig {
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
        GlobalSearchCell(data: data)
            .fixTappableArea()
            .onTapGesture {
                dismiss()
                model.onSelect(searchData: data)
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
    
    @ViewBuilder
    private var emptyState: some View {
        switch model.state.mode {
        case .default:
            defaultEmptyState
        case .filtered:
            filteredEmptyState
        }
    }
    
    private var defaultEmptyState: some View {
        EmptyStateView(
            title: Loc.nothingFound,
            subtitle: Loc.GlobalSearch.EmptyState.subtitle,
            buttonData: EmptyStateView.ButtonData(
                title: Loc.createObject,
                action: {
                    dismiss()
                    model.createObject()
                }
            )
        )
    }
    
    private var filteredEmptyState: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(22)
            sectionHeader(for: model.sectionConfig())
            Spacer()
            AnytypeText(Loc.GlobalSearch.EmptyFilteredState.title, style: .calloutRegular)
                .foregroundColor(.Text.primary)
            Spacer()
        }
    }
}

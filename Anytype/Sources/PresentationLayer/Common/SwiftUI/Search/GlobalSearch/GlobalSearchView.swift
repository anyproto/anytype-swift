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
            header
            sections
            Divider()
            content
        }
        .background(Color.Background.secondary)
        .task {
            await model.startParticipantTask()
        }
        .task(id: model.state) {
            await model.search()
        }
        .onChange(of: model.dismiss) { dismiss() }
        .onChange(of: model.state.searchText) { model.onSearchTextChanged() }
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            searchBar
            if model.state.searchText.isEmpty {
                menu.transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: model.state.searchText.isEmpty)
    }
    
    private var searchBar: some View {
        SearchBar(text: $model.state.searchText, focused: true, shouldShowDivider: false)
            .submitLabel(.go)
            .onSubmit {
                model.onKeyboardButtonTap()
            }
    }
    
    private var menu: some View {
        ObjectsSortMenu(
            sort: $model.state.sort,
            label: {
                Image(asset: .X40.sorts)
            }
        )
        .padding(.leading, -8)
        .padding(.trailing, 16)
        .menuActionDismissBehavior(.disabled)
    }
    
    private var sections: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ObjectTypeSection.searchSupportedSection, id: \.self) { section in
                    AnytypeText(
                        section.title,
                        style: .uxTitle2Medium
                    )
                    .foregroundColor(model.state.section == section ? .Text.inversion : .Text.secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(model.state.section == section ? Color.Control.secondary : .clear)
                    .cornerRadius(16)
                    .fixTappableArea()
                    .onTapGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.onSectionChanged(section)
                    }
                    .animation(.easeInOut, value: model.state.section == section)
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 6)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
        } else if model.sections.isEmpty {
            emptyState
        } else {
            searchResults
        }
    }
    
    private var searchResults: some View {
        PlainList {
            ForEach(model.sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionHeaderView(title: title)
                        .padding(.horizontal, 16)
                }
                ForEach(section.rows) { rowModel in
                    itemRow(for: rowModel)
                }
            }
        }
        .scrollIndicators(.never)
        .id(model.state)
    }
    
    private func itemRow(for rowModel: SearchWithMetaModel) -> some View {
        SearchWithMetaCell(model: rowModel)
            .fixTappableArea()
            .onTapGesture {
                model.onSelect(searchData: rowModel)
            }
            .if(rowModel.canArchive) {
                $0.swipeActions {
                    Button(Loc.toBin, role: .destructive) {
                        model.onRemove(objectId: rowModel.id)
                    }
                }
            }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: Loc.nothingFound,
            subtitle: Loc.GlobalSearch.EmptyState.subtitle,
            style: .plain
        )
    }
}

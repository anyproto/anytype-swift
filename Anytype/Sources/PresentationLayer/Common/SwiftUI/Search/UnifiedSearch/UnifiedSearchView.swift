import Foundation
import SwiftUI

struct UnifiedSearchView: View {

    @State private var model: UnifiedSearchViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: UnifiedSearchModuleData) {
        self._model = State(initialValue: UnifiedSearchViewModel(data: data))
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            UnifiedSearchBar(
                tokens: model.tokenModels,
                text: $model.state.searchText,
                onRemoveToken: { model.onRemoveToken($0) }
            )
            .submitLabel(.go)
            .onSubmit {
                model.onKeyboardButtonTap()
            }
            Divider()
            content
        }
        .background(Color.Background.secondary)
        .task {
            await model.startTypesSubscription()
        }
        .task {
            await model.startParticipantTask()
        }
        .task(id: model.state) {
            await model.search()
        }
        .onChange(of: model.dismiss) { dismiss() }
        .onChange(of: model.state.searchText) { model.onSearchTextChanged() }
    }

    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
        } else if model.channelRows.isEmpty && model.rows.isEmpty {
            emptyState
        } else {
            searchResults
        }
    }

    private var searchResults: some View {
        PlainList {
            if model.channelRows.isNotEmpty {
                ListSectionHeaderView(title: Loc.UnifiedSearch.Section.channels)
                    .padding(.horizontal, 16)
                ForEach(model.channelRows) { row in
                    UnifiedSearchChannelRowView(
                        row: row,
                        onTap: { model.onSelectChannel(row) },
                        onDrill: { model.onScopeToSpace(row.spaceId) }
                    )
                }
            }

            if model.rows.isNotEmpty {
                if let objectsSectionTitle {
                    ListSectionHeaderView(title: objectsSectionTitle)
                        .padding(.horizontal, 16)
                }
                ForEach(model.rows) { rowModel in
                    itemRow(for: rowModel)
                }
            }
        }
        .scrollIndicators(.never)
        .id(model.state.tokens)
    }

    private var objectsSectionTitle: String? {
        if model.state.searchText.isEmpty {
            Loc.UnifiedSearch.Section.recentObjects
        } else if model.channelRows.isNotEmpty {
            Loc.UnifiedSearch.Section.objects
        } else {
            nil
        }
    }

    private func itemRow(for rowModel: SearchWithMetaModel) -> some View {
        Button {
            model.onSelect(searchData: rowModel)
        } label: {
            SearchWithMetaCell(
                model: rowModel,
                onSpaceCaptionTap: rowModel.spaceCaption.map { caption in
                    { model.onScopeToSpace(caption.spaceId) }
                }
            )
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(rowModel.canArchive) {
            $0.swipeActions {
                Button(Loc.delete, role: .destructive) {
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

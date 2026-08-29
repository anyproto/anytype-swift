import Foundation
import SwiftUI

struct UnifiedSearchView: View {

    @State private var model: UnifiedSearchViewModel
    @Namespace private var glassNamespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var barExpanded = false

    init(data: UnifiedSearchModuleData) {
        self._model = State(initialValue: UnifiedSearchViewModel(data: data))
    }

    var body: some View {
        // Search block floats at the bottom above the keyboard,
        // matching the vault's bottom-anchored search), results scroll behind it
        VStack(spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaBarIOS26(edge: .bottom, spacing: 0) {
            bottomBlock
        }
        .background(Color.Background.secondary)
        .homeBottomPanelHidden(true)
        .onAppear {
            guard model.animatesBarExpansion, !reduceMotion else {
                barExpanded = true
                return
            }
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                barExpanded = true
            }
        }
        .task {
            await model.observeTypes()
        }
        .task {
            await model.observeMembers()
        }
        .task {
            await model.observeChats()
        }
        .task {
            await model.observeSpaces()
        }
        .task {
            await model.startParticipantTask()
        }
        .task(id: model.state) {
            await model.search()
        }
        .onChange(of: model.state.searchText) { model.onSearchTextChanged() }
        .sheet(isPresented: $model.showPeoplePicker) {
            UnifiedSearchPickerView(rows: model.peoplePickerRows) {
                model.onSelectPerson($0)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $model.showTypesPicker) {
            UnifiedSearchPickerView(rows: model.typesPickerRows) {
                model.onSelectType($0)
            }
            .presentationDetents([.medium, .large])
        }
    }

    @ViewBuilder
    private var bottomBlock: some View {
        // Container spacing must stay below the chip row's layout spacing (8),
        // or adjacent glass capsules blend together at rest
        let block = GlassEffectContainerIOS26(spacing: 6) {
            VStack(spacing: 0) {
                if model.chips.isNotEmpty {
                    UnifiedSearchChipsRowView(chips: model.chips, glassNamespace: glassNamespace) {
                        model.onChipTap($0)
                    }
                }
                HStack(spacing: 10) {
                    UnifiedSearchBar(
                        tokens: model.tokenModels,
                        selectedTokenId: model.selectedTokenId,
                        collapsesToIcons: model.state.searchText.isNotEmpty,
                        text: $model.state.searchText,
                        onTokenTap: { model.onTokenTap($0) },
                        onRemoveToken: { model.onRemoveToken($0) },
                        onBackspaceWhenEmpty: { model.onBackspaceWhenEmpty() },
                        onSubmit: { model.onKeyboardButtonTap() }
                    )
                    cancelButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        // The bar springs open from the entry button's corner
        .scaleEffect(model.animatesBarExpansion && !barExpanded ? 0.2 : 1, anchor: .bottomLeading)
        .opacity(model.animatesBarExpansion && !barExpanded ? 0 : 1)
        if #available(iOS 26.0, *) {
            block
        } else {
            block.background(Color.Background.secondary)
        }
    }

    private var cancelButton: some View {
        Button {
            model.onCancel()
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.Control.primary)
                .frame(width: 44, height: 44)
                .cancelBackground
                .fixTappableArea()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Loc.cancel)
    }

    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
        } else if model.channelRows.isEmpty && model.personRows.isEmpty && model.rows.isEmpty && model.messageRows.isEmpty {
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
                        onDrill: { model.onScopeToSpace(row.spaceId, source: .row) }
                    )
                }
            }

            if model.personRows.isNotEmpty {
                ListSectionHeaderView(title: Loc.UnifiedSearch.Section.people)
                    .padding(.horizontal, 16)
                ForEach(model.personRows) { row in
                    UnifiedSearchPersonRowView(
                        row: row,
                        onTap: { model.onSelectPersonRow(row) },
                        onDrill: { model.onDrillPersonRow(row) }
                    )
                }
            }

            ForEach(model.rowSections) { section in
                if let title = section.data ?? objectsSectionTitle {
                    // The result cells carry their own top inset - a tight header
                    // bottom keeps the group visually attached to its rows
                    ListSectionHeaderView(title: title, bottomPadding: 0)
                        .padding(.horizontal, 16)
                }
                ForEach(section.rows) { rowModel in
                    itemRow(for: rowModel)
                }
            }

            if model.messageRows.isNotEmpty {
                if model.state.searchText.isEmpty {
                    ListSectionHeaderView(title: Loc.UnifiedSearch.Section.recentMessages)
                        .padding(.horizontal, 16)
                }
                ForEach(model.messageRows) { row in
                    UnifiedSearchMessageRowView(
                        row: row,
                        onTap: { model.onSelectMessage(row) }
                    )
                }
            }

            // Appears when scrolled to the end - loads the next page
            Color.clear
                .frame(height: 1)
                .onAppear { model.onReachedBottom() }
                .id("load-more-\(model.loadMoreSentinelId)")
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
        .id(model.state.tokens)
    }

    // The empty browse titles itself with day groups; a text search shows one
    // "Objects" header only when channel/person rows precede it
    private var objectsSectionTitle: String? {
        if model.channelRows.isNotEmpty || model.personRows.isNotEmpty {
            Loc.UnifiedSearch.Section.objects
        } else {
            nil
        }
    }

    private func itemRow(for rowModel: SearchWithMetaModel) -> some View {
        Button {
            model.onSelect(searchData: rowModel)
        } label: {
            SearchWithMetaCell(model: rowModel)
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

private extension View {
    @ViewBuilder
    var cancelBackground: some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .circle)
        } else {
            self
                .background(Color.Background.highlightedMedium)
                .clipShape(.circle)
        }
    }
}

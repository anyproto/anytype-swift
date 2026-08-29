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
        // Paint to the physical screen bottom, under the keyboard too - the
        // app switcher snapshots without a keyboard, and the underlying screen
        // must not show through the gap
        .background(Color.Background.secondary.ignoresSafeArea())
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
        .onChange(of: model.state.searchText) {
            model.dismissOnboarding()
            model.onSearchTextChanged()
        }
        .overlay {
            if model.showOnboarding {
                onboardingOverlay
            }
        }
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
                        focusRequestId: model.fieldFocusRequestId,
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
        .fitIPadToReadableContentGuide()
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
        } else if !model.showsCreateChannelAction && model.channelRows.isEmpty && model.personRows.isEmpty && model.typeRows.isEmpty && model.focusRows.isEmpty && model.focusSuggestions.isEmpty && model.rows.isEmpty && model.messageRows.isEmpty {
            emptyState
        } else {
            searchResults
                .fitIPadToReadableContentGuide()
        }
    }

    private var searchResults: some View {
        PlainList {
            // Focused listing: the way back out wide first, then the per-space instances
            ForEach(model.focusSuggestions) { suggestion in
                focusSuggestionRow(suggestion)
            }
            if model.focusRows.isNotEmpty {
                if let title = model.focusSectionTitle {
                    ListSectionHeaderView(title: title, increasedTopPadding: false, bottomPadding: 0)
                        .padding(.horizontal, 16)
                }
                ForEach(model.focusRows) { row in
                    UnifiedSearchLeadRowView(
                        icon: row.icon,
                        title: row.title,
                        caption: row.caption,
                        badged: row.kind != .typeInstance,
                        onTap: { model.onSelectFocusRow(row) },
                        onDrill: { model.onSelectFocusRow(row) }
                    )
                }
            }

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

            if model.showsCreateChannelAction {
                createChannelRow
            }

            if model.personRows.isNotEmpty {
                ListSectionHeaderView(title: Loc.UnifiedSearch.Section.people)
                    .padding(.horizontal, 16)
                ForEach(model.personRows) { row in
                    UnifiedSearchLeadRowView(
                        icon: row.icon,
                        title: row.title,
                        caption: row.caption,
                        badged: true,
                        onTap: { model.onSelectPersonRow(row) },
                        onDrill: { model.onDrillPersonRow(row) }
                    )
                }
            }

            if model.typeRows.isNotEmpty {
                ListSectionHeaderView(title: Loc.UnifiedSearch.Chip.types)
                    .padding(.horizontal, 16)
                ForEach(model.typeRows) { row in
                    UnifiedSearchLeadRowView(
                        icon: row.icon,
                        title: row.title,
                        caption: row.subtitle,
                        onTap: { model.onSelectTypeRow(row) },
                        onDrill: { model.onDrillTypeRow(row) }
                    )
                }
            }

            ForEach(model.rowSections) { section in
                if let title = section.data ?? objectsSectionTitle {
                    // The result cells carry their own top inset - a tight header
                    // bottom keeps the group visually attached to its rows.
                    // The first day header carries the recency toggle.
                    if section.data != nil, section.id == model.rowSections.first?.id {
                        ListSectionHeaderView(title: title, bottomPadding: 0) {
                            browseSortMenu
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ListSectionHeaderView(title: title, bottomPadding: 0)
                            .padding(.horizontal, 16)
                    }
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
    }

    // The empty browse titles itself with day groups; a text search shows one
    // "Objects" header only when channel/person rows precede it
    private var objectsSectionTitle: String? {
        if model.channelRows.isNotEmpty || model.personRows.isNotEmpty || model.typeRows.isNotEmpty {
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

    // One-time "Meet the new search" hint over the results area; any tap
    // (or typing) dismisses and counts as seen
    private var onboardingOverlay: some View {
        VStack(spacing: 12) {
            AnytypeText(Loc.UnifiedSearch.Onboarding.title, style: .heading)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)
            AnytypeText(Loc.UnifiedSearch.Onboarding.subtitle, style: .uxCalloutRegular)
                .foregroundStyle(Color.Text.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                ForEach([Loc.UnifiedSearch.Chip.messages, Loc.UnifiedSearch.Chip.byMe, Loc.media], id: \.self) { sample in
                    AnytypeText(sample, style: .uxTitle2Medium)
                        .foregroundStyle(Color.Text.secondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.Shape.transparentSecondary)
                        .clipShape(.capsule)
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(Color.Background.secondary.opacity(0.97))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        // A tap anywhere over the results counts as seen
        .onTapGesture {
            model.dismissOnboarding()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Loc.UnifiedSearch.Onboarding.title)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: model.showOnboarding)
    }

    private var browseSortMenu: some View {
        Menu {
            ForEach([UnifiedSearchBrowseSort.edited, .created], id: \.self) { sort in
                Button {
                    model.onToggleBrowseSort(sort)
                } label: {
                    if sort == model.state.browseSort {
                        Label(sort.title, systemImage: "checkmark")
                    } else {
                        Text(sort.title)
                    }
                }
            }
        } label: {
            HStack(spacing: 2) {
                AnytypeText(model.state.browseSort.title, style: .relation2Regular)
                    .foregroundStyle(Color.Text.secondary)
                Image(asset: .X18.Disclosure.down)
                    .foregroundStyle(Color.Control.secondary)
            }
            .fixTappableArea()
        }
    }

    private var createChannelRow: some View {
        Menu {
            CreateChannelMenuItems(
                onTapPersonal: { model.onCreatePersonalChannel() },
                onTapGroup: { model.onCreateGroupChannel() },
                onTapJoinQR: { model.onJoinQrCode() }
            )
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: 24, height: 24)
                AnytypeText(Loc.Channel.Create.EmptyState.button, style: .uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer()
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 16)
            .fixTappableArea()
        }
    }

    private func focusSuggestionRow(_ suggestion: UnifiedSearchFocusSuggestion) -> some View {
        Button {
            model.onSelectFocusSuggestion(suggestion)
        } label: {
            HStack(spacing: 12) {
                Image(asset: .X18.search)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 24, height: 24)
                AnytypeText(suggestion.title, style: .uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer()
            }
            .frame(minHeight: 36)
            .padding(.horizontal, 16)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
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

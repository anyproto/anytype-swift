import SwiftUI

struct AllContentView: View {
    
    @StateObject private var model: AllContentViewModel
    
    init(spaceId: String, output: (any AllContentModuleOutput)?) {
        _model = StateObject(wrappedValue: AllContentViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            sections
            SearchBar(text: $model.searchText, focused: false, placeholder: Loc.search)
            content
        }
        .task {
            await model.startParticipantTask()
        }
        .task(id: model.state) {
            await model.restartSubscription()
        }
        .task(id: model.searchText) {
            await model.search()
        }
        .onAppear() {
            model.onAppear()
        }
        .onDisappear() {
            model.onDisappear()
        }
        .onChange(of: model.state.sort) { newValue in
            model.onChangeSort()
        }
        .onChange(of: model.state.mode) { newValue in
            model.onChangeMode()
        }
    }
    
    private var navigationBar: some View {
        PageNavigationHeader(title: model.state.mode.title) {
            settingsMenu
        }
    }
    
    private var settingsMenu: some View {
        AllContentSettingsMenu(
            state: $model.state,
            binTapped: {
                model.binTapped()
            }
        )
    }
    
    @ViewBuilder
    private var content: some View {
        if model.firstOpen {
            Spacer()
        } else if model.sections.isEmpty {
            emptyState
        } else {
            list
        }
    }
    
    private var list: some View {
        PlainList {
            if model.state.mode == .unlinked {
                onlyUnlinkedBanner
            }
            ForEach(model.sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionHeaderView(title: title)
                        .padding(.horizontal, 20)
                }
                ForEach(section.rows, id: \.id) { row in
                    WidgetObjectListRowView(model: row)
                        .onAppear {
                            model.onAppearLastRow(row.id)
                        }
                        .if(row.canArchive) {
                            $0.swipeActions {
                                Button(Loc.toBin, role: .destructive) {
                                    model.onDelete(objectId: row.objectId)
                                }
                            }
                        }
                }
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
        .id(model.state.scrollId + model.searchText)
    }
    
    private var sections: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(ObjectTypeSection.allContentSupportedSections, id: \.self) { section in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.sectionChanged(section)
                    } label: {
                        AnytypeText(
                            section.title,
                            style: .uxTitle2Medium
                        )
                        .foregroundColor(model.state.section == section ? Color.Control.button : Color.Control.active)
                    }
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 20)
        }
    }
    
    private var onlyUnlinkedBanner: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(14)
            AnytypeText(Loc.AllContent.Settings.Unlinked.description, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(14)
        }
        .divider(spacing: 0, alignment: .leading)
        .padding(.horizontal, 16)
    }
    
    private var emptyState: some View {
        let emptySearchText = model.searchText.isEmpty
        let title = emptySearchText ? Loc.EmptyView.Default.title : Loc.AllContent.Search.Empty.State.title
        let subtitle = emptySearchText ? Loc.EmptyView.Default.subtitle : Loc.AllContent.Search.Empty.State.subtitle
        return EmptyStateView(
            title: title,
            subtitle: subtitle,
            style: .plain
        )
    }
}

#Preview {
    AllContentView(spaceId: "", output: nil)
}

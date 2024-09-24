import SwiftUI

struct AllContentView: View {
    
    @StateObject private var model: AllContentViewModel
    
    init(spaceId: String, output: (any AllContentModuleOutput)?) {
        _model = StateObject(wrappedValue: AllContentViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            types
            SearchBar(text: $model.searchText, focused: false, placeholder: Loc.search)
            content
        }
        .task(id: model.state) {
            await model.restartSubscription()
        }
        .task(id: model.searchText) {
            await model.search()
        }
        .onDisappear() {
            model.onDisappear()
        }
    }
    
    private var navigationBar: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            AnytypeText(model.state.mode.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
        }
        .overlay(alignment: .trailing) {
            settingsMenu
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var settingsMenu: some View {
        AllContentSettingsMenu(
            state: model.state,
            modeChanged: { mode in
                model.modeChanged(mode)
            },
            sortRelationChanged: { relation in
                model.sortRelationChanged(relation)
            },
            sortTypeChanged: { type in
                model.sortTypeChanged(type)
            },
            binTapped: {
                model.binTapped()
            }
        )
    }
    
    private var content: some View {
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
                }
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
        .id(model.state.scrollId + model.searchText)
    }
    
    private var types: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(AllContentType.allCases, id: \.self) { type in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.typeChanged(type)
                    } label: {
                        AnytypeText(
                            type.title,
                            style: .uxTitle2Medium
                        )
                        .foregroundColor(model.state.type == type ? Color.Button.button : Color.Button.active)
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
            Spacer.fixedHeight(model.state.sort.relation.canGroupByDate ? 0 : 14)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    AllContentView(spaceId: "", output: nil)
}

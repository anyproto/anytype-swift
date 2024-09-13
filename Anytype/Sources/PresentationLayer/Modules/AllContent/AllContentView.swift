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
            modesMenu
            Spacer()
        }
        .overlay(alignment: .leading) {
            sortsMenu
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var modesMenu: some View {
        Menu {
            ForEach(AllContentMode.allCases, id: \.self) { mode in
                Button {
                    model.onModeChanged(mode)
                } label: {
                    HStack(spacing: 0) {
                        AnytypeText(
                            mode.title,
                            style: .uxTitle2Medium
                        )
                        .foregroundColor(.Button.button)
                        
                        Spacer()
                        
                        if model.state.mode == mode {
                            Image(asset: .X24.tick)
                                .foregroundColor(.Text.primary)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                AnytypeText(model.state.mode.title, style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
                Image(asset: .X18.Disclosure.down)
                    .foregroundColor(.Text.primary)
            }
        }
    }
    
    private var sortsMenu: some View {
        Menu {
            ForEach(AllContentSort.Relation.allCases, id: \.self) { sortRelation in
                Button {
                    model.onSortChanged(sortRelation)
                } label: {
                    HStack(spacing: 0) {
                        AnytypeText(
                            sortRelation.title,
                            style: .uxTitle2Medium
                        )
                        .foregroundColor(.Button.button)
                        
                        Spacer()
                        
                        if model.state.sort.relation == sortRelation {
                            Image(asset: model.state.sort.type == .asc ? .X24.Arrow.down : .X24.Arrow.up)
                                .foregroundColor(.Text.primary)
                        }
                    }
                }
            }
        } label: {
            Image(asset: .X28.sort)
                .foregroundColor(.Button.active)
        }
    }
    
    private var content: some View {
        PlainList {
            ForEach(model.rows, id: \.id) { model in
                WidgetObjectListRowView(model: model)
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var types: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(AllContentType.allCases, id: \.self) { type in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.onTypeChanged(type)
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
}

#Preview {
    AllContentView(spaceId: "", output: nil)
}

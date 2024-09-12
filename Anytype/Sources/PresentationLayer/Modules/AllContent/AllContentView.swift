import SwiftUI

struct AllContentView: View {
    
    @StateObject private var model: AllContentViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: AllContentViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.allContent)
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
    
    private var content: some View {
        PlainList {
            ForEach(model.rows, id: \.id) { row in
                SearchObjectRowView(
                    viewModel: row,
                    selectionIndicatorViewModel: nil
                )
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
    AllContentView(spaceId: "")
}

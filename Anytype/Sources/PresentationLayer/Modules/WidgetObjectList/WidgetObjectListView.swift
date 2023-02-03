import SwiftUI

struct WidgetObjectListView<Model: WidgetObjectListViewModelProtocol>: View {
    
    @ObservedObject var model: Model
    @State var searchText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: model.title)
            SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.rows, id: \.objectId) {
                        ListWidgetRow(model: $0)
                    }
                }
            }
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear() {
            model.onDisappear()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

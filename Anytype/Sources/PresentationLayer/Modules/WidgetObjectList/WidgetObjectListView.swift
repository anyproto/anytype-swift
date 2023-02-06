import SwiftUI

struct WidgetObjectListView: View {
    
    @ObservedObject var model: WidgetObjectListViewModel
    @State var searchText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: model.title)
            SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.rows) { row in
                        row.makeView()
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
        .onChange(of: searchText) { model.didAskToSearch(text: $0) }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

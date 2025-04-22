import SwiftUI
import Loc

struct BinListView: View {
    
    @StateObject private var model: BinListViewModel
    @State private var searchText: String = ""
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: BinListViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                PageNavigationHeader(title: Loc.bin) {
                    editButton
                }
                SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                content
            }
            optionsView
        }
        .task {
            await model.startSubscriptions()
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenBin()
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: searchText) { model.onSearch(text: $0) }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var editButton: some View {
        // TODO: implement
    }
    
    @ViewBuilder
    private var content: some View {
        // TODO: implement
        Spacer()
    }
    
    @ViewBuilder
    private var optionsView: some View {
        // TODO: implement
    }
}

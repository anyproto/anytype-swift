import SwiftUI

struct WidgetObjectListView<Model: WidgetObjectListViewModelProtocol>: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.rows, id: \.objectId) {
                    ListWidgetRow(model: $0)
                }
            }
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear() {
            model.onDisappear()
        }
    }
}

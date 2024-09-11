import SwiftUI

struct AllContentView: View {
    
    @StateObject private var model: AllContentViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: AllContentViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.allContent)
            content
        }
        .onAppear {
            model.onAppear()
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
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    AllContentView(spaceId: "")
}

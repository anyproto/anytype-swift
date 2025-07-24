import SwiftUI
import AnytypeCore

struct PublishToWebViewData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    
    var id: Int { hashValue }
}


struct PublishToWebView: View {
    
    @StateObject private var model: PublishToWebViewModel
    private weak var output: (any PublishToWebModuleOutput)?
    
    init(data: PublishToWebViewData, output: (any PublishToWebModuleOutput)?) {
        _model = StateObject(wrappedValue: PublishToWebViewModel(data: data))
        self.output = output
    }
    
    var body: some View {
        Group {
            switch model.state {
            case .initial:
                EmptyView()
            case .error(let error):
                ErrorStateView(message: error)
            case .loaded(let data):
                PublishToWebInternalView(data: data, output: output)
            }
        }
        .task { await model.onAppear() }
        .animation(.default, value: model.state)
    }
}

#Preview {
    PublishToWebView(data: PublishToWebViewData(objectId: "", spaceId: ""), output: nil)
}

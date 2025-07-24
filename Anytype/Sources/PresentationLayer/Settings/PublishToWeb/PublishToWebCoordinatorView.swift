import SwiftUI

struct PublishToWebCoordinatorView: View {
    
    @StateObject private var model: PublishToWebCoordinatorViewModel
    
    init(data: PublishToWebViewData) {
        _model = StateObject(wrappedValue: PublishToWebCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        PublishToWebView(data: model.data, output: model)
            .sheet(isPresented: $model.showMembership) {
                MembershipCoordinator()
            }
    }
}
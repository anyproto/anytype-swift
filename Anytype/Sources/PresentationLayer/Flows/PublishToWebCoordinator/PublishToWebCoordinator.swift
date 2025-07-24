import SwiftUI

struct PublishToWebCoordinator: View {
    
    @StateObject private var model: PublishToWebCoordinatorModel
    
    init(data: PublishToWebViewData) {
        _model = StateObject(wrappedValue: PublishToWebCoordinatorModel(data: data))
    }
    
    var body: some View {
        PublishToWebView(data: model.data, output: model)
            .sheet(isPresented: $model.showMembership) {
                MembershipCoordinator()
            }
    }
}
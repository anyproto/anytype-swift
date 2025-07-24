import Foundation
import SwiftUI

@MainActor
protocol PublishToWebModuleOutput: AnyObject {
    func onShowMembership()
}

@MainActor
final class PublishToWebCoordinatorViewModel: ObservableObject, PublishToWebModuleOutput {
    
    @Published var showMembership = false
    
    let data: PublishToWebViewData
    
    init(data: PublishToWebViewData) {
        self.data = data
    }
    
    // MARK: - PublishToWebModuleOutput
    
    func onShowMembership() {
        showMembership = true
    }
}

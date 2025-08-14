import Foundation
import SwiftUI
import UIKit

@MainActor
protocol PublishToWebModuleOutput: AnyObject {
    func onShowMembership()
    func onSharePreview(url: URL)
    func onOpenPreview(url: URL)
}

@MainActor
final class PublishToWebCoordinatorModel: ObservableObject, PublishToWebModuleOutput {
    
    @Published var showMembership = false
    @Published var sharedUrl: URL?
    @Published var safariUrl: URL?
    
    let data: PublishToWebViewData
    
    init(data: PublishToWebViewData) {
        self.data = data
    }
    
    // MARK: - PublishToWebModuleOutput
    
    func onShowMembership() {
        showMembership = true
    }
    
    func onSharePreview(url: URL) {
        sharedUrl = url
    }
    
    func onOpenPreview(url: URL) {
        safariUrl = url
    }
}

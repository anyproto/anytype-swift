import Foundation
import Combine
import SwiftUI


@MainActor
final class PublishToWebViewModel: ObservableObject {
    
    @Published var domain: String = "vova.any.org"
    @Published var customPath: String = "how-to-be-a-great-engineer"
    @Published var showJoinSpaceButton: Bool = true
    @Published var canPublish: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func onPublishTap() {
        // TBD;
    }
    
    private func setupBindings() {
        $customPath
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$canPublish)
    }
}

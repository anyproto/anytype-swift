import Foundation
import TipKit
import Combine
import SwiftUI

@available(iOS 17.0, *)
private struct SpaceCreationTipImpl: Tip {
    var title: Text {
        Text(verbatim: "Create Chats")
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(10)
    }
}

@MainActor
class SpaceCreationTipWrapper: ObservableObject {
    @Published var shouldDisplay = false
    
    init() {
        startUpdating()
    }
    
    private func startUpdating() {
        if #available(iOS 17.0, *) {
            Task { @MainActor in
                for await shouldDisplayValue in SpaceCreationTipImpl().shouldDisplayUpdates {
                    shouldDisplay = shouldDisplayValue
                }
            }
        }
    }
    
    func invalidate() {
        if #available(iOS 17.0, *) {
            SpaceCreationTipImpl().invalidate(reason: .actionPerformed)
        }
    }
}

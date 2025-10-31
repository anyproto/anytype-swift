import Foundation
import TipKit
import Combine
import SwiftUI

struct SpaceCreationTip: Tip {
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
        Task { @MainActor in
            for await shouldDisplayValue in SpaceCreationTip().shouldDisplayUpdates {
                shouldDisplay = shouldDisplayValue
            }
        }
    }

    func invalidate() {
        SpaceCreationTip().invalidate(reason: .actionPerformed)
    }
}

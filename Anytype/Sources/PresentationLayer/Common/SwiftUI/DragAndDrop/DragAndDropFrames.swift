import Foundation
import SwiftUI

struct AnytypeDragAndDropFrames: EnvironmentKey {
    static let defaultValue = DragAndDropFrames()
}

extension EnvironmentValues {
    var anytypeDragAndDropFrames: DragAndDropFrames {
        get { self[AnytypeDragAndDropFrames.self] }
        set { self[AnytypeDragAndDropFrames.self] = newValue }
    }
}

final class DragAndDropFrames {
    var frames: [String: CGRect] = [:]
}

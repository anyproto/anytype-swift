import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var anytypeDragAndDropFrames = DragAndDropFrames()
}

final class DragAndDropFrames {
    var frames: [String: CGRect] = [:]
}

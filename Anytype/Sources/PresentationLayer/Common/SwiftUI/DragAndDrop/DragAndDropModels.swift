import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var anytypeDragState: Binding<DragState> = .constant(DragState())
    @Entry var anytypeDragAndDropPendingCommit = DragAndDropPendingCommit()
}

struct DropDataElement<Data> {
    var data: Data
    var index: Int
}

struct DragState {
    var dragInitiateId: String? = nil
    var dragInProgress: Bool = false
    
    mutating func resetState() {
        dragInitiateId = nil
        dragInProgress = false
    }
}

struct DropState<Data> {
    var fromElement: DropDataElement<Data>? = nil
    var toElement: DropDataElement<Data>? = nil
    
    mutating func resetState() {
        self = DropState()
    }
}

final class DragAndDropPendingCommit {
    var commit: (() -> Void)?
}

class DragItemProvider: NSItemProvider {
    var didEnd: (() -> Void)?

    deinit {
        // Deferred to the next runloop to avoid re-entrant @Binding mutation when deinit
        // fires during SwiftUI graph tear-down or drag payload release.
        let didEnd = didEnd
        DispatchQueue.main.async { didEnd?() }
    }
}

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var anytypeDragState: Binding<DragState> = .constant(DragState())
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

class DragItemProvider: NSItemProvider {
    var didEnd: (() -> Void)?
    deinit {
        didEnd?()
    }
}

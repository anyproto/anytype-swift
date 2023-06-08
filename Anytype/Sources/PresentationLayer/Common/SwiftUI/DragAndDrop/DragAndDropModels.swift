import Foundation
import SwiftUI

struct AnytypeDragState: EnvironmentKey {
    static let defaultValue: Binding<DragState> = .constant(DragState())
}

extension EnvironmentValues {
    var anytypeDragState: Binding<DragState> {
        get { self[AnytypeDragState.self] }
        set { self[AnytypeDragState.self] = newValue }
    }
}

struct DropDataElement<Data> {
    var data: Data
    var index: Int
}

struct DragState {
    var dragInitiateId: String? = nil
    var dragInProgress: Bool = false
    var frames: [String: CGRect] = [:]
    
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

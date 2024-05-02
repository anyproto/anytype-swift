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

final class DragState: ObservableObject {
    @Published var dragInitiateId: String? = nil
    @Published var dragInProgress: Bool = false
    
    // Not make Published, will be affect ui update.
    // When one view set frame, all other view with DragState will be updated.
    var frames: [String: CGRect] = [:]
    
    func resetState() {
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

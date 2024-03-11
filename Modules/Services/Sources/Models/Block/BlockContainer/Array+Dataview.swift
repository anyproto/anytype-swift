import AnytypeCore
import SwiftUI

// TODO: Delete active view ID from middleware model

extension Array where Element == DataviewView {
    // Looking forward first, then backward
    func findNextSupportedView(mainIndex: Int) -> DataviewView? {
        guard indices.contains(mainIndex) else { return nil }
        
        for index in (mainIndex + 1..<count) {
            return self[index]
        }
        for index in (0..<mainIndex).reversed() {
            return self[index]
        }
        
        return nil
    }
}

public extension DataviewViewType {
    var isSupported: Bool {
        self == .table ||
        self == .gallery ||
        self == .list ||
        (FeatureFlags.setKanbanView && self == .kanban)
    }
}

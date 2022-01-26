import BlocksModels
import AnytypeCore
import SwiftUI

extension Array where Element == DataviewView {
    // Looking forward first, then backward
    func findNextSupportedView(mainIndex: Int) -> DataviewView? {
        guard indices.contains(mainIndex) else { return nil }
        
        for index in (mainIndex + 1..<count) {
            if self[index].isSupported {
                return self[index]
            }
        }
        for index in (0..<mainIndex).reversed() {
            if self[index].isSupported {
                return self[index]
            }
        }
        
        return nil
    }
}

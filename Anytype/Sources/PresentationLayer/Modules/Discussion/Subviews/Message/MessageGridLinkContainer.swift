import Foundation
import SwiftUI
import Services

struct MessageGridLinkContainer: View {

    let objects: [[ObjectDetails]]
    let onTapObject: (ObjectDetails) -> Void
    
    private let oneSide: CGFloat = 297
    private let twoSize: CGFloat = (297 - 4) * 0.5
    private let treeSize: CGFloat = (297 - 8) * 0.33
    
    var body: some View {
        Grid {
            ForEach(0..<objects.count) { index in
                GridRow {
                    ForEach(0..<objects[index].count) { rowItems in
                        GeometryReader { geometry in
                            Color.red
                                .frame(width: 50, height: 50)
//                                .frame(width: rowItemSize(rowItems: rowItems), height: rowItemSize(rowItems: rowItems))
                        }
                    }
                }
            }
        }
    }
    
    private func rowItemSize(rowItems: Int) -> CGFloat? {
        switch rowItems {
        case 3:
            return treeSize
        case 2:
            return twoSize
        case 1:
            return oneSide
        default:
            return nil
        }
    }
}

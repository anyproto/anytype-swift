import Foundation
import SwiftUI
import Services

struct MessageGridLinkContainer: View {

    let objects: [[ObjectDetails]]
    let onTapObject: (ObjectDetails) -> Void
    
    private enum Constants {
        static let spacing: CGFloat = 4
        static let oneSide: CGFloat = 250
        static let twoSide: CGFloat = (Constants.oneSide - Constants.spacing) * 0.5
        static let treeSide: CGFloat = (Constants.oneSide - Constants.spacing * 2) * 0.33
        
    }
    
    var body: some View {
        Grid(horizontalSpacing: Constants.spacing, verticalSpacing: Constants.spacing) {
            ForEach(objects, id:\.self) { rowObjects in
                GridRow {
                    ForEach(rowObjects, id:\.id) { object in
                            Color.red
                            .frame(width: rowItemSize(rowItems: rowObjects.count), height: rowItemSize(rowItems: rowObjects.count))
                    }
                }
            }
        }
    }
    
    private func rowItemSize(rowItems: Int) -> CGFloat? {
        switch rowItems {
        case 3:
            return Constants.treeSide
        case 2:
            return Constants.twoSide
        case 1:
            return Constants.oneSide
        default:
            return nil
        }
    }
}

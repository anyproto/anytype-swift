import Foundation
import SwiftUI

struct TodoIconView: View {
    
    private static let maxSide = 28.0
    
    let checked: Bool
    
    var body: some View {
        Image(asset: checked ? .TaskLayout.done : .TaskLayout.empty)
            .resizable()
            .scaledToFit()
            .buttonDynamicForegroundStyle()
            .frame(maxWidth: 28, maxHeight: 28)
    }
}

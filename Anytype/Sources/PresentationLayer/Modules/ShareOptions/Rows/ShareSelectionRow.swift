import Foundation
import SwiftUI

struct ShareSelectionRow: View {
    
    let text: String
    let selected: Bool
    
    var body: some View {
        HStack {
            Image(asset: .system(name: "checkmark"))
                .opacity(selected ? 1 : 0)
                .foregroundColor(.blue)
            Spacer.fixedWidth(8)
            AnytypeText(text, style: .bodyRegular, color: .Text.primary)
            Spacer()
        }
    }
}

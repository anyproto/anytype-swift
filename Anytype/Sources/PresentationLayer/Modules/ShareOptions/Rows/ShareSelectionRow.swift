import Foundation
import SwiftUI

struct ShareSelectionRow: View {
    
    let text: String
    let selected: Bool
    
    var body: some View {
        HStack {
            Image(asset: .system(name: "checkmark"))
                .hidden(!selected)
                .foregroundColor(.blue)
            Spacer.fixedWidth(8)
            AnytypeText(text, style: .bodyRegular)
                .foregroundColor(.Text.primary)
            Spacer()
        }
    }
}

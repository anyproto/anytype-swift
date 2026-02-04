import Foundation
import SwiftUI

struct DebugMenuInputSettings: View {
    
    let title: String
    let placeholder: String
    @Binding var inputText: String
    
    var body: some View {
        HStack {
            AnytypeText(title, style: .bodyRegular)
                .foregroundStyle(Color.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField(placeholder, text: $inputText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }
        .padding(20)
        .background(UIColor.systemGroupedBackground.suColor)
    }
    
}

import Foundation
import SwiftUI

struct MessageView: View {
    
    let block: MessageBlock
    
    var body: some View {
        Text(block.text)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(Color.gray)
            .cornerRadius(8)
    }
}

import Foundation
import SwiftUI

struct PlaceholderIconView: View {
    
    let text: String
    
    var body: some View {
        ImageCharIconView(text: text)
            .background(Color.Shape.secondary)
            .cornerRadius(2)
    }
}

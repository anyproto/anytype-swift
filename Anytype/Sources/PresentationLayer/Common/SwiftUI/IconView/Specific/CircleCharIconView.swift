import Foundation
import SwiftUI

struct CircleCharIconView: View {
    
    // MARK: - Public properties
    
    let text: String
    
    var body: some View {
        CharIconView(text: text)
            .mask(Circle())
    }
}

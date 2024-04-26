import Foundation
import SwiftUI

struct SectionHeaderView: View {
    
    let title: String
    
    var body: some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .caption1Regular, color: .Text.secondary)
            Spacer()
        }
        .padding(.top, 26)
        .padding(.bottom, 8)
    }
}

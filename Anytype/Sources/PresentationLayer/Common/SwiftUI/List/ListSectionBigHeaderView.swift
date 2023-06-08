import SwiftUI

struct ListSectionBigHeaderView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .uxCalloutRegular, color: .Text.secondary)
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
        .padding(.horizontal, 16)
    }
}

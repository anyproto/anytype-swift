import SwiftUI

struct SpaceTypeView: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(asset: .X24.privateSpace)
                .foregroundColor(.Text.primary)
            AnytypeText(name, style: .bodyRegular, color: .Text.primary)
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

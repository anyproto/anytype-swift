import SwiftUI

struct SpaceTypeView: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 4) {
            // TODO: add icon
            Color.gray.frame(width: 20, height: 20)
            AnytypeText(name, style: .bodyRegular, color: .Text.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

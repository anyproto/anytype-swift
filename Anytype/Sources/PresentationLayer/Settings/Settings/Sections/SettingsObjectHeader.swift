import Foundation
import SwiftUI

struct SettingsObjectHeader: View {

    @Binding var name: String
    let nameTitle: String
    let iconImage: ObjectIconImage?
    let onTap: () -> Void
    
    var body: some View {
        Spacer.fixedHeight(16)
        VStack {
            if let iconImage {
                IconView(icon: iconImage)
            }
        }
        .frame(width: 96, height: 96)
        .fixTappableArea()
        .onTapGesture {
            onTap()
        }
        Spacer.fixedHeight(10)
        SettingsTextField(title: nameTitle, text: $name)
    }
}

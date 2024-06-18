
import SwiftUI

struct PickerSectionHeaderView: View {
    
    let title: String
    
    var body: some View {
        AnytypeText(title, style: .caption1Medium)
                .foregroundColor(.Text.secondary)
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, -3)
    }
}

struct PickerSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PickerSectionHeaderView(title: "a")
    }
}

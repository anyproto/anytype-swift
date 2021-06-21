
import SwiftUI

struct PickerSectionHeaderView: View {
    
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            AnytypeText(title, style: .captionMedium)
            .foregroundColor(Color.textSecondary)
            Spacer()
        }
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(Color.background)
    }
}

struct PickerSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PickerSectionHeaderView(title: "a")
    }
}

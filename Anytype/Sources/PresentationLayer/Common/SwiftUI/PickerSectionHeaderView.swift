
import SwiftUI

struct PickerSectionHeaderView: View {
    
    let title: String
    
    var body: some View {
        VStack(alignment: .center) {
            AnytypeText(title, style: .caption1Medium, color: .textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(Color.backgroundSecondary)
    }
}

struct PickerSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PickerSectionHeaderView(title: "a")
    }
}


import SwiftUI

struct PickerSectionHeaderView: View {
    
    let title: String
    
    var body: some View {
        AnytypeText(title, style: .caption1Medium, color: .TextNew.secondary)
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, -3)
        .background(Color.BackgroundNew.secondary)
    }
}

struct PickerSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PickerSectionHeaderView(title: "a")
    }
}

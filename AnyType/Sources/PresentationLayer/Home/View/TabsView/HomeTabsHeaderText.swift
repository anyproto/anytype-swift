import SwiftUI

struct HomeTabsHeaderText: View {
    let text: String
    var isSelected: Bool
    
    var body: some View {
        AnytypeText(text, style: .subheading)
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .textPrimary : .white)
            .blendMode(isSelected ? .normal : .softLight)
    }
}
struct HomeTabsHeaderText_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            HStack {
                HomeTabsHeaderText(text: "Selected", isSelected: true)
                HomeTabsHeaderText(text: "Not selected", isSelected: false)
            }
        }
    }
}

import SwiftUI

struct HomeTabsHeaderText: View {
    let text: String
    var isSelected: Bool
    
    var body: some View {
        AnytypeText(text, style: .subheading)
            .frame(alignment: .leading)
            .foregroundColor(isSelected ? .textPrimary : .white)
            .blendMode(isSelected ? .normal : .softLight)
            .lineLimit(1)
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

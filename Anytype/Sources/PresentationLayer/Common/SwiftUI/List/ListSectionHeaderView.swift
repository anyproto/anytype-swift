import SwiftUI

struct ListSectionHeaderView: View {
    let title: String
    
    var body: some View {
        SectionHeaderView(title: title)
            .divider(spacing: 0, alignment: .leading)
    }
}

struct ListSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ListSectionHeaderView(title: "title")
    }
}

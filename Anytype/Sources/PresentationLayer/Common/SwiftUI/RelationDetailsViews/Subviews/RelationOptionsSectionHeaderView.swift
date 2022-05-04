import SwiftUI

struct RelationOptionsSectionHeaderView: View {
    let title: String
    
    var body: some View {
        AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            .padding(.top, 26)
            .padding(.bottom, 8)
            .divider(spacing: 0, alignment: .leading)
            .padding(.horizontal, 20)
    }
}

struct RelationValueOptionSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        RelationOptionsSectionHeaderView(title: "title")
    }
}

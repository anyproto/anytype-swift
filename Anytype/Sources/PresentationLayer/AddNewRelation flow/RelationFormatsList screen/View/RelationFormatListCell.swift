import SwiftUI
import AnytypeCore
import BlocksModels

struct RelationFormatListCell: View {
    
    let model: Model

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(model.icon).frame(width: 24, height: 24)

            AnytypeText(model.title, style: .uxBodyRegular, color: .textPrimary)
                .lineLimit(1)
        }
        .frame(height: 52)
        .divider(alignment: .leading)
    }
}

extension RelationFormatListCell {
    
    struct Model: Identifiable, Hashable {
        let id: String
        
        let title: String
        let icon: String
    }
    
}

import SwiftUI

struct TagRelationRowView: View {

    let config: TagView.Config
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(config: config)
            Spacer()
        }
        .frame(height: 48)
    }
}

#Preview {
    TagRelationRowView(
        config: TagView.Config.default
    )
}

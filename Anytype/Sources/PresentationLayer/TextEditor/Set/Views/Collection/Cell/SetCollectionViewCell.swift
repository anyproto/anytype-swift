import SwiftUI
import Kingfisher

struct SetCollectionViewCell: View {
    let configuration: SetTableViewRowData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            title
        }
        .padding(16)
        .frame(height: 125)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.strokePrimary, lineWidth: 0.5)
        )
    }
    
    private var title: some View {
        AnytypeText(configuration.title, style: .previewTitle2Medium, color: .textPrimary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
}

import Foundation
import SwiftUI
import Services

struct MessageObjectBigBookmarkView: View {
    
    let icon: Icon?
    let source: URL?
    let title: String
    let description: String
    let pictureId: String
    let onTapObject: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    if let icon {
                        IconView(icon: icon)
                            .frame(width: 16, height: 16)
                    }
                    Text(source?.host() ?? "")
                        .anytypeStyle(.relation3Regular)
                        .lineLimit(1)
                        .foregroundStyle(Color.Text.secondary)
                }
                .frame(height: 16)
                Spacer.fixedHeight(4)
                Text(title)
                    .anytypeStyle(.previewTitle2Medium)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                Spacer.fixedHeight(2)
                Text(description)
                    .anytypeStyle(.relation3Regular)
                    .lineLimit(2)
                    .foregroundStyle(Color.Text.primary)
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            if pictureId.isNotEmpty {
                ImageIdIconView(imageId: pictureId)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
        }
        .frame(height: 104)
        .padding(.horizontal, 16)
        .background(Color.Background.primary)
        .cornerRadius(12, style: .continuous)
        .border(12, color: Color.Shape.transperentSecondary)
        .onTapGesture {
            onTapObject()
        }
    }
}

extension MessageObjectBigBookmarkView {
    init(details: ObjectDetails, onTapObject: @escaping (_ details: ObjectDetails) -> Void) {
        self.icon = details.objectIconImage
        self.source = details.source?.url
        self.title = details.name
        self.description = details.description
        self.pictureId = details.picture
        self.onTapObject = {
            onTapObject(details)
        }
    }
}

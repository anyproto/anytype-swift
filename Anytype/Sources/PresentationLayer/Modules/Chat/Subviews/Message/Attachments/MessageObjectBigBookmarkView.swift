import Foundation
import SwiftUI
import Services
import CachedAsyncImage

struct MessageObjectBigBookmarkView: View {
    
    let source: URL?
    let title: String
    let description: String
    let pictureId: String
    let onTapObject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if pictureId.isNotEmpty {
                ImageIdIconView(imageId: pictureId, square: false, side: .height)
                    .aspectRatio(CGSize(width: 1.91, height: 1), contentMode: .fit)
                    .cornerRadius(2)
            }
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    if let host = source?.host(), host.isNotEmpty {
                        Text(host)
                            .anytypeStyle(.relation3Regular)
                            .lineLimit(1)
                            .foregroundStyle(Color.Control.transparentActive)
                    }
                    
                    if title.isNotEmpty {
                        Text(title)
                            .anytypeStyle(.previewTitle2Medium)
                            .lineLimit(1)
                            .foregroundStyle(Color.Text.primary)
                    }
                    
                    if description.isNotEmpty {
                        Text(description)
                            .anytypeStyle(.relation3Regular)
                            .lineLimit(2)
                            .foregroundStyle(Color.Control.transparentActive)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.Shape.transperentSecondary)
        .cornerRadius(12, style: .continuous)
        .onTapGesture {
            onTapObject()
        }
    }
}

extension MessageObjectBigBookmarkView {
    init(details: ObjectDetails, onTapObject: @escaping (_ details: ObjectDetails) -> Void) {
        self.source = details.source?.url
        self.title = details.name
        self.description = details.description
        self.pictureId = details.picture
        self.onTapObject = {
            onTapObject(details)
        }
    }
}

import SwiftUI

struct FileStorageInfoBlock: View {
    
    let iconImage: ObjectIconImage?
    let title: String
    let description: String
    let isWarning: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            SwiftUIObjectIconImageViewWithPlaceholder(icon: iconImage)
            .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 1) {
                AnytypeText(title, style: .previewTitle2Medium, color: .Text.primary)
                AnytypeText(description, style: .relation3Regular, color: isWarning ? .System.red : .Text.secondary)
            }
            .lineLimit(1)
        }
        .frame(height: 72)
    }
}

struct FileStorageInfoBlock_Previews: PreviewProvider {
    static var previews: some View {
        FileStorageInfoBlock(
            iconImage: .icon(.space(.gradient(.random))),
            title: "Anton’s space",
            description: "212 MB of 1 GB used",
            isWarning: false
        )
    }
}

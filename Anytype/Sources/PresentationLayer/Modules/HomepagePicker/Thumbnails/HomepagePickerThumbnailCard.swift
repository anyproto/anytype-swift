import SwiftUI
import DesignKit

struct HomepagePickerThumbnailCard: View {
    let option: HomepagePickerOption
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 7) {
            Image(asset: option.thumbnailAsset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 88, height: 176)

            AnytypeText(option.title, style: .caption1Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            AnytypeCircleCheckbox(checked: isSelected, size: 20)
        }
        .frame(width: 88)
        .contentShape(Rectangle())
    }
}

private extension HomepagePickerOption {
    var thumbnailAsset: ImageAsset {
        switch self {
        case .object(let type):
            switch type {
            case .chat: return .HomepagePicker.chatThumbnail
            case .page: return .HomepagePicker.pageThumbnail
            case .collection: return .HomepagePicker.collectionThumbnail
            }
        }
    }
}

#Preview("Thumbnails") {
    HStack(spacing: 24) {
        ForEach(HomepagePickerOption.allCases) { option in
            VStack(spacing: 16) {
                HomepagePickerThumbnailCard(option: option, isSelected: true)
                HomepagePickerThumbnailCard(option: option, isSelected: false)
            }
        }
    }
    .padding()
}

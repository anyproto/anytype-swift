import SwiftUI
import DesignKit

struct HomepagePickerThumbnailCard: View {
    let option: HomepagePickerOption
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 7) {
            thumbnailContent
                .frame(height: 176)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.Control.tertiary, lineWidth: 1)
                )

            AnytypeText(option.title, style: .caption1Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            AnytypeCircleCheckbox(checked: isSelected)
                .frame(width: 20, height: 20)
        }
        .frame(width: 88)
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        switch option {
        case .widgets:
            WidgetsThumbnail()
        case .object(let type):
            switch type {
            case .chat:
                ChatThumbnail()
            case .page:
                PageThumbnail()
            case .collection:
                CollectionThumbnail()
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

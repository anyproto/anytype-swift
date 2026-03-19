import SwiftUI

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
                        .strokeBorder(
                            isSelected ? Color.Control.accent50 : Color.Control.tertiary,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )

            AnytypeText(option.title, style: .caption1Medium)
                .foregroundStyle(isSelected ? Color.Control.accent100 : Color.Control.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: 88)
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        switch option {
        case .chat:
            ChatThumbnail(isSelected: isSelected)
        case .widgets:
            WidgetsThumbnail(isSelected: isSelected)
        case .page:
            PageThumbnail(isSelected: isSelected)
        case .collection:
            CollectionThumbnail(isSelected: isSelected)
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

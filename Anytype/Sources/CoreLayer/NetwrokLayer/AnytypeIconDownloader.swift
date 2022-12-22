import UIKit

final class AnytypeIconDownloader {
    func image(
        with style: BlockLinkState.Style,
        imageGuideline: ImageGuideline
    ) async -> UIImage? {
        switch style {
        case .noContent:
            return nil
        case .icon(let objectIconType):
            return await image(with: objectIconType, imageGuideline: imageGuideline)
        case .checkmark(let isChecked):
            return UIImage(asset: isChecked ? .taskChecked : .taskUnchecked)?
                .imageResized(to: imageGuideline.size)
        }
    }

    func image(
        with objectIconType: ObjectIconType,
        imageGuideline: ImageGuideline
    ) async -> UIImage? {
        switch objectIconType {
        case let .basic(id), let .bookmark(id):
            let metadata = ImageMetadata(id: id, width: imageGuideline.size.width)

            return await image(with: metadata, imageGuideline: imageGuideline)
        case .profile(let profile):
            return await image(with: profile, imageGuideline: imageGuideline)
        case .emoji(let emoji):
            return ObjectIconImagePainter.shared.image(
                with: emoji.value,
                font: .systemFont(ofSize: imageGuideline.size.height/1.2),
                textColor: .Text.primary,
                imageGuideline: imageGuideline,
                backgroundColor: .clear
            )
        }
    }

    private func image(with profileIcon: ObjectIconType.Profile, imageGuideline: ImageGuideline) async -> UIImage? {
        switch profileIcon {
        case let .imageId(id):
            let metadata = ImageMetadata(id: id, width: imageGuideline.size.width)

            let image = await image(with: metadata, imageGuideline: imageGuideline)

            let centredSquareImage = image?.centeredSquareImage()?
                .imageResized(to: imageGuideline.size)

            return centredSquareImage?.rounded(radius: imageGuideline.size.width / 2)
        case let .character(placeholder):
            let imageGuideline = ImageGuideline(size: imageGuideline.size, radius: .widthFraction(0.5))

            return ImageBuilder(imageGuideline)
                .setImageColor(.Stroke.primary)
                .setText(String(placeholder))
                .setFont(UIFont.systemFont(ofSize: 17))
                .build()
        }
    }

    private func image(with metadata: ImageMetadata, imageGuideline: ImageGuideline) async -> UIImage? {
        guard let url = metadata.contentUrl  else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            AnytypeImageDownloader.retrieveImage(with: url) { image in
                let transformedImage = image?
                    .centeredSquareImage()?
                    .imageResized(to: imageGuideline.size)
                    .rounded(radius: imageGuideline.size.width / 2)
                
                continuation.resume(returning: transformedImage)
            }
        }
    }
}

//
//  ImageViewerViewModel.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 08.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class ImageViewerViewModel: ObservableObject {
    struct ImageDescriptor: Identifiable, Hashable {
        let id: String
        let image: UIImage
    }

    var activityItems: [UIImage] {
        [images.first?.image].compactMap { $0 }
    }

    @Published var selectedImageId: String
    @Published var images: [ImageDescriptor]

    convenience init(image: UIImage) {
        self.init(images: [image])
    }

    convenience init?(imageSource: ImageSource) {
        guard let image = imageSource.uiImage else { return nil }
        self.init(image: image)
    }

    // Still unavailable. Will find a solution ASAP for several images.
    private init(images: [UIImage], selectedImageIndex: Int = 0) {
        self.images = images.enumerated().map {
            ImageDescriptor(id: String($0.offset), image: $0.element)
        }
        self.selectedImageId = String(selectedImageIndex)
    }
}

private extension ImageSource {
    var uiImage: UIImage? {
        switch self {
        case .image(let image):
            return image
        case .middleware(let fileId):
            guard let url = fileId.resolvedUrl,
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return nil }

            return image
        }
    }
}


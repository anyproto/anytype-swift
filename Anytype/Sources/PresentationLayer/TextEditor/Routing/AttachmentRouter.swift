//
//  AttachmentRouter.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 06.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import AnytypeCore
import SwiftUI

protocol AttachmentRouterProtocol {
    func openImage(_ imageSource: ImageSource)
}

final class AttachmentRouter: NSObject, AttachmentRouterProtocol {
    private let rootViewController: UIViewController

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func openImage(_ imageSource: ImageSource) {
        guard let image = image(from: imageSource) else { return }

        let viewModel = ImageViewerViewModel(image: image)
        let view = ImageViewerView(viewModel: viewModel) { [unowned rootViewController] in
            rootViewController.dismiss(animated: true, completion: nil)
        }

        let hostingViewController = UIHostingController(rootView: view)
        hostingViewController.view.backgroundColor = .clear
        hostingViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(hostingViewController, animated: true, completion: nil)
    }

    private func image(from imageSource: ImageSource) -> UIImage? {
        switch imageSource {
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

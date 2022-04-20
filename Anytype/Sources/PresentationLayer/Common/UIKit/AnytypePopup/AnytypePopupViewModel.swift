//
//  AnytypePopupViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 30.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI

final class AnytypePopupViewModel<Content: View>: AnytypePopupViewModelProtocol, ObservableObject {
    private(set) var popupLayout: AnytypePopupLayoutType
    private weak var popup: AnytypePopupProxy?
    private let contentView: Content

    init(contentView: Content, popupLayout: AnytypePopupLayoutType = .constantHeight(height: 0, floatingPanelStyle: true)) {
        self.contentView = contentView
        self.popupLayout = popupLayout
    }

    func viewDidUpdateHeight(_ height: CGFloat) {
        if case .constantHeight = popupLayout {
            popupLayout = .constantHeight(height: height, floatingPanelStyle: false)
        }
        popup?.updateLayout(false)
    }

    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }

    func makeContentView() -> UIViewController {
        UIHostingController(rootView: InnerAnytypePopupView(viewModel: self, contentView: contentView))
    }
}

private extension AnytypePopupViewModel {
    
    struct InnerAnytypePopupView: View {
        
        @ObservedObject var viewModel: AnytypePopupViewModel
        let contentView: Content
        @State private var currentHeight: CGFloat = .zero

        var body: some View {
            contentView
                .highPriorityGesture(
                    DragGesture()
                )
                .readSize { size in
                    guard currentHeight != size.height else { return }
                    currentHeight = size.height
                    viewModel.viewDidUpdateHeight(currentHeight)
                }
        }
    }
    
}

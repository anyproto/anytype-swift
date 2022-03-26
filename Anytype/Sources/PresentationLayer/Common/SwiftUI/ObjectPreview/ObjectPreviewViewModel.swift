//
//  ObjectPreviewViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewViewModel: ObservableObject {
    // MARK: - Private variables

    private(set) var popupLayout: AnytypePopupLayoutType = .constantHeight(height: 0, floatingPanelStyle: true)
    private weak var popup: AnytypePopupProxy?

    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    @Published var objectPreviewSections = ObjectPreviewViewSection(main: [], featuredRelation: [])

    // MARK: - Initializer

    init(featuredRelationsByIds: [String: Relation],
         fields: MiddleBlockFields) {
        updateObjectPreview(featuredRelationsByIds: featuredRelationsByIds, fields: fields)
    }

    func viewDidUpdateHeight(_ height: CGFloat) {
        popupLayout = .constantHeight(height: height, floatingPanelStyle: false)
        popup?.updateLayout(false)
    }

    func updateObjectPreview(featuredRelationsByIds: [String: Relation], fields: MiddleBlockFields) {
        objectPreviewSections = objectPreviewModelBuilder.build(featuredRelationsByIds: featuredRelationsByIds,
                                                                fields: fields)
    }
}

extension ObjectPreviewViewModel: AnytypePopupViewModelProtocol {

    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }

    func makeContentView() -> UIViewController {
        UIHostingController(rootView: ObjectPreviewView(viewModel: self))
    }
}

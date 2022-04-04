//
//  PopupViewBuilder.swift
//  Anytype
//
//  Created by Denis Batvinkin on 01.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

final class PopupViewBuilder {

    static func createCheckPopup<ViewModel: CheckPopuViewViewModelProtocol>(viewModel: ViewModel) -> AnytypePopup {
        let view = CheckPopupView(viewModel: viewModel)
        return AnytypePopup(contentView: view)
    }
}


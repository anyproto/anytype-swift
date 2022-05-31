//
//  SimpleTable.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

struct SimpleTableBlockViewModel {
    let textBlocks: [TextBlockViewModel]
}

struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    let blockViewModels: [TextBlockContentConfiguration]

    @EquatableNoop var heightDidChanged: () -> Void
}


final class SimpleTableBlockView: UIView, BlockContentView {
    private lazy var dynamicLayoutView = DynamicCompositionalLayoutView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        var views = [UIView]()

        configuration.blockViewModels.forEach { item in



        }

        dynamicLayoutView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                compositionalLayout: .spreadsheet(groupItemsCount: <#T##Int#>, itemsWidths: <#T##[CGFloat]#>, interItemSpacing: <#T##NSCollectionLayoutSpacing#>, groundEdgeSpacing: <#T##NSCollectionLayoutEdgeSpacing#>, interGroupSpacing: <#T##CGFloat#>),
                views: views,
                heightDidChanged: configuration.heightDidChanged
            )
        )
    }

    private func setupSubview() {
        addSubview(dynamicLayoutView) {
            $0.pinToSuperview(
                insets: .init(top: 10, left: 0, bottom: 10, right: 0)
            )
        }
    }
}

//
//  SimpleTable.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit
import BlocksModels
import Combine

struct SimpleTableBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    var hashable: AnyHashable {
        textBlocks
            .map { $0.hashable } as [AnyHashable]
    }

    private let textBlocks: [TextBlockViewModel]
    private let blockDelegate: BlockDelegate
    private let cancellables: [AnyCancellable]

    init(
        info: BlockInformation,
        textBlocks: [TextBlockViewModel],
        blockDelegate: BlockDelegate
    ) {
        self.info = info
        self.textBlocks = textBlocks
        self.blockDelegate = blockDelegate

        self.cancellables = textBlocks.map {
            $0.setNeedsLayoutSubject.sink { _ in
                blockDelegate.textBlockSetNeedsLayout()
            }
        }
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let contentConfigurations = textBlocks.map {
            $0.textBlockContentConfiguration()
        }

        return SimpleTableBlockContentConfiguration(
            contentConfigurations: contentConfigurations,
            heightDidChanged: blockDelegate.textBlockSetNeedsLayout
        ).cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }



    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}

struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView


    let contentConfigurations: [TextBlockContentConfiguration]

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

        configuration.contentConfigurations.forEach { item in

            let view = TextBlockContentConfiguration.View(frame: .zero)
            view.update(with: item)

            views.append(view)
        }

        let layout = UICollectionViewCompositionalLayout.spreadsheet(
            itemsWidths: [100, 300, 40]
        )
        self.backgroundColor = .green

        dynamicLayoutView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                compositionalLayout: layout,
                views: views,
                heightDidChanged: configuration.heightDidChanged
            )
        )
    }

    private func setupSubview() {
        addSubview(dynamicLayoutView) {
            $0.pinToSuperview(
                insets: .init(top: 10, left: 0, bottom: -10, right: 0)
            )
        }
    }
}

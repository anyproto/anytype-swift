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
        [
            info.id
        ] as [AnyHashable]
    }

    private let textBlocks: [TextBlockViewModel]
    private let blockDelegate: BlockDelegate
    private var cancellables: [AnyCancellable]
    private let resetSubject: PassthroughSubject<Void, Never>

    init(
        info: BlockInformation,
        textBlocks: [TextBlockViewModel],
        blockDelegate: BlockDelegate
    ) {
        self.info = info
        self.textBlocks = textBlocks
        self.blockDelegate = blockDelegate
        self.cancellables = [AnyCancellable]()

        let resetSubject = PassthroughSubject<Void, Never>()
        self.resetSubject = resetSubject

        self.cancellables = textBlocks.map { textBlockViewModel -> AnyCancellable in
            textBlockViewModel.setNeedsLayoutSubject.eraseToAnyPublisher().sink { _ in
                print("+-+ textBlockSetNeedsLayout")
                resetSubject.send(())
//                blockDelegate.textBlockSetNeedsLayout()
            }
        }
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let contentConfigurations = textBlocks.map {
            $0.textBlockContentConfiguration()
        }


        return SimpleTableBlockContentConfiguration(
            contentConfigurations: contentConfigurations.chunked(into: 3),
            resetPublisher: resetSubject.eraseToAnyPublisher(),
            heightDidChanged: blockDelegate.textBlockSetNeedsLayout
        ).cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }



    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}

struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView


    let contentConfigurations: [[TextBlockContentConfiguration]]
    @EquatableNoop private(set) var resetPublisher: AnyPublisher<Void, Never>

    @EquatableNoop var heightDidChanged: () -> Void
}


final class SimpleTableBlockView: UIView, BlockContentView {
    private lazy var dynamicLayoutView = DynamicCompositionalLayoutView(frame: .zero)
    private var resetSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        var views = [[UIView]]()


        for section in configuration.contentConfigurations {
            var sectionViews = [UIView]()

            for item in section {
                let view = TextBlockContentConfiguration.View(frame: .zero)
                view.update(with: item)

                sectionViews.append(view)
            }

            views.append(sectionViews)
        }


        let layout = UICollectionViewCompositionalLayout.spreadsheet(
            itemsWidths: [100, 300, 40],
            views: views
        )

//        self.backgroundColor = .green

        resetSubscription = configuration.resetPublisher.sink { [weak self] _ in
            self?.dynamicLayoutView.collectionView.collectionViewLayout.invalidateLayout()
            self?.dynamicLayoutView.collectionView.collectionViewLayout.prepare()
        }

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
                insets: .init(top: 10, left: 20, bottom: -10, right: -20)
            )
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

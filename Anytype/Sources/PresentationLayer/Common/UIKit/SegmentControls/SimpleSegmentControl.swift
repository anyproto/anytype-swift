//
//  SimpleSegmentControl.swift
//  AnyType
//
//  Created by Denis Batvinkin on 28.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

#warning("Not used. Do we need it?")
final class SimpleSegmentControl<ItemIndex: RawRepresentable>: UIControl where ItemIndex.RawValue == Int {
    private(set) var selectedItemIndex: ItemIndex

    private var buttonsContainer: UIStackView = {
        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .horizontal
        buttonsContainer.distribution = .fillProportionally
        return buttonsContainer
    }()

    init(currentSelectedIndex: ItemIndex) {
        self.selectedItemIndex = currentSelectedIndex
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSegment(title: String) {
        let segmentIndex = buttonsContainer.arrangedSubviews.count

        let itemView = SegmentItemView(title: title)
        itemView.layer.cornerRadius = 14
        itemView.layer.cornerCurve = .continuous

        itemView.setActionHandler { [weak self] in
            guard let self = self else { return }
            guard let itemIndex = ItemIndex(rawValue: segmentIndex) else { return }

            self.setSelectedItem(for: itemIndex)
            self.sendActions(for: .valueChanged)
        }

        buttonsContainer.addArrangedSubview(itemView)

        if segmentIndex == 0, let itemIndex = ItemIndex(rawValue: segmentIndex) {
            setSelectedItem(for: itemIndex)
        }
    }

    override var intrinsicContentSize: CGSize {
        return buttonsContainer.intrinsicContentSize
    }

    private func setupViews() {
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonsContainer)
        buttonsContainer.edgesToSuperview()
    }

    private func setSelectedItem(for index: ItemIndex) {
        guard buttonsContainer.arrangedSubviews.indices.contains(index.rawValue) else { return }

        let newSelectedItem = self.buttonsContainer.arrangedSubviews[index.rawValue]
        let selectedItemIntIndex = selectedItemIndex.rawValue

        if buttonsContainer.arrangedSubviews.indices.contains(selectedItemIntIndex) {
            let currentItemView = self.buttonsContainer.arrangedSubviews[selectedItemIntIndex]
            currentItemView.backgroundColor = .clear
        }
        selectedItemIndex = index
        newSelectedItem.backgroundColor = UIColor.grayscale10
    }
}

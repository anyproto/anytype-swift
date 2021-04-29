//
//  SimpleSegmentControl.swift
//  AnyType
//
//  Created by Denis Batvinkin on 28.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class SimpleSegmentControl: UIControl {

    private(set) var selectedItemIndex: Int = 0

    private var buttonsContainer: UIStackView = {
        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .horizontal
        buttonsContainer.distribution = .fillProportionally
        return buttonsContainer
    }()

    init() {
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

            self.setSelectedItem(for: segmentIndex)
            self.sendActions(for: .valueChanged)
        }

        buttonsContainer.addArrangedSubview(itemView)

        if segmentIndex == 0 {
            setSelectedItem(for: 0)
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

    private func setSelectedItem(for index: Int) {
        guard buttonsContainer.arrangedSubviews.indices.contains(index) else {
            return
        }
        let newSelectedItem = self.buttonsContainer.arrangedSubviews[index]

        if buttonsContainer.arrangedSubviews.indices.contains(selectedItemIndex) {
            let currentItemView = self.buttonsContainer.arrangedSubviews[selectedItemIndex]
            currentItemView.backgroundColor = .clear
        }
        selectedItemIndex = index
        newSelectedItem.backgroundColor = UIColor.grayscale10
    }
}

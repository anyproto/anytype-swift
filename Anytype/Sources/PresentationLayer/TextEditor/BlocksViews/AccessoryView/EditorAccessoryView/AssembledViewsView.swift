//
//  AssembledViewsView.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 22.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class AssembledViewsView<A: UIView, B: UIView>: UIView {
    let a: A
    let b: B

    private let stackView = UIStackView()

    init(a: A, b: B) {
        self.a = a
        self.b = b

        super.init(frame: .zero)
        setupSubviews()
    }

    override init(frame: CGRect) {
        fatalError()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    private func setupSubviews() {
        autoresizingMask = .flexibleHeight
        addSubview(stackView) {
            $0.pinToSuperview()
        }
        stackView.axis = .vertical
        stackView.spacing = 0

        stackView.addArrangedSubview(a)
        stackView.addArrangedSubview(b)

        print("a: \(a) \n b: \(b) \n\n\n")
        frame = .init(
            origin: .zero,
            size: .init(
                width: .zero,
                height: a.frame.height + b.frame.height
            )
        )
    }
}

//
//  MarkupAccessoryView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 02.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import SwiftUI

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5172%3A1931
class MarkupAccessoryView: UIView {

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: bounds.width, height: 48)
    }

    // MARK: - Setup view

    private func setupView() {
        autoresizingMask = .flexibleHeight
        
        addSubview(MarkupAccessoryContentView().asUIView()) {
            $0.pinToSuperview()
        }
    }
}

struct MarkupAccessoryContentView: View {

    var body: some View {
        HStack {
            
        }
    }
}

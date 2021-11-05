//
//  MarkupAccessoryView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 02.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5172%3A1931
final class MarkupAccessoryView: UIView {
    private let markupModeViewModel: MarkupAccessoryViewModel

    // MARK: - Lifecycle

    init(viewModel: MarkupAccessoryViewModel) {
        self.markupModeViewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundPrimary
        let contentView = MarkupAccessoryContentView(viewModel: self.markupModeViewModel).asUIView()
        
        addSubview(contentView) {
            $0.pinToSuperview()
        }
    }

    // MARK: - Public methos

    func selectionChanged(range: NSRange) {
        markupModeViewModel.range = range
    }

    func update(block: BlockModelProtocol, textView: UITextView) {
        markupModeViewModel.selectBlock(block)
        markupModeViewModel.range = textView.selectedRange
    }

    // MARK: - Unavailable

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}

struct MarkupAccessoryContentView: View {
    @StateObject var viewModel: MarkupAccessoryViewModel

    var body: some View {
        HStack {
            ForEach(viewModel.markupOptions, id: \.self) { item in
                Button {
                    viewModel.action(item)
                } label: {
                    item.icon
                        .renderingMode(.template)
                        .foregroundColor(.textPrimary)
                        .frame(width: 48, height: 48)

                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

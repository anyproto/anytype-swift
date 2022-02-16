//
//  MarkupAccessoryView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 02.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels
import Combine


/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5172%3A1931
final class MarkupAccessoryView: UIView {
    private var cancellables = [AnyCancellable]()
    
    private let viewModel: MarkupAccessoryViewModel
    private var colorView: ColorView!

    // MARK: - Lifecycle

    init(viewModel: MarkupAccessoryViewModel) {
        self.viewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        self.colorView = createColorView()
        setupViews()
        bindViewModel()
    }

    private func createColorView() -> ColorView {
        let color = viewModel.currentText?.colorState(range: viewModel.range) ?? UIColor.Text.default
        let backgroundColor = viewModel.currentText?.backgroundColor(range: viewModel.range) ?? UIColor.Background.default

        let colorView = ColorView(color: color,
                                  backgroundColor: backgroundColor) { [weak self] item in
            self?.viewModel.handleSelectedColorItem(item)
        } viewDidClose: { [weak self] in
            self?.viewModel.showColorView = false
        }

        return colorView
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundPrimary
        let contentView = MarkupAccessoryContentView(viewModel: self.viewModel).asUIView()
        
        addSubview(contentView) {
            $0.pinToSuperviewPreservingReadability()
        }
    }


    private func bindViewModel() {
        viewModel.$showColorView.sink { [weak self] shouldShowColorView in
            guard let self = self else {  return }

            if shouldShowColorView {
                let view = UIApplication.shared.windows[UIApplication.shared.windows.count - 1]
                let topAnchorConstant = self.viewModel.colorButtonFrame?.maxY ?? 0

                view.addSubview(self.colorView) {
                    $0.pinToSuperview()
                }
                view.addSubview(self.colorView.containerView) {
                    $0.width.equal(to: 260)
                    $0.height.equal(to: 176)
                    $0.trailing.equal(to: view.trailingAnchor, constant: -10)
                    $0.top.equal(to: view.topAnchor, constant: topAnchorConstant + 8)
                }

                let color = self.viewModel.currentText?.colorState(range: self.viewModel.range) ?? UIColor.Text.default
                let backgroundColor = self.viewModel.currentText?.backgroundColor(range: self.viewModel.range) ?? UIColor.Background.default

                self.colorView.selectedTextColor = color
                self.colorView.selectedBackgroundColor = backgroundColor
            } else {
                self.colorView.removeFromSuperview()
                self.colorView.containerView.removeFromSuperview()
            }

            UISelectionFeedbackGenerator().selectionChanged()
        }.store(in: &cancellables)
    }

    // MARK: - Public methos

    func selectionChanged(range: NSRange) {
        viewModel.updateRange(range: range)
    }

    func update(block: BlockModelProtocol, textView: UITextView) {
        viewModel.selectBlock(block, text: textView.attributedText, range: textView.selectedRange)
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
            ForEach(viewModel.markupItems, id:\.id) { item in
                Button {
                    viewModel.action(item.markupItem)
                } label: {
                    Group {
                        if case .color = item.markupItem {
                            item.markupItem.icon
                                .background(GeometryReader { gp -> Color in
                                    viewModel.colorButtonFrame = gp.frame(in: .global) // in window
                                    return Color.clear
                                })
                        } else {
                            item.markupItem.icon
                                .renderingMode(.template)
                                .foregroundColor(viewModel.iconColor(for: item.markupItem))
                        }
                    }
                    .frame(width: 48, height: 48)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

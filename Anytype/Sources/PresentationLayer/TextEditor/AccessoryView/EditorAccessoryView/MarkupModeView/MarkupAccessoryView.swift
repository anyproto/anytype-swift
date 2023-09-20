//
//  MarkupAccessoryView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 02.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Services
import Combine
import AnytypeCore

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5172%3A1931
final class MarkupAccessoryView: UIView {
    private var cancellables = [AnyCancellable]()
    
    private weak var viewModel: MarkupAccessoryViewModel?
    private var colorView: ColorView!

    // MARK: - Lifecycle

    init(viewModel: MarkupAccessoryViewModel) {
        self.viewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        self.colorView = createColorView(viewModel: viewModel)
        setupViews(viewModel: viewModel)
        bindViewModel(viewModel: viewModel)
        updateColorViewStyle()
    }

    private func createColorView(viewModel: MarkupAccessoryViewModel) -> ColorView {
        let colorView = ColorView() { [weak viewModel] item in
            viewModel?.handleSelectedColorItem(item)
        } viewDidClose: { [weak viewModel] in
            viewModel?.showColorView = false
        }

        return colorView
    }

    private func setupViews(viewModel: MarkupAccessoryViewModel) {
        autoresizingMask = .flexibleHeight
        backgroundColor = .Background.primary
        let contentView = MarkupAccessoryContentView(viewModel: viewModel).asUIView()

        addSubview(contentView) {
            if FeatureFlags.ipadIncreaseWidth {
                $0.pinToSuperview()
            } else {
                $0.pinToSuperviewPreservingReadability()
            }

        }
    }

    private func bindViewModel(viewModel: MarkupAccessoryViewModel) {
        viewModel.$showColorView.sink { [weak self] shouldShowColorView in
            guard let self = self else {  return }

            if shouldShowColorView {
                guard let viewModel = self.viewModel,
                      let view = UIApplication.shared.keyWindow else { return }
                let topAnchorConstant = viewModel.colorButtonFrame?.minY ?? 0

                view.addSubview(self.colorView) {
                    $0.pinToSuperview()
                }
                view.addSubview(self.colorView.containerView) {
                    $0.width.equal(to: 260)
                    $0.height.equal(to: 176)
                    $0.trailing.equal(to: view.trailingAnchor, constant: -10)
                    $0.bottom.equal(to: view.topAnchor, constant: topAnchorConstant - 8)
                }

                let color = viewModel.foregroundColorState()
                let backgroundColor = viewModel.backgroundColorState()

                self.colorView.selectedTextColor = color
                self.colorView.selectedBackgroundColor = backgroundColor
            } else {
                self.colorView.removeFromSuperview()
                self.colorView.containerView.removeFromSuperview()
            }
        }.store(in: &cancellables)
    }

    // MARK: - Public methos
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorViewStyle()
    }

    // MARK: - Unavailable

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
    
    // MARK: - Private
    
    private func updateColorViewStyle() {
        // Presented window - is not application window. This is the system window.
        // We should to set custom UserInterfaceStyle for sync with application.
        colorView.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
        colorView.containerView.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
    }
}

struct MarkupAccessoryContentView: View {
    @StateObject var viewModel: MarkupAccessoryViewModel

    var body: some View {
        HStack {
            ForEach(viewModel.markupItems, id:\.id) { item in
                Button { [weak viewModel] in
                    viewModel?.action(item.markupItem)
                } label: {
                    Group {
                        if case .color = item.markupItem {
                            Image(asset: item.markupItem.iconAsset)
                                .background(GeometryReader { [weak viewModel] gp -> Color in
                                    viewModel?.colorButtonFrame = gp.frame(in: .global) // in window
                                    return Color.clear
                                })
                        } else {
                            Image(asset: item.markupItem.iconAsset)
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

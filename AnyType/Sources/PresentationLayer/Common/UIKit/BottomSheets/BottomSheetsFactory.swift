//
//  BottomSheetsFactory.swift
//  Anytype
//
//  Created by Denis Batvinkin on 20.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import FloatingPanel
import BlocksModels
import UIKit


final class BottomSheetsFactory {
    typealias ActionHandler = (_ action: BlockActionHandler.ActionType) -> Void

    static func createStyleBottomSheet(parentViewController: UIViewController,
                                       delegate: FloatingPanelControllerDelegate,
                                       blockModel: BlockModelProtocol,
                                       actionHandler: @escaping ActionHandler) {
        let fpc = FloatingPanelController()
        fpc.delegate = delegate
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        fpc.surfaceView.layer.cornerCurve = .continuous

        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: parentViewController.view.safeAreaInsets.bottom + 6, right: 10.0)
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .grayscale30
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.layout = StylePanelLayout()
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        // NOTE: This will be moved to coordinator in next pr
        guard case let .text(textContentType) = blockModel.information.content.type else { return }
        let askAttributes: () -> TextAttributesViewController.AttributesState = {
            guard case let .text(textContent) = blockModel.information.content else {
                return .init(hasBold: false, hasItalic: false, hasStrikethrough: false, hasCodeStyle: false)
            }

            let range = NSRange(location: 0, length: textContent.attributedText.length)

            let hasBold = textContent.attributedText.hasTrait(trait: .traitBold, at: range)
            let hasItalic = textContent.attributedText.hasTrait(trait: .traitItalic, at: range)
            let hasStrikethrough = textContent.attributedText.hasAttribute(.strikethroughStyle, at: range)
            let alignment = BlocksModelsParserCommonAlignmentUIKitConverter.asUIKitModel(blockModel.information.alignment) ?? .left

            let attributes = TextAttributesViewController.AttributesState(
                hasBold: hasBold, hasItalic: hasItalic, hasStrikethrough: hasStrikethrough, hasCodeStyle: false, alignment: alignment, url: ""
            )
            return attributes
        }

        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        let askColor: () -> UIColor? = {
            guard case let .text(textContent) = blockModel.information.content else { return nil }
            return ColorConverter.asModel(textContent.color, background: false)
        }
        let askBackgroundColor: () -> UIColor? = {
            return ColorConverter.asModel(blockModel.information.backgroundColor, background: true)
        }

        let contentVC = StyleViewController(
            viewControllerForPresenting: parentViewController,
            style: textContentType,
            askColor: askColor,
            askBackgroundColor: askBackgroundColor,
            askTextAttributes: askAttributes
        ) { action in
            actionHandler(action)
        }
        
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: parentViewController, animated: true)
    }
}

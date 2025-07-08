//
//  SelectionDecorationView.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 11.07.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit
import Combine

class SelectionDecorationView: UICollectionReusableView, ReusableContent {
    private var cancellables = [AnyCancellable]()

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }

    override var reuseIdentifier: String? {
        SelectionDecorationView.reusableIdentifier
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let attributes = layoutAttributes as? SelectionDecorationAttributes else {
            return
        }

        attributes.$selectedRects.sink { [weak self] rects in
            UIView.performWithoutAnimation {
                self?.redraw(selectedFrames: rects)
            }
        }.store(in: &cancellables)
    }

    private func redraw(selectedFrames: [[CGRect]]) {
        removeAllSubviews()

        let drawingView = DrawingView(rects: selectedFrames)

        addSubview(drawingView) {
            $0.pinToSuperview()
        }

        layoutIfNeeded()
    }
}

final class SelectionDecorationAttributes: UICollectionViewLayoutAttributes {
    @Published var selectedRects = [[CGRect]]()
}

final class DrawingView: UIView {
    private let rects: [[CGRect]]

    init(rects: [[CGRect]]) {
        self.rects = rects

        super.init(frame: .zero)

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {

        for arrayOfRects in rects {
            let mainPath = UIBezierPath()

            for rect in arrayOfRects {
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 2)

                mainPath.append(path)
            }

            let gourdInverse = UIBezierPath(cgPath: mainPath.cgPath)

            guard let c = UIGraphicsGetCurrentContext() else {
                fatalError("current context not found.")
            }

            c.beginTransparencyLayer(auxiliaryInfo: nil)

            c.addPath(gourdInverse.cgPath)
            c.setLineWidth(3)
            c.setStrokeColor(UIColor.Control.accent100.cgColor)
            c.strokePath()

            c.beginPath()
            c.addPath(mainPath.cgPath)
            c.clip()

            c.beginPath()
            c.addPath(gourdInverse.cgPath)
            c.setBlendMode(CGBlendMode.clear)
            c.setFillColor(UIColor.clear.cgColor)
            c.fillPath()

            c.endTransparencyLayer()
        }
    }
}

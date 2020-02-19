//
//  EmptyCell.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension DocumentViewCells {
    class Cell: UITableViewCell {
        struct Options {
            var useUIKit: Bool = true
            var shouldShowIndent: Bool = false
        }
        typealias Model = DocumentView.ViewModel.Row
        
        struct Layout {
            var containedViewInset = 8
            var indentationWidth = 8
            var boundaryWidth = 2
        }
        
        var model: Model?
        var containedView: UIView?
        var containerView: UIView?
        var boundaryView: UIView?
        var elementsView: UIView? // top-most view
        var boundaryRevealConstraint: NSLayoutConstraint?
        var indentationConstraint: NSLayoutConstraint?
        var options: Options = .init()
        var layout: Layout = .init()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: - Setup
        func setup() {
            self.translatesAutoresizingMaskIntoConstraints = false
            let containerView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            let boundaryView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .gray
                return view
            }()
            
            let elementsView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
                        
            elementsView.addSubview(containerView)
            elementsView.addSubview(boundaryView)
            
            self.contentView.addSubview(elementsView)
            
            self.containerView = containerView
            self.boundaryView = boundaryView
            self.elementsView = elementsView
            
            self.addLayout()
        }
        
        func addLayout() {
            
            if let view = self.elementsView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
                self.indentationConstraint = view.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
                self.indentationConstraint?.isActive = true
            }
            
            if let view = self.boundaryView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                ])
                self.boundaryRevealConstraint = view.widthAnchor.constraint(equalToConstant: 0)
                self.boundaryRevealConstraint?.isActive = true
            }
            
            if let view = self.containerView, let superview = view.superview, let leftView = self.boundaryView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
    }
}

// MARK: Configured
extension DocumentViewCells.Cell {
    class ViewBuilder {
        
        class func createView(_ model: BlockViewBuilderProtocol?, useUIKit: Bool) -> UIView? {
            guard let model = model else { return nil }
            
            if useUIKit {
                let view = model.buildUIView()
                
                let superview = UIView()
                superview.translatesAutoresizingMaskIntoConstraints = false
                superview.addSubview(view)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
                
                return superview
            }
            let controller = UIHostingController(rootView: model.buildView())
            let view = controller.view
            return view
        }
    }
    
    func updateIfNewModel(_ model: Model) {
        if model != self.model {
            self.model = model
            
            // put into container
            if let view = ViewBuilder.createView(self.model?.builder, useUIKit: self.options.useUIKit), let viewModel = self.model {
                self.containedView?.removeFromSuperview()
                self.containedView = view
                self.containerView?.addSubview(view)
                let indentation = CGFloat(viewModel.indentationLevel + 1)
                self.indentationConstraint?.constant = indentation * CGFloat(self.layout.indentationWidth)
                if let superview = view.superview {
                    let spacer: CGFloat = CGFloat(self.layout.containedViewInset)
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: spacer),
                        view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -spacer),
                        view.topAnchor.constraint(equalTo: superview.topAnchor, constant: spacer),
                        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -spacer)
                    ])
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.clipsToBounds = true
                }
            }
        }
    }
    
    func configured(_ model: Model) -> Self {
        self.updateIfNewModel(model)
        return self
    }
    
    func configured(useUIKit: Bool) -> Self {
        var options = self.options
        options.useUIKit = useUIKit
        self.update(options: options)
        return self
    }
    
    func configured(shouldShowIndent: Bool) -> Self {
        var options = self.options
        options.shouldShowIndent = shouldShowIndent
        self.update(options: options)
        return self
    }
}

// MARK: Toggle
extension DocumentViewCells.Cell {
    func update(options: Options) {
        if self.options.shouldShowIndent != options.shouldShowIndent {
            self.boundaryRevealConstraint?.constant = options.shouldShowIndent ? CGFloat(self.layout.boundaryWidth) : 0
            self.layoutIfNeeded()
        }
        
        self.options = options
    }
}

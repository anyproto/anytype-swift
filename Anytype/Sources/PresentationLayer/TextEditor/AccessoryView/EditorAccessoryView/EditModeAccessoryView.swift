//
//  EditModeAccessoryView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import UIKit


final class EditModeAccessoryView: UIView {
    enum EditModeAccessoryViewKind {
        case cursor
        case markap
    }

    var accessoryViewKind: EditModeAccessoryViewKind
    let cursorModeView: EditorAccessoryView
    let markupModeView: MarkupAccessoryView

    // MARK: - Lifecycle

    init(cursorModeView: EditorAccessoryView, markupModeView: MarkupAccessoryView) {
        self.cursorModeView = cursorModeView
        self.markupModeView = markupModeView
        self.accessoryViewKind = .cursor

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundPrimary
        addSubview(currentAccessoryView) {
            $0.pinToSuperview()
        }
    }

    private var currentAccessoryView: UIView {
        switch accessoryViewKind {
        case .cursor:
            return cursorModeView
        case .markap:
            return markupModeView
        }
    }

    private func changeAccessoryViewKind(_ kind: EditModeAccessoryViewKind) {
        currentAccessoryView.removeFromSuperview()

        self.accessoryViewKind = kind
        addSubview(currentAccessoryView) {
            $0.pinToSuperview()
        }
    }

    // MARK: - Public methos


    func selectionChanged(range: NSRange) {
        if case .markap = accessoryViewKind {
            if range.length == 0 {
                changeAccessoryViewKind(.cursor)
            }
        } else if range.length > 0 {
            changeAccessoryViewKind(.markap)
        }
    }

    func update(block: BlockModelProtocol, textView: CustomTextView) {
        cursorModeView.update(block: block, textView: textView)
    }

    // MARK: - Unavailable

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}

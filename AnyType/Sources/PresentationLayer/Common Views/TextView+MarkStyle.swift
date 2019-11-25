//
//  TextView+MarkStyle.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
//MARK: - Decorations / MarkStyle

//extension TextView {
//    enum Either<Left, Right> {
//        case left(Left)
//        case right(Right)
//    }
//    enum MarkStyle {
//        case bold(Bool = true) // turn on, turn off
//        case italic(Bool = true) // turn on, turn off
//        case strikethrough(Bool = true) // turn on, turn off
//        case underscored(Bool = true) // style also? // turn on, turn off
//        case keyboard(Bool = true) // turn on, turn off
//        case textColor(Color?) // choose colors
//        case backgroundColor(Color?) // choose colors
//        case link(URL?)
//    }
//    private func applyStyle(style: MarkStyle, range: Range<Int>) -> Self {
//        return self
//    }
//    func applyStyle(style: MarkStyle, rangeOrWholeString either: Either<Range<Int>, Bool>) -> Self {
//        if case let .right(value) = either, value == false {
//            return self
//        }
//        return self
//    }
//    func foregroundColor(_ color: UIColor?) -> Self {
//        if let color = color {
//            attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
//        }
//        return self
//    }
//    func strikedthrough(_ strikedthrough: Bool) -> Self {
//        attributedString.addAttribute(.strikethroughStyle, value: strikedthrough ? 1 : 0, range: NSRange(location: 0, length: text.count))
//        
//        return self
//    }
//}


struct TheTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var sizeThatFit: CGSize
    private var attributedString: NSMutableAttributedString
    
    // MARK: - Lifecycle
    
    init(text: Binding<String>, sizeThatFit: Binding<CGSize>) {
        _text = text
        _sizeThatFit = sizeThatFit
        attributedString = NSMutableAttributedString(string: text.wrappedValue)
    }
    
    // MARK: - Private methods
    
    private func createTextView() -> UITextView {
        let textView = UITextView()
        textView.font = UIFont(name: "HelveticaNeue", size: 15)
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = createTextView()
        textView.attributedText = NSAttributedString(string: text)
        textView.delegate = context.coordinator
        
        DispatchQueue.main.async {
            self.sizeThatFit = textView.intrinsicContentSize
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString
        //        uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TheTextView
        
        init(_ uiTextView: TheTextView) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            if (self.parent.sizeThatFit.height != size.height) {
                self.parent.sizeThatFit = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            }
        }
    }
}


//MARK: - Decorations

extension TheTextView {
    enum Either<Left, Right> {
        case left(Left)
        case right(Right)
    }
    enum MarkStyle {
        case bold(Bool = true) // turn on, turn off
        case italic(Bool = true) // turn on, turn off
        case strikethrough(Bool = true) // turn on, turn off
        case underscored(Bool = true) // style also? // turn on, turn off
        case keyboard(Bool = true) // turn on, turn off
        case textColor(Color?) // choose colors
        case backgroundColor(Color?) // choose colors
        case link(URL?)
    }
    private func applyStyle(style: MarkStyle, range: Range<Int>) -> Self {
        return self
    }
    func applyStyle(style: MarkStyle, rangeOrWholeString either: Either<Range<Int>, Bool>) -> Self {
        if case let .right(value) = either, value == false {
            return self
        }
        return self
    }
    func foregroundColor(_ color: UIColor?) -> Self {
        if let color = color {
            attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        }
        return self
    }
    func strikedthrough(_ strikedthrough: Bool) -> Self {
        attributedString.addAttribute(.strikethroughStyle, value: strikedthrough ? 1 : 0, range: NSRange(location: 0, length: text.count))
        
        return self
    }
}

struct TheTextView_Previews: PreviewProvider {
    @State static var text = ""
    @State static var sizeThatFit: CGSize = .zero
    
    static var previews: some View {
        VStack {
            TheTextView(text: $text, sizeThatFit: $sizeThatFit)
                .frame(maxWidth: 300, maxHeight: 50)
            TheTextView(text: $text, sizeThatFit: $sizeThatFit)
                .frame(maxWidth: 300, maxHeight: 50)
        }
    }
}

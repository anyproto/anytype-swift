//
//  TextView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "HelveticaNeue", size: 15)
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        textView.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        
        return textView
    }()
    
    @Binding var text: String
    @Binding var sizeThatFit: CGSize
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        textView.delegate = context.coordinator
        
        DispatchQueue.main.async {
            self.sizeThatFit = self.textView.intrinsicContentSize
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            
            self.parent.sizeThatFit = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        }
    }
}


struct TextView_Previews: PreviewProvider {
    @State static var text = ""
    @State static var sizeThatFit: CGSize = .zero
    
    static var previews: some View {
        VStack {
            TextView(text: $text, sizeThatFit: $sizeThatFit)
                .frame(maxWidth: 200, maxHeight: sizeThatFit.height)
        }
    }
}

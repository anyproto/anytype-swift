//
//  TextView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var sizeThatFit: CGSize
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let rect = CGRect(origin: .zero, size: sizeThatFit)
        let myTextView = UITextView(frame: rect)
        myTextView.delegate = context.coordinator
        
        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isScrollEnabled = false
        myTextView.textContainer.lineBreakMode = .byWordWrapping
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        myTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return myTextView
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
            print("text now: \(String(describing: textView.text!))")
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

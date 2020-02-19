//
//  TextView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine
import UIKit


// public TextView -> InnerTextView
// private InnerTextView -> UITextView
// private InnerTextView -> AttributesModifier

// TODO: We should keep state of attributed string in textView?
// Put attributedString into InnerTextView
struct TextView: View {
    @ObservedObject private var wholeTextMarkStyleKeeper: MarkStyleKeeper = .init()
    @ObservedObject var storage: Storage
    @Binding var text: String
    @State var sizeThatFit: CGSize = .init(width: 0.0, height: 31.0)
    
    weak var delegate: TextViewUserInteractionProtocol?
    
    var body: some View {
        InnerTextView(text: self.$text, sizeThatFit: self.$sizeThatFit, wholeTextMarkStyleKeeper: self._wholeTextMarkStyleKeeper, delegate: self.delegate)
            .frame(height: self.sizeThatFit.height)
    }
    
    // MARK: Lifecycle
    init(text: Binding<String>) {
        _text = text
        storage = .init()
    }
    
    init(text: Binding<String>, delegate: TextViewUserInteractionProtocol?) {
        self.init(text: text)
        self.delegate = delegate
    }
        
    // MARK: Enable updates
    // To jump in the darkest area of mocking, you set storage to keep changes of edited ranges.
    mutating func update(storage: ObservedObject<Storage>) -> Self {
        _storage = storage
        return self
    }
}


// MARK: - Decorations

extension TextView {
    
    class MarkStyleKeeper: ObservableObject {
        class InnerStorage {
            var strikethrough: Bool = false
            var textColor: UIColor?
        }
        @Published var value: InnerStorage = .init()
    }
   
    class Storage: ObservableObject {
        struct Update {
//            var style: MarkStyle
            var range: Range<Int>
        }
        
        @Published var updates: [Update] = []
        
        init(_ updates: [Update] = []) {
            self.updates = updates
        }
        
        func add(_ update: Update) -> Self {
            self.updates += [update]
            return self
        }
    }
        
    // MARK: Checkbox
    func foregroundColor(_ color: UIColor?) -> Self {
        if let color = color {
            self.wholeTextMarkStyleKeeper.value.textColor = color
        }
        return self
    }
    func strikethrough(_ strikethrough: Bool) -> Self {
        self.wholeTextMarkStyleKeeper.value.strikethrough = strikethrough
        return self
    }
}

//MARK: - Previews
struct TextView_Previews: PreviewProvider {
    @State static var text = ""
    @State static var sizeThatFit: CGSize = .zero
    
    static var previews: some View {
        VStack {
            TextView(text: $text)
                .frame(maxWidth: 300, maxHeight: 50)
            TextView(text: $text)
                .frame(maxWidth: 300, maxHeight: 50)
        }
    }
}

extension Logging.Categories {
    static let textView: Self = "textView"
}

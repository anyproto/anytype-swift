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
    @State var sizeThatFit: CGSize = CGSize(width: 0.0, height: 38.0)
    
    var body: some View {
        InnerTextView(text: self.$text, sizeThatFit: self.$sizeThatFit, wholeTextMarkStyleKeeper: self._wholeTextMarkStyleKeeper)
            .frame(height: self.sizeThatFit.height)
    }
    
    // MARK: Lifecycle
    init(text: Binding<String>) {
        _text = text
        storage = .init()
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
            var strikedthrough: Bool = false
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
    
    func strikedthrough(_ strikedthrough: Bool) -> Self {
        self.wholeTextMarkStyleKeeper.value.strikedthrough = strikedthrough
        return self
    }
}


// MARK: - TextView

private struct InnerTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var sizeThatFit: CGSize
    @ObservedObject var wholeTextMarkStyleKeeper: TextView.MarkStyleKeeper
    @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
    
    // MARK: - Lifecycle

    init(text: Binding<String>, sizeThatFit: Binding<CGSize>, wholeTextMarkStyleKeeper: ObservedObject<TextView.MarkStyleKeeper>) {
        _text = text
        _sizeThatFit = sizeThatFit
        _wholeTextMarkStyleKeeper = wholeTextMarkStyleKeeper
    }
        
    // MARK: - Private methods
    
    private func createTextView() -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textContainer.lineFragmentPadding = 0.0
//        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        //TODO: add debug here.
        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }
        
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = createTextView()
        context.coordinator.configureMarkStylePublisher(textView)
        context.coordinator.configureBlocksToolbarHandler(textView)
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap(_:)))
        tapGesture.delegate = context.coordinator
        textView.addGestureRecognizer(tapGesture)
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.setAttributes([.font : UIFont.preferredFont(forTextStyle: .body)], range: NSRange(location: 0, length: attributedString.length))
        textView.textStorage.setAttributedString(attributedString)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.updateWholeMarkStyle(uiView, wholeMarkStyleKeeper: self.wholeTextMarkStyleKeeper)
        }
    }
}


// MARK: - InnerTextView / Coordinator

extension InnerTextView {
    class Coordinator: NSObject {
        // MARK: Aliases
        typealias HighlightedAccessoryView = TextView.HighlightedAccessoryView
        typealias BlockToolbarAccesoryView = TextView.BlockToolbar.AccessoryView
        
        // MARK: Variables
        var parent: InnerTextView
        
        @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
        
        lazy private var highlightedAccessoryView: HighlightedAccessoryView = .init()
        private var highlightedAccessoryViewHandler: (((NSRange, NSTextStorage)) -> ())?

        var highlightedMarkStyleHandler: AnyCancellable?
        var changeColorMarkStyleHandler: AnyCancellable?
        var wholeMarkStyleHandler: AnyCancellable?
        
        lazy private var blocksAccessoryView: BlockToolbarAccesoryView = .init()
        
        var defaultKeyboardRect: CGRect = .zero
        var blocksAccessoryViewHandler: AnyCancellable?
                
        // MARK: - Initiazliation
        init(_ uiTextView: InnerTextView) {
            self.parent = uiTextView
            self._outerViewNeedsLayout = uiTextView._outerViewNeedsLayout
            super.init()
            self.setup()
        }
        
        func setup() {
            self.configureInnerAccessoryViewHandler()
            self.configureKeyboardNotificationsListening()
        }
                
        // MARK: Keyboard Handling
        @objc func keyboardWillShow(notification: Notification) {
            if self.defaultKeyboardRect == .zero, let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                // save size?
                self.defaultKeyboardRect = rect
//                print("get new keyboard size: \(self.defaultKeyboardRect)")
            }
        }
        
        func configureKeyboardNotificationsListening() {
            NotificationCenter.default.addObserver(self, selector: #selector(Self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    }
}


// MARK: - InnerTextView.Coordinator / Publishers
extension InnerTextView.Coordinator {
    // MARK: - Publishers
    // MARK: - Publishers / Blocks Toolbar
    func configureBlocksToolbarHandler(_ view: UITextView) {
        self.blocksAccessoryViewHandler = Publishers.CombineLatest(Just(view), self.blocksAccessoryView.model.$userAction).sink(receiveValue: { (value) in
            let (textView, action) = value
            
            if let currentView = textView.inputView, let nextView = action.view, type(of: currentView) == type(of: nextView) {
                textView.inputView = nil
                textView.reloadInputViews()
                // send event.
                return
            }

//            print("keyboardSize: \(self.defaultKeyboardRect.size)")
            
            let view = action.view
            view?.frame = .init(x: 0, y: 0, width: self.defaultKeyboardRect.size.width, height: self.defaultKeyboardRect.size.height)
            
//            print("newKeyboardSize: \(String(describing: view?.frame.size))")
            textView.inputView = view
            textView.reloadInputViews()
        })
    }
    
    // MARK: - Publishers / Highlighted Toolbar
    func updateWholeMarkStyle(_ view: UITextView, wholeMarkStyleKeeper: TextView.MarkStyleKeeper) {
        let (textView, value) = (view, wholeMarkStyleKeeper.value)
        let attributedText = textView.textStorage
        let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
        if let style = modifier.getMarkStyle(style: .strikethrough(value.strikedthrough), at: .whole(true)), style != .strikethrough(value.strikedthrough) {
            _ = modifier.applyStyle(style: .strikethrough(value.strikedthrough), rangeOrWholeString: .whole(true))
        }
        if let color = value.textColor, let style = modifier.getMarkStyle(style: .textColor(color), at: .whole(true)), style != .textColor(color) {
            _ = modifier.applyStyle(style: .textColor(color), rangeOrWholeString: .whole(true))
        }
    }
    func configureWholeMarkStylePublisher(_ view: UITextView, wholeMarkStyleKeeper: TextView.MarkStyleKeeper) {
        self.wholeMarkStyleHandler = Publishers.CombineLatest(Just(view), wholeMarkStyleKeeper.$value).sink { (textView, value) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            if let style = modifier.getMarkStyle(style: .strikethrough(value.strikedthrough), at: .whole(true)), style != .strikethrough(value.strikedthrough) {
                _ = modifier.applyStyle(style: .strikethrough(value.strikedthrough), rangeOrWholeString: .whole(true))
            }
            if let color = value.textColor, let style = modifier.getMarkStyle(style: .textColor(color), at: .whole(true)), style != .textColor(color) {
                _ = modifier.applyStyle(style: .textColor(color), rangeOrWholeString: .whole(true))
            }
        }
    }
    
    func configureInnerAccessoryViewHandler() {
        self.highlightedAccessoryViewHandler = { [weak self] (pair) in
            let (range, text) = pair
            self?.highlightedAccessoryView.model.update(range: range, attributedText: text)
        }
    }
    
    func configureMarkStylePublisher(_ view: UITextView) {
        self.changeColorMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.changeColorSubject).sink { (pair) in
            let (textView, (range, textColor, backgroundColor)) = pair
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)

//            print("range is: \(range)")
            
            guard range.length > 0 else { return }
            if let textColor = textColor {
                _ = modifier.applyStyle(style: .textColor(textColor), rangeOrWholeString: .range(range))
            }
            if let backgroundColor = backgroundColor {
                _ = modifier.applyStyle(style: .backgroundColor(backgroundColor), rangeOrWholeString: .range(range))
            }
            //TODO: Uncomment if needed.
            //We can process .textColor and .backgroundColor states to change icon.
//            self.highlightedAccessoryViewHandler?((range, attributedText))
        }
        self.highlightedMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.$userAction).sink { (textView, action) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            
//            print("\(action)")
            
            switch action {
            case let .bold(range):
                if let style = modifier.getMarkStyle(style: .bold(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))

            case let .italic(range):
                if let style = modifier.getMarkStyle(style: .italic(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
            case let .strikethrough(range):
                if let style = modifier.getMarkStyle(style: .strikethrough(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
            case let .code(range):
                if let style = modifier.getMarkStyle(style: .keyboard(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
            case let .changeColor(_, inputView):
                if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
                    textView.inputView = nil
                    textView.reloadInputViews()
                    // send event.
                    return
                }
                inputView?.frame = .init(x: 0, y: 0, width: self.defaultKeyboardRect.size.width, height: self.defaultKeyboardRect.size.height)
                textView.inputView = inputView
                textView.reloadInputViews()
            default: return
            }
        }
    }

}


// MARK: - InnerTextView.Coordinator / UITextViewDelegate

extension InnerTextView.Coordinator: UITextViewDelegate {
    // MARK: Input Switching
    func switchInputs(_ textView: UITextView) {
        func switchInputs(_ length: Int, accessoryView: UIView?, inputView: UIView?) -> (Bool, UIView?, UIView?) {
            switch (length, accessoryView, inputView) {
            // Length == 0, => set blocks toolbar and restore default keyboard.
            case (0, _, _): return (true, self.blocksAccessoryView, nil)
            // Length != 0 and is BlockToolbarAccessoryView => set highlighted accessory view and restore default keyboard.
            case (_, is BlockToolbarAccesoryView, _): return (true, self.highlightedAccessoryView, nil)
            // Otherwise, we need to keep accessory view and keyboard.
            default: return (false, accessoryView, inputView)
            }
        }
        
        let (shouldAnimate, accessoryView, inputView) = switchInputs(textView.selectedRange.length, accessoryView: textView.inputAccessoryView, inputView: textView.inputView)
        
        if shouldAnimate {
            textView.inputAccessoryView = accessoryView
            textView.inputView = inputView
            textView.reloadInputViews()
        }
        
        if (textView.inputAccessoryView is HighlightedAccessoryView) {
            let range = textView.selectedRange
            let attributedText = textView.textStorage
            self.highlightedAccessoryViewHandler?((range, attributedText))
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.switchInputs(textView)
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.switchInputs(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.switchInputs(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            // TODO: rethink.
            // We require this environment object update to notify outer views to call setNeedsLayout to fix sizes.
            self.outerViewNeedsLayout.needsLayout = ()
            self.parent.text = textView.text
            self.parent.sizeThatFit = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
        }
    }
}


// MARK: - InnerTextView.Coordinator / UIGestureRecognizerDelegate

extension InnerTextView.Coordinator: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func tap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
             print("tap began")
        } else if gestureRecognizer.state == .recognized {
            gestureRecognizer.view?.becomeFirstResponder()
             print("tap recognized")
        } else if gestureRecognizer.state == .possible {
            print("tap possible")
        } else if gestureRecognizer.state == .changed {
            print("tap changed")
        } else if gestureRecognizer.state == .ended {
            print("tap ended")
        } else if gestureRecognizer.state == .failed {
            print("tap failed")
        } else if gestureRecognizer.state == .cancelled {
             print("tap cancelled")
        }
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

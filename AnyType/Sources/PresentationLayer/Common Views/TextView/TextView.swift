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
    
    var body: some View {
        InnerTextView(text: self.$text, sizeThatFit: self.$sizeThatFit, wholeTextMarkStyleKeeper: self._wholeTextMarkStyleKeeper)
            .frame(minHeight: self.sizeThatFit.height, idealHeight: self.sizeThatFit.height, maxHeight: self.sizeThatFit.height).modifier(BaseView())
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

// MARK: Decorations
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

// MARK: UserActions
extension TextView {
    public enum UserAction {
        typealias BlockAction = TextView.BlockToolbar.UnderlyingAction
        
        typealias MarksAction = TextView.HighlightedToolbar.UnderlyingAction // it should be what?! I guess it is Action with range, right?!
         
        // Actions with text...
        enum InputAction {
            case changeText(String)
        }
        
        // Actions with input custom keys...
        enum KeyboardAction {
            enum Key {
                case enterWithPayload(String?)
                case enterAtBeginning
                case enter
                case deleteWithPayload(String?)
                case delete
                static func convert(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Self? {
                    //
                    // Well...
                    // We should also keep values to the right of the Cursor.
                    // So, enter key should have minimum one value as String on the right as Optional<String>
//                    print("textView: \(textView.text) range: \(range) text: \(text). Text length: \(text.count)")
                    print("textViewLength: \(textView.text.count) range: \(range) textLength: \(text.count)")
                    switch (textView.text, range, text) {
                    case (_, .init(location: 1, length: 0), "\n"): return .enterAtBeginning
                    case let (source, at, "\n") where source?.count == at.location + at.length: return .enter
                    case let (source, at, "\n"):
                        guard let source = source, let theRange = Range(at, in: source) else { return nil }
                        return .enterWithPayload(source.replacingCharacters(in: theRange, with: "\n").split(separator: "\n").last.flatMap(String.init))
                    case ("", .init(location: 0,length: 0), ""): return .delete
                    case let (source, .init(location: 0, length: 0), ""): return .deleteWithPayload(source)
                    default: return nil
                    }
                }
            }
            case pressKey(Key)
            static func convert(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Self? {
//                print("textView.text: \(String(describing: textView.text))")
//                print("textView.range: \(range)")
//                print("textView.replacementText: \(text)")
                return Key.convert(textView, shouldChangeTextIn: range, replacementText: text).flatMap{.pressKey($0)}
            }
        }
        
        case blockAction(BlockAction), marksAction(MarksAction), inputAction(InputAction), keyboardAction(KeyboardAction)
    }
}

// MARK: TextView
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
        textView.font = .preferredFont(forTextStyle: .title1)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        //TODO: add debug here.
//        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
//        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }
        
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = createTextView()
        let attributedString = NSMutableAttributedString(string: text)
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.preferredFont(forTextStyle: .body)]
        let range = NSRange(location: 0, length: attributedString.length)
        textView.typingAttributes = attributes
        textView.textStorage.setAttributedString(attributedString)
        textView.textStorage.setAttributes(attributes, range: range)
        context.coordinator.configureMarkStylePublisher(textView)
        context.coordinator.configureBlocksToolbarHandler(textView)
        context.coordinator.userInteractionDelegate = context.coordinator
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        
        
        DispatchQueue.main.async {
            self.sizeThatFit = textView.intrinsicContentSize
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.updateWholeMarkStyle(uiView, wholeMarkStyleKeeper: self.wholeTextMarkStyleKeeper)
    }
}

// MARK: InnerTextView / Coordinator
extension InnerTextView {
    class Coordinator: NSObject {
        // MARK: Aliases
        typealias HighlightedAccessoryView = TextView.HighlightedToolbar.AccessoryView
        typealias BlockToolbarAccesoryView = TextView.BlockToolbar.AccessoryView
        
        // MARK: Variables
        var parent: InnerTextView
        
        @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
        
        weak var userInteractionDelegate: TextViewUserInteractionProtocol?
        func configure(_ delegate: TextViewUserInteractionProtocol?) -> Self {
            self.userInteractionDelegate = delegate
            return self
        }
        
        lazy private var highlightedAccessoryView: HighlightedAccessoryView = .init()
        private var highlightedAccessoryViewHandler: (((NSRange, NSTextStorage)) -> ())?
        
        var highlightedMarkStyleHandler: AnyCancellable?
        var wholeMarkStyleHandler: AnyCancellable?
        
        lazy private var blocksAccessoryView: BlockToolbarAccesoryView = .init()
        var blocksAccessoryViewHandler: AnyCancellable?
        var blocksUserActionsHandler: AnyCancellable?
        
        var defaultKeyboardRect: CGRect = .zero
                
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
                print("get new keyboard size: \(self.defaultKeyboardRect)")
            }
        }
        
        func configureKeyboardNotificationsListening() {
            NotificationCenter.default.addObserver(self, selector: #selector(Self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    }
}

// MARK: InnerTextView.Coordinator / Publishers
extension InnerTextView.Coordinator {
    // MARK: - Publishers
    // MARK: - Publishers / Outer world
    
    func publishToOuterWorld(_ action: TextView.UserAction?) {
        action.flatMap({self.userInteractionDelegate?.didReceiveAction($0)})
    }
    func publishToOuterWorld(_ action: TextView.UserAction.BlockAction?) {
        action.flatMap(TextView.UserAction.blockAction).flatMap(publishToOuterWorld)
    }
    func publishToOuterWorld(_ action: TextView.UserAction.MarksAction?) {
        action.flatMap(TextView.UserAction.marksAction).flatMap(publishToOuterWorld)
    }
    func publishToOuterWorld(_ action: TextView.UserAction.InputAction?) {
        action.flatMap(TextView.UserAction.inputAction).flatMap(publishToOuterWorld)
    }
    func publishToOuterWorld(_ action: TextView.UserAction.KeyboardAction?) {
        action.flatMap(TextView.UserAction.keyboardAction).flatMap(publishToOuterWorld)
    }
    
    // MARK: - Publishers / Blocks Toolbar
    func configureBlocksToolbarHandler(_ view: UITextView) {
        self.blocksAccessoryViewHandler = Publishers.CombineLatest(Just(view), self.blocksAccessoryView.model.$userAction).sink(receiveValue: { (value) in
            let (textView, action) = value
            
            guard action.action != .keyboardDismiss else {
                textView.endEditing(false)
                return
            }
            
            self.switchInputs(textView, accessoryView: nil, inputView: action.view)
        })
        
        // TODO: Add other user interaction publishers.
        // 1. Add hook that will send this data to delegate.
        // 2. Add delegate that will take UserAction like delegate?.onUserAction(UserAction)
        // 3. Add another delegate that will "wraps" UserAction with information about block ( first delegate IS a observableModel or even just ObservableObject or @binding... )
        // 4. Second delegate is a documentViewModel ( so, it needs information about block if available.. )
        // 5. Add hook to receive user key inputs and context of current text View. ( enter may behave different ).
        // 6. Add hook that will catch marks styles. ( special convert for links and colors )
        self.blocksUserActionsHandler = Publishers.CombineLatest(Just(view), self.blocksAccessoryView.model.allInOnePublisher).sink { [weak self] value in
            let (_, action) = value
            // now tell outer world that we are ready to process actions.
            // ...
            self?.publishToOuterWorld(action)
        }
    }
    
    // MARK: - Publishers / Highlighted Toolbar
    func updateWholeMarkStyle(_ view: UITextView, wholeMarkStyleKeeper: TextView.MarkStyleKeeper) {
        let (textView, value) = (view, wholeMarkStyleKeeper.value)
        let attributedText = textView.textStorage
        let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
        if let style = modifier.getMarkStyle(style: .strikethrough(value.strikethrough), at: .whole(true)), style != .strikethrough(value.strikethrough) {
            _ = modifier.applyStyle(style: .strikethrough(value.strikethrough), rangeOrWholeString: .whole(true))
        }
        if let color = value.textColor, let style = modifier.getMarkStyle(style: .textColor(color), at: .whole(true)), style != .textColor(color) {
            _ = modifier.applyStyle(style: .textColor(color), rangeOrWholeString: .whole(true))
        }
    }
    func configureWholeMarkStylePublisher(_ view: UITextView, wholeMarkStyleKeeper: TextView.MarkStyleKeeper) {
        self.wholeMarkStyleHandler = Publishers.CombineLatest(Just(view), wholeMarkStyleKeeper.$value).sink { (textView, value) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            if let style = modifier.getMarkStyle(style: .strikethrough(value.strikethrough), at: .whole(true)), style != .strikethrough(value.strikethrough) {
                _ = modifier.applyStyle(style: .strikethrough(value.strikethrough), rangeOrWholeString: .whole(true))
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
        self.highlightedMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.$userAction).sink { (textView, action) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            print("\(action)")
            switch action {
            case .keyboardDismiss: textView.endEditing(false)
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
                
            case let .keyboard(range):
                if let style = modifier.getMarkStyle(style: .keyboard(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
                
            case let .linkView(range, builder):
                let style = modifier.getMarkStyle(style: .link(nil), at: .range(range))
                let string = attributedText.attributedSubstring(from: range).string
                let view = builder(string, style.flatMap({
                    switch $0 {
                    case let .link(link): return link
                    default: return nil
                    }
                }))
                self.setFocus(in: textView, at: range)
                self.switchInputs(textView, accessoryView: view, inputView: nil)
                // we should apply selection attributes to indicate place where link will be applied.

            case let .link(range, url):
                self.unsetFocus(in: textView)
                guard range.length > 0 else { return }
                _ = modifier.applyStyle(style: .link(url), rangeOrWholeString: .range(range))
                self.highlightedAccessoryViewHandler?((range, attributedText))
                self.switchInputs(textView)
                textView.becomeFirstResponder()
                
            case let .changeColorView(_, inputView):
                self.switchInputs(textView, accessoryView: nil, inputView: inputView)

            case let .changeColor(range, textColor, backgroundColor):
                guard range.length > 0 else { return }
                if let textColor = textColor {
                    _ = modifier.applyStyle(style: .textColor(textColor), rangeOrWholeString: .range(range))
                }
                if let backgroundColor = backgroundColor {
                    _ = modifier.applyStyle(style: .backgroundColor(backgroundColor), rangeOrWholeString: .range(range))
                }
                return
            default: return
            }
        }
    }

}

// MARK: InnerTextView.Coordinator / ResponderProxy
extension InnerTextView.Coordinator {
//    class ResponderProxy: UIResponder {
//        var textView: UITextView?
//        var hasTextView: Bool {textView != nil}
//        fileprivate func configure(_ textView: UITextView?) -> Self {
//            self.textView = textView
//            return self
//        }
//        func inject() {
//            if hasTextView {
//                let next = self.textView?.next
//                self.textView?.next = self
//                self.next = next
//            }
//        }
//    }
}

// MARK: InnerTextView.Coordinator / UITextViewDelegate
extension InnerTextView.Coordinator: UITextViewDelegate {
    // MARK: Debug
    func outputResponderChain(_ responder: UIResponder?) {
        let chain = sequence(first: responder, next: {$0?.next}).compactMap({$0}).reduce("") { (result, responder) -> String in
            result + " -> \(String(describing: type(of: responder)))"
        }
        print("chain: \(chain)")
    }
    // MARK: Selection and Marked Text
    func setFocus(in textView: UITextView, at range: NSRange) {
        // set attributes of text or place view around it?
//        let attributedText = textView.textStorage
//        let string = attributedText.attributedSubstring(from: range).string
//        textView.setMarkedText(string, selectedRange: range)
//        textView.selectedTextRange = textView.markedTextRange
//        print("setFocus here: \(String(describing: textView.selectedTextRange))")
//        textView.selectedTextRange = textView.textRange(from: <#T##UITextPosition#>, to: <#T##UITextPosition#>)
//        textView.textStorage.setAttributes([.markedClauseSegment : 1], range: range)
    }
    
    func unsetFocus(in textView: UITextView) {
//        let markedTextRange = textView.markedTextRange
//        textView.unmarkText()
//        textView.selectedTextRange = markedTextRange
//        let range = textView.selectedRange
//        textView.textStorage.removeAttribute(.markedClauseSegment, range: range)//([.textEffect : nil], range: range)
    }
    
    // MARK: Input Switching
    func switchInputs(_ textView: UITextView, accessoryView: UIView?, inputView: UIView?) {
        if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
            textView.inputView = nil
            textView.reloadInputViews()
            return
        }
        else {
            inputView?.frame = .init(x: 0, y: 0, width: self.defaultKeyboardRect.size.width, height: self.defaultKeyboardRect.size.height)
            textView.inputView = inputView
            textView.reloadInputViews()
        }
        
        if let accessoryView = accessoryView {
            textView.inputAccessoryView = accessoryView
            textView.reloadInputViews()
        }
    }
    func switchInputs(_ textView: UITextView) {
        func switchInputs(_ length: Int, accessoryView: UIView?, inputView: UIView?) -> (Bool, UIView?, UIView?) {
            switch (length, accessoryView, inputView) {
            // Length == 0, => set blocks toolbar and restore default keyboard.
            case (0, _, _): return (true, self.blocksAccessoryView, nil)
            // Length != 0 and is BlockToolbarAccessoryView => set highlighted accessory view and restore default keyboard.
            case (_, is BlockToolbarAccesoryView, _): return (true, self.highlightedAccessoryView, nil)
            // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
            case (_, is TextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return (true, self.highlightedAccessoryView, nil)
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.publishToOuterWorld(TextView.UserAction.KeyboardAction.convert(textView, shouldChangeTextIn: range, replacementText: text))
        if text == "\n" {
            // we should return false and perform update by ourselves.
        }
        return true
    }
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
            self.outerViewNeedsLayout.needsLayout = true
            self.parent.text = textView.text
            self.parent.sizeThatFit = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        }
    }
}

//MARK: TextViewUserInteractionProtocol
extension InnerTextView.Coordinator: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        print("I receive! \(action)")
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


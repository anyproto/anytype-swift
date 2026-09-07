import Testing
import UIKit
@testable import Anytype

@MainActor
struct QuickCaptureInputObserverTests {
    @Test(arguments: ["a", "\n", ""])
    func inputIsObservedEvenWhenEditorInterceptsIt(_ replacement: String) throws {
        let textView = UITextView()
        let delegate = InputDelegate()
        textView.delegate = delegate
        let observer = QuickCaptureInputObserver()
        var inputCount = 0
        observer.observe(textView) { inputCount += 1 }

        let accepted = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: replacement)

        #expect(accepted == false)
        #expect(inputCount == 1)
        #expect(delegate.replacements == [replacement])
        #expect(textView.delegate === delegate)
    }

    @Test func installingAndRemovingObserverDoesNotCountAsInput() {
        let textView = UITextView()
        let delegate = InputDelegate()
        textView.delegate = delegate
        let observer = QuickCaptureInputObserver()
        var inputCount = 0
        observer.observe(textView) { inputCount += 1 }
        observer.stopObserving()
        #expect(inputCount == 0)
        #expect(textView.delegate === delegate)
    }

    @Test func otherDelegateCallbacksAreForwarded() {
        let textView = UITextView()
        let delegate = InputDelegate()
        textView.delegate = delegate
        let observer = QuickCaptureInputObserver()
        observer.observe(textView) { }
        #expect(observer.responds(to: #selector(UITextViewDelegate.textViewDidEndEditing(_:))))
        textView.delegate?.textViewDidEndEditing?(textView)
        #expect(delegate.didEndEditing)
        observer.stopObserving()
    }

    @Test func movingObserverRestoresPreviousTextViewWithoutOverwritingReplacementDelegate() {
        let first = UITextView()
        let second = UITextView()
        let original = InputDelegate()
        let replacement = InputDelegate()
        first.delegate = original
        let observer = QuickCaptureInputObserver()
        observer.observe(first) { }
        observer.observe(second) { }
        #expect(first.delegate === original)
        second.delegate = replacement
        observer.stopObserving()
        #expect(second.delegate === replacement)
    }
}

@MainActor
private final class InputDelegate: NSObject, UITextViewDelegate {
    var replacements = [String]()
    var didEndEditing = false

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        replacements.append(text)
        return false
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditing = true
    }
}

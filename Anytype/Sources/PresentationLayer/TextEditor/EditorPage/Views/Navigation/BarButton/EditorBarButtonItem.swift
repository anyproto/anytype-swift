import SwiftUI

struct EditorBarButtonItem: UIViewRepresentable {
    let image: UIImage
    let state: EditorBarItemState
    let action: () -> ()
    
    func makeUIView(context: Context) -> UIEditorBarButtonItemContainer {
        return UIEditorBarButtonItemContainer(image: image, action: action)
    }
    
    func updateUIView(_ item: UIEditorBarButtonItemContainer, context: Context) {
        item.changeState(state)
    }
}

final class UIEditorBarButtonItemContainer: UIView {
    let button: UIEditorBarButtonItem

    override var intrinsicContentSize: CGSize { .init(width: 44, height: 44) }

    required init(image: UIImage, action: @escaping () -> Void) {
        button = .init(image: image, action: action)
        super.init(frame: .zero)
        addSubview(button) {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeState(_ state: EditorBarItemState) {
        button.changeState(state)
    }
}

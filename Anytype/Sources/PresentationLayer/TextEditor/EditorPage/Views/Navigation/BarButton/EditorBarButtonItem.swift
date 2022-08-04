import SwiftUI

struct EditorBarButtonItem: UIViewRepresentable {
    let imageAsset: ImageAsset
    let state: EditorBarItemState
    let action: () -> ()
    
    func makeUIView(context: Context) -> UIEditorBarButtonItemContainer {
        return UIEditorBarButtonItemContainer(imageAsset: imageAsset, action: action)
    }
    
    func updateUIView(_ item: UIEditorBarButtonItemContainer, context: Context) {
        item.changeState(state)
    }
}

final class UIEditorBarButtonItemContainer: UIView {
    let button: UIEditorBarButtonItem

    override var intrinsicContentSize: CGSize { .init(width: 44, height: 44) }

    required init(imageAsset: ImageAsset, action: @escaping () -> Void) {
        button = .init(imageAsset: imageAsset, action: action)
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

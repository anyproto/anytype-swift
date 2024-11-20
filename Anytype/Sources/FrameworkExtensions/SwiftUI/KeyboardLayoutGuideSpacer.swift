import SwiftUI

//struct KeyboardLayoutGuideSpacer: View {
//    
//    @State private var keyboardSize: CGSize = .zero
//    
//    var body: some View {
//        Color.clear.frame(height: keyboardSize.height)
//    }
//}


struct KeyboardSizeReader: UIViewRepresentable {
    
    @Binding var keyboardSize: CGSize
    
    func makeUIView(context: Context) -> some UIView {
        let container = UIView()
        container.backgroundColor = .red
        
        let subview = UIViewKeyboardLayoutGuideInteractiveHandler()
        subview.backgroundColor = .green
        container.addSubview(subview) {
            $0.top.equal(to: container.keyboardLayoutGuide.topAnchor)
            $0.leading.equal(to: container.keyboardLayoutGuide.leadingAnchor)
            $0.trailing.equal(to: container.keyboardLayoutGuide.trailingAnchor)
            $0.bottom.equal(to: container.keyboardLayoutGuide.bottomAnchor)
        }
        
        subview.keyboardSize = $keyboardSize
        
        return container
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

final class UIViewKeyboardLayoutGuideInteractiveHandler: UIView {
    
//    override init(frame: CGRect) {
//        super
//    }
    
//    var onChangeSize: ((CGSize) -> Void)?
    
    var keyboardSize: Binding<CGSize>?
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        print("KP bounds \(frame)")
//        onChangeSize?(frame.size)
        keyboardSize?.wrappedValue = frame.size
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
        
//        let subview = UIView()
//        subview.backgroundColor = .green
//        addSubview(subview) {
//            $0.top.equal(to: keyboardLayoutGuide.topAnchor)
//            $0.leading.equal(to: keyboardLayoutGuide.leadingAnchor)
//            $0.trailing.equal(to: keyboardLayoutGuide.trailingAnchor)
//            $0.bottom.equal(to: keyboardLayoutGuide.bottomAnchor)
//        }
        
//        guard let superview else { return }
        
//        topAnchor.constraint(equalTo: superview.keyboardLayoutGuide.topAnchor).isActive = true
//        leadingAnchor.constraint(equalTo: superview.keyboardLayoutGuide.leadingAnchor).isActive = true
//        trailingAnchor.constraint(equalTo: superview.keyboardLayoutGuide.trailingAnchor).isActive = true
//        bottomAnchor.constraint(equalTo: superview.keyboardLayoutGuide.bottomAnchor).isActive = true
//    }
}

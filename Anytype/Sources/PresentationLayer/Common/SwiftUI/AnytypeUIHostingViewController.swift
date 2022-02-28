import Foundation
import ObjectiveC
import SwiftUI

class AnytypeUIHostingViewController<Content: View>: UIHostingController<Content> {
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        fixSafeAreaInsets()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    private func fixSafeAreaInsets() {
        guard let _class = view?.classForCoder else { return }
        
        let safeAreaInsets: @convention (block) (AnyObject) -> UIEdgeInsets = { (self : AnyObject!) -> UIEdgeInsets in
            return .zero
        }
        guard let method = class_getInstanceMethod(_class.self, #selector(getter: UIView.safeAreaInsets)) else { return }
        class_replaceMethod(_class, #selector (getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding (method) )
        let safeAreaLayoutGuide: @convention (block) (AnyObject) -> UILayoutGuide? = { (self : AnyObject!) -> UILayoutGuide? in
            return nil
        }
        
        guard let method2 = class_getInstanceMethod(_class.self, #selector (getter: UIView.safeAreaLayoutGuide)) else { return }
        
        class_replaceMethod(_class, #selector (getter: UIView.safeAreaLayoutGuide),
        imp_implementationWithBlock(safeAreaLayoutGuide),method_getTypeEncoding(method2))
    }
}

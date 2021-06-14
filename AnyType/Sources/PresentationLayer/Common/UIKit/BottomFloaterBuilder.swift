import SwiftUI

struct BottomFloaterBuilder {
    
    func builBottomFloater<Content: View>(@ViewBuilder content: () -> Content) -> UIViewController {
        let controller = UIHostingController(
            rootView: FloaterWrapper(content: content)
        )
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        
        controller.rootView.onHide =  { [weak controller] in
            controller?.dismiss(animated: false)
        }
        
        return controller
    }
    
}

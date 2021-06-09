import SwiftUI

extension UIViewController {
    func showEditorSettings() {
        showBottomFloater {
            SettingsAssembly().settingsView().padding() // TODO: Add  real view
        }
    }
    
    private func showBottomFloater<Content: View>(@ViewBuilder content: () -> Content) {
        let controller = UIHostingController(rootView: FloaterWrapper(content: content))
        controller.modalPresentationStyle = .overCurrentContext
        
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        
        controller.rootView.onHide =  { [weak controller] in
            controller?.dismiss(animated: false)
        }
        
        present(controller, animated: false)
    }
}

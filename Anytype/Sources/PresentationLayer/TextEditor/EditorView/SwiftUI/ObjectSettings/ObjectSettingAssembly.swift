import SwiftUI

final class ObjectSettingAssembly {
    func coverPicker(viewModel: ObjectCoverPickerViewModel) -> UIViewController {
        let controller = UIHostingController(
            rootView: ObjectCoverPicker(viewModel: viewModel)
        )
        
        controller.rootView.onDismiss = { [weak controller] in
            controller?.dismiss(animated: true)
        }
        
        return controller
    }
    
    func iconPicker(viewModel: ObjectIconPickerViewModel) -> UIViewController {
        let controller = UIHostingController(
            rootView: ObjectIconPicker(viewModel: viewModel)
        )
        
        controller.rootView.dismissHandler = DismissHandler(
            onDismiss:  { [weak controller] in
                controller?.dismiss(animated: true)
            }
        )
        
        return controller
    }
}

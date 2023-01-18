import Foundation
import SwiftUI

struct SwiftUIModule {
    var view: AnyView
    var dismissable: Dismissible?
    
    init<M>(view: some View, model: M? = nil) where M: Dismissible {
        self.view = view.eraseToAnyView()
        self.dismissable = model
    }
}

extension NavigationContextProtocol {
    func present(_ module: SwiftUIModule, animated: Bool = true) {
        presentSwiftUIView(view: module.view, model: module.dismissable, animated: animated)
    }
}

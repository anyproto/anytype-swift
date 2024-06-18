import Foundation

// TODO: Legacy DI. Delete it for support multiwindow.
extension Container {
    
    // Registry in scene delegate
    var legacyViewControllerProvider: Factory<ViewControllerProviderProtocol> {
        self { ViewControllerProvider.shared }.singleton
    }
    
    var legacyToastPresenter: Factory<ToastPresenterProtocol> {
        self { ToastPresenter() }
    }
    
    var legacyNavigationContext: Factory<NavigationContextProtocol> {
        self { NavigationContext() }
    }
    
    var keyboardHeightListener: Factory<KeyboardHeightListener> {
        self { KeyboardHeightListener() }
    }
}


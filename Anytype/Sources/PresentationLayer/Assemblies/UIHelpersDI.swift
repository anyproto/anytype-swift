import Foundation

// TODO: Legacy DI. Delete it for support multiwindow.
extension Container {
    
    // Registry in scene delegate
    var legacyViewControllerProvider: Factory<any ViewControllerProviderProtocol> {
        self { ViewControllerProvider() }.singleton
    }
    
    var legacyToastPresenter: Factory<any ToastPresenterProtocol> {
        self { ToastPresenter() }
    }
    
    var legacyNavigationContext: Factory<any NavigationContextProtocol> {
        self { NavigationContext() }
    }
    
    @MainActor
    var keyboardHeightListener: Factory<KeyboardHeightListener> {
        self { KeyboardHeightListener() }
    }
}


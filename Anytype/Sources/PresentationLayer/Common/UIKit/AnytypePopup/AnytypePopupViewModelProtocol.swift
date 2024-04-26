import Foundation
import UIKit.UIViewController
import FloatingPanel


@MainActor
protocol AnytypePopupViewModelProtocol {
    
    var popupLayout: AnytypePopupLayoutType { get }
    
    func onPopupInstall(_ popup: AnytypePopupProxy)
    
    func makeContentView() -> UIViewController
    
    func willAppear()
}

// Default implementation 
extension AnytypePopupViewModelProtocol {
    func willAppear() {}
}

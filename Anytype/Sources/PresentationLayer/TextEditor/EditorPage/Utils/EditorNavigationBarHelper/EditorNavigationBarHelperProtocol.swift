import UIKit
import BlocksModels

protocol EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView)
    
    func handleViewWillAppear(scrollView: UIScrollView)
    func handleViewWillDisappear()
    
    func configureNavigationBar(using header: ObjectHeader, details: ObjectDetails?)
    
    func editorEditingStateDidChange(_ state: EditorEditingState)
}

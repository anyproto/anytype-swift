import UIKit
import Services

protocol EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView)
    
    func handleViewWillAppear(scrollView: UIScrollView)
    func handleViewWillDisappear()
    
    func configureNavigationBar(using header: ObjectHeader)
    func configureNavigationTitle(using details: ObjectDetails?, templatesCount: Int)
    
    func editorEditingStateDidChange(_ state: EditorEditingState)
}

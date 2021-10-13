import UIKit
import BlocksModels

protocol EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView)
    
    func handleViewWillAppear(_ vc: UIViewController?, _ scrollView: UIScrollView)
    func handleViewWillDisappear()
    
    func configureNavigationBar(using header: ObjectHeader, details: ObjectDetails?)
    
}

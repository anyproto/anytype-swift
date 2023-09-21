import Foundation
import SwiftUI

protocol ShareViewModelProtocol: AnyObject {
    func didSelectDestination(searchData: ObjectSearchData)
    
    var showingView: AnyView { get }
    
    var onSaveOptionSave: ((SharedContentSaveOption) -> Void)? { get set }
}

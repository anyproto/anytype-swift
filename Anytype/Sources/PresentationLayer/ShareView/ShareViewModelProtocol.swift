import Foundation
import SwiftUI

protocol ShareViewModelProtocol: AnyObject {
    var showingView: AnyView { get }
    var selectedSpace: SpaceView? { get set }
    var onSaveOptionSave: ((SharedContentSaveOption) -> Void)? { get set }
    
    func didSelectDestination(searchData: ObjectSearchData)
}

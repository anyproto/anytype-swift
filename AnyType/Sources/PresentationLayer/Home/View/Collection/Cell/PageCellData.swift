import Foundation
import UIKit
import Combine


struct PageCellData: Identifiable {
    let id: String
    var destinationId: String
    var icon: DocumentIcon?
    var title: String
    var type: String
    var isLoading: Bool
}

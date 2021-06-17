import Foundation
import UIKit
import Combine


struct PageCellData: Identifiable {
    let id: String
    let destinationId: String
    let icon: DocumentIcon?
    let title: String
    let type: String
    let isLoading: Bool
    let isArchived: Bool
}

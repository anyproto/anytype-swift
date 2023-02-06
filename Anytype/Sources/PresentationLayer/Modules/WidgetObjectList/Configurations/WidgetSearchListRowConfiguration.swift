import Foundation
import BlocksModels
import SwiftUI

extension ListRowConfiguration {
    
    static func widgetSearchConfiguration(objectDetails: ObjectDetails, showType: Bool, onTap: @escaping (EditorScreenData) -> Void) -> ListRowConfiguration {
        return ListRowConfiguration(
            id: objectDetails.id,
            contentHash: objectDetails.hashValue,
            viewBuilder: {
                ListWidgetRow(model: ListWidgetRow.Model(details: objectDetails, showType: showType, onTap: onTap))
                    .eraseToAnyView()
            }
        )
    }
}

import Foundation
import BlocksModels
import SwiftUI

extension ListRowConfiguration {
    
    static func widgetSearchConfiguration(objectDetails: ObjectDetails, onTap: @escaping (EditorScreenData) -> Void) -> ListRowConfiguration {
        return ListRowConfiguration(
            id: objectDetails.id,
            contentHash: objectDetails.hashValue,
            viewBuilder: {
                ListWidgetRow(model: ListWidgetRow.Model(details: objectDetails, showType: true, onTap: onTap))
                    .eraseToAnyView()
            }
        )
    }
}

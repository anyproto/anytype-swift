import Foundation
import BlocksModels
import SwiftUI

extension ListRowConfiguration {
    
    static func widgetSearchConfiguration(objectDetails: ObjectDetails, onTap: @escaping () -> Void) -> ListRowConfiguration {
        return ListRowConfiguration(
            id: objectDetails.id,
            contentHash: objectDetails.hashValue,
            viewBuilder: {
                Button {
                    onTap()
                } label: {
                    SearchCell(data: WidgetListSearchData(details: objectDetails)).eraseToAnyView()
                }.eraseToAnyView()
            }
        )
    }
}

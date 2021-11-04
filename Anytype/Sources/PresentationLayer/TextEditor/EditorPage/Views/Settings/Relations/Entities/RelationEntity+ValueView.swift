import Foundation
import SwiftUI

extension RelationEntity {
    
    var valueView: some View {
        Group {
            switch relation.format {
            case .longText:
                TextRelationView(
                    value: value?.stringValue,
                    hint: relation.format.hint
                )
            case .shortText:
                TextRelationView(
                    value: value?.stringValue,
                    hint: relation.format.hint
                )
            case .number:
                EmptyView()
            case .status:
                EmptyView()
            case .date:
                EmptyView()
            case .file:
                EmptyView()
            case .checkbox:
                EmptyView()
            case .url:
                EmptyView()
            case .email:
                EmptyView()
            case .phone:
                EmptyView()
            case .emoji:
                EmptyView()
            case .tag:
                EmptyView()
            case .object:
                EmptyView()
            case .relations:
                EmptyView()
            case .unrecognized:
                EmptyView()
            }
        }
    }
    
}


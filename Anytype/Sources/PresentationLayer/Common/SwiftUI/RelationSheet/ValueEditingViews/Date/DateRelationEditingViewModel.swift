import Foundation
import SwiftUI
import SwiftProtobuf

final class DateRelationEditingViewModel: ObservableObject {
    
    var onDismiss: () -> Void = {}

    @Published var selectedValue: DateRelationEditingValue {
        didSet {
            saveValue()
        }
    }
    
    @Published var date: Date {
        didSet {
            saveValue()
        }
    }
    
    let values = DateRelationEditingValue.allCases
    
    let relationName: String
    private let relationKey: String
    private let service: RelationsServiceProtocol
    
    init(
        relationKey: String,
        relationName: String,
        value: DateRelationValue?,
        service: RelationsServiceProtocol
    ) {
        self.selectedValue = value?.dateRelationEditingValue ?? .noDate
        self.relationKey = relationKey
        self.relationName = relationName
        self.date = value?.date ?? Date()
        self.service = service
    }
    
}

extension DateRelationEditingViewModel: RelationEditingViewModelProtocol {

    func saveValue() {
        let value: Google_Protobuf_Value = {
            switch selectedValue {
            case .noDate:
                return nil
            case .today:
                return Date().timeIntervalSince1970.protobufValue
            case .yesterday:
                return Date.yesterday.timeIntervalSince1970.protobufValue
            case .tomorrow:
                return Date.tomorrow.timeIntervalSince1970.protobufValue
            case .exactDay:
                return date.timeIntervalSince1970.protobufValue
            }
        }()
        
        service.updateRelation(relationKey: relationKey, value: value)
    }
    
    func makeView() -> AnyView {
        AnyView(DateRelationEditingView(viewModel: self))
    }
     
}

private extension DateRelationValue {
    
    var dateRelationEditingValue: DateRelationEditingValue {
        var value = DateRelationEditingValue.noDate
        
        if Calendar.current.isDateInToday(self.date) {
            value = .today
        } else if Calendar.current.isDateInTomorrow(self.date) {
            value = .tomorrow
        } else if Calendar.current.isDateInYesterday(self.date) {
            value = .yesterday
        } else {
            value = .exactDay
        }
        
        return value
    }
}

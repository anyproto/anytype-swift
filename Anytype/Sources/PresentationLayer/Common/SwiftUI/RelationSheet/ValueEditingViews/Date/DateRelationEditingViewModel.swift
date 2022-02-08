import Foundation
import SwiftUI
import SwiftProtobuf

final class DateRelationEditingViewModel: ObservableObject {
    
    var onDismiss: () -> Void = {}
    
    @Published var isPresented: Bool = false {
        didSet {
            guard isPresented == false else { return }
            
            saveValue()
        }
    }
    @Published var selectedValue: DateRelationEditingValue = .noDate
    @Published var date: Date
    
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
        self.relationKey = relationKey
        self.relationName = relationName
        self.date = value?.date ?? Date()
        self.service = service
        
        handleInitialValue(value)
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

private extension DateRelationEditingViewModel {
    
    func handleInitialValue(_ value: DateRelationValue?) {
        var selectedValue = DateRelationEditingValue.noDate
        
        guard let value = value else {
            self.selectedValue = selectedValue
            return
        }
        
        if Calendar.current.isDateInToday(value.date) {
            selectedValue = .today
        } else if Calendar.current.isDateInTomorrow(value.date) {
            selectedValue = .tomorrow
        } else if Calendar.current.isDateInYesterday(value.date) {
            selectedValue = .yesterday
        } else {
            selectedValue = .exactDay
        }
        
        self.selectedValue = selectedValue
    }
    
}

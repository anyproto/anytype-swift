import Foundation
import SwiftUI
import SwiftProtobuf

final class DateRelationEditingViewModel: ObservableObject {
    
    let values: [DateRelationEditingValue] = DateRelationEditingValue.allCases
    
    @Published var selectedValue: DateRelationEditingValue = .noDate
    @Published var date: Date
    
    private let service: DetailsServiceProtocol
    private let key: String
    
    init(
        service: DetailsServiceProtocol,
        key: String,
        value: DateRelationValue?
    ) {
        self.service = service
        self.key = key
        self.date = value?.date ?? Date()
        
        handleInitialValue(value)
    }
    
}

extension DateRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        switch selectedValue {
        case .noDate:
            service.updateDetails([DetailsUpdate(key: key, value: nil)])
        case .today:
            service.updateDetails([
                DetailsUpdate(key: key, value: Date().timeIntervalSince1970.protobufValue)
            ])
        case .yesterday:
            service.updateDetails([
                DetailsUpdate(key: key, value: Date.yesterday.timeIntervalSince1970.protobufValue)
            ])
        case .tomorrow:
            service.updateDetails([
                DetailsUpdate(key: key, value: Date.tomorrow.timeIntervalSince1970.protobufValue)
            ])
        default:
            break
        }
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

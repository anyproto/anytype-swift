import Foundation
import SwiftUI
import SwiftProtobuf
import FloatingPanel
import Combine

final class DateRelationDetailsViewModel: ObservableObject {
        
    let popupLayout = AnytypePopupLayoutType.relationOptions
    private weak var popup: AnytypePopupProxy?

    @Published var selectedValue: DateRelationDetailsValue {
        didSet {
            saveValue()
        }
    }
    
    @Published var date: Date {
        didSet {
            saveValue()
        }
    }
    
    let values = DateRelationDetailsValue.allCases
    
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    init(
        value: DateRelationValue?,
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
        self.selectedValue = value?.dateRelationEditingValue ?? .noDate
        self.date = value?.date ?? Date()
        
        self.relation = relation
        self.service = service
    }
    
    var title: String {
        relation.name
    }
    
}

extension DateRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView:  DateRelationDetailsView(viewModel: self))
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }

}

private extension DateRelationDetailsViewModel {

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
        
        service.updateRelation(relationKey: relation.id, value: value)
    }
     
}

private extension DateRelationValue {
    
    var dateRelationEditingValue: DateRelationDetailsValue {
        var value = DateRelationDetailsValue.noDate
        
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

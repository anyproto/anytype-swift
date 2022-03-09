import Foundation

final class NewSearchViewModel<Row: NewSearchRowProtocol>: ObservableObject {
    
    @Published private(set) var rows: [Row] = []
    
    func update(rows: [Row]) {
        self.rows = rows
    }
    
}

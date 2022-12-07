import Foundation

struct NewSearchCreateButtonModel {
    let show: Bool
    let title: String
    
    init(show: Bool, title: String = "") {
        self.show = show
        self.title = title
    }
}

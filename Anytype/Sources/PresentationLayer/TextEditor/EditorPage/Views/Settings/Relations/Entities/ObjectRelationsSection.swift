import Foundation

struct ObjectRelationsSection: Identifiable {
    let id = UUID()
    let title: String
    let relations: [SearchData]
}

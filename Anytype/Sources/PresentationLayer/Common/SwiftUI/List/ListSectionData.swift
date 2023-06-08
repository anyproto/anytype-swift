import Foundation

struct ListSectionData<Section, Row>: Identifiable {
    let id: String
    let data: Section
    let rows: [Row]
}

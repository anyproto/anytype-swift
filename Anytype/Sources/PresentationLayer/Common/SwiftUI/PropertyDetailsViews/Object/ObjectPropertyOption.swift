import SwiftUI
import Services
import AnytypeCore


struct ObjectPropertyOption: Equatable, Identifiable {
    let id: String
    let icon: Icon
    let title: String
    let type: String
    let isArchived: Bool
    let isDeleted: Bool
    let disableDeletion: Bool
    let disableDuplication: Bool
    
    let objectScreenData: ScreenData?
    let screenData: ScreenData?
    
    var isUnavailable: Bool {
        isArchived || isDeleted
    }
}

extension ObjectPropertyOption {
    init(objectOption: Property.Object.Option) {
        id = objectOption.id
        icon = objectOption.icon ?? .object(.defaultObjectIcon)
        title = objectOption.title
        type = objectOption.type
        isArchived = objectOption.isArchived
        isDeleted = objectOption.isDeleted
        disableDeletion = true
        disableDuplication = true
        objectScreenData = objectOption.editorScreenData
        screenData = objectOption.editorScreenData
    }

    init(objectDetails: ObjectDetails) {
        id = objectDetails.id
        icon = objectDetails.objectIconImage
        title = objectDetails.pluralTitle
        type = objectDetails.objectType.displayName
        isArchived = objectDetails.isArchived
        isDeleted = objectDetails.isDeleted
        objectScreenData = ScreenData(details: objectDetails, openMediaFileAsObject: true)
        screenData = objectDetails.screenData()
        
        let restrictions = objectDetails.restrictionsValue
        disableDeletion = restrictions.contains(.delete)
        disableDuplication = restrictions.contains(.duplicate)
    }
}


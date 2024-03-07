import Foundation

extension Container {
    var setPrefilledFieldsBuilder: Factory<SetPrefilledFieldsBuilderProtocol> {
        self { SetPrefilledFieldsBuilder() }.shared
    }
    
    var setObjectCreationHelper: Factory<SetObjectCreationHelperProtocol> {
        self { SetObjectCreationHelper() }.shared
    }
}

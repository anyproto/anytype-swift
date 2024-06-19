import Foundation

extension Container {
    var setPrefilledFieldsBuilder: Factory<SetPrefilledFieldsBuilderProtocol> {
        self { SetPrefilledFieldsBuilder() }.shared
    }
    
    var setObjectCreationHelper: Factory<SetObjectCreationHelperProtocol> {
        self { SetObjectCreationHelper() }.shared
    }
    
    var setSubscriptionDataBuilder: Factory<SetSubscriptionDataBuilderProtocol> {
        self { SetSubscriptionDataBuilder() }
    }
    
    var setGroupSubscriptionDataBuilder: Factory<SetGroupSubscriptionDataBuilderProtocol> {
        self { SetGroupSubscriptionDataBuilder() }
    }
    
    var setContentViewDataBuilder: Factory<SetContentViewDataBuilderProtocol> {
        self { SetContentViewDataBuilder() }
    }
}

import Foundation

extension Container {
    var setPrefilledFieldsBuilder: Factory<any SetPrefilledFieldsBuilderProtocol> {
        self { SetPrefilledFieldsBuilder() }.shared
    }
    
    var setObjectCreationHelper: Factory<any SetObjectCreationHelperProtocol> {
        self { SetObjectCreationHelper() }.shared
    }
    
    var setSubscriptionDataBuilder: Factory<any SetSubscriptionDataBuilderProtocol> {
        self { SetSubscriptionDataBuilder() }
    }
    
    var setGroupSubscriptionDataBuilder: Factory<any SetGroupSubscriptionDataBuilderProtocol> {
        self { SetGroupSubscriptionDataBuilder() }
    }
    
    var setContentViewDataBuilder: Factory<any SetContentViewDataBuilderProtocol> {
        self { SetContentViewDataBuilder() }
    }
}

import Foundation


enum AuthModels {
    enum CreateAccount {}
}

extension AuthModels.CreateAccount {
    
    struct Request {
        var name: String
        var avatar: ProfileModel.Avatar
    }
}

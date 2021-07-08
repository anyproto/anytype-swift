import BlocksModels
import UIKit.UIColor

extension DetailsEntryValueProvider {
    
    // MARK: - Icon
    
    var icon: DocumentIconType? {
        guard let layout = self.layout else {
            return basicIcon.flatMap { DocumentIconType.basic($0) }
        }
        
        switch layout {
        case .basic:
            return basicIcon.flatMap { DocumentIconType.basic($0) }
        case .profile:
            return profileIcon.flatMap { DocumentIconType.profile($0) }
        }
    }
    
    private var basicIcon: DocumentIconType.Basic? {
        if let iconImageId = self.iconImage, !iconImageId.isEmpty {
            return DocumentIconType.Basic.imageId(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji) {
            return DocumentIconType.Basic.emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: DocumentIconType.Profile? {
        if let iconImageId = self.iconImage, !iconImageId.isEmpty {
            return DocumentIconType.Profile.imageId(iconImageId)
        }
        
        return self.name?.first.flatMap {
            DocumentIconType.Profile.placeholder($0)
        }
    }
    
    // MARK: - Cover
    
    var documentCover: DocumentCover? {
        guard
            let coverType = coverType,
            let coverId = coverId, !coverId.isEmpty
        else { return nil }
        
        switch coverType {
        case .none:
            return nil
        case .uploadedImage:
            return DocumentCover.imageId(coverId)
        case .color:
            return CoverConstants.colors.first { $0.name == coverId }.flatMap {
                DocumentCover.color(UIColor(hexString: $0.hex))
            }
        case .gradient:
            return CoverConstants.gradients.first { $0.name == coverId }.flatMap {
                DocumentCover.gradient(
                    UIColor(hexString: $0.startHex),
                    UIColor(hexString: $0.endHex)
                )
            }
        case .bundledImage:
            return Constants.bundledImageHashMap[coverId].flatMap {
                DocumentCover.imageId($0)
            }
        }
    }
    
}

private enum Constants {
    static let bundledImageHashMap: [String: String] = [
        "crystal-pallace": "bafybeicab5x3i4zo74rnoqd7oipzb2r63ejoidsp2rrxh2xulzisee2fum",
        "the-little-pond": "bafybeifuxo5r3c5cariqjl4v374gjgrojqj4yihfsd6ihonu3zytmzgns4",
        "walk-at-pourville": "bafybeihocrbpdshvajpixukpketuplex4ckzt5l3pcksc6iqespoaugde4",
        "poppy-field": "bafybeiaq2li2tl6lgvap5wysj5r7vozfc25c4t54dkcyjwazpucwny72yq",
        "ballet": "bafybeifea6alfcpjkcytgzvkzv3vyhjarcoopzihwzojzycohgpboovwee",
        "flower-girl": "bafybeicfhibstzlvpifekhldyp7bsdma6dgwy5mrku7ledjoswocuyl3xa",
        "fruits-midi": "bafybeidl6xzxsjhgamb7t4qgjjjif7bkvtpthhewprgjoiedouqj2vgjwi",
        "autumn": "bafybeiabhvkc26qafmora5hxvxwb34feyfc6btoe3ybwlxxkyu2ymk22sm",
        "big-electric-chair": "bafybeify6z44fpduwdwgsdhf4pk5d5s5d4qguelip3jd7okgqme7tnpysy",
        "flowers": "bafybeiafdf7nbgjwxbmqwedhcmn35gcd4ejfv3yaeka6mw7vy7m2zteboa",
        "sunday-morning": "bafybeigsl5dfoj23o4r2rtw43sl4kvhijpkq77qjmgvc2io6qg7nrjjbgu",
        "japan": "bafybeifowedv7fme7ugjnj6vnqrmf4uz4wudt5l55gee5igqxemhg4xrh4",
        "grass": "bafybeiginsg5gc7qosdrhkpeobtosbkpmyg6j7mdgomcy567mfpbnbpbpa",
        "butter": "bafybeihbzr7knybfztkxhpbwezv3lx44h5issibjz77m5fbuy3tku5rkby",
        "medication": "bafybeiauvmphta2ujtjll3vv7uc2aunzir2vkrlb4d3ais5bmcnzi4w25u",
        "landscape3": "bafybeidf2fwr4pmoldksbify2n36ufd4e6po4nt664rnidw5jl2k3nuzqi",
        "third-sleep": "bafybeiaq23nrbztctw36xtayerd6qheoi2ae2x2nods3ksosgfizbrzxqq",
        "banquet": "bafybeiamsdjmdbdrwdswmkhy4fuavoi7agvdelp2wrafq3q23gn3lnrnoi",
        "chemist": "bafybeihqthprdduwgxmeyejstjhzoem3u257msinqbeqt3jgbjwylpoese"
    ]
}

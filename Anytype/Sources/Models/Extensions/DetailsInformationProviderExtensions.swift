import BlocksModels
import UIKit.UIColor

extension DetailsEntryValueProvider {
    
    var documentIcon: DocumentIcon? {
        if let iconImageId = self.iconImage, !iconImageId.isEmpty {
            return DocumentIcon.imageId(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji) {
            return DocumentIcon.emoji(iconEmoji)
        }
        
        return nil
    }
    
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
            return Constants.colorHexMap[coverId].flatMap {
                DocumentCover.color(UIColor(hexString: $0))
            }
        case .gradient:
            return Constants.gradientColorsMap[coverId].flatMap { gradien in
                DocumentCover.gradient(
                    UIColor(hexString: gradien.startHex),
                    UIColor(hexString: gradien.endHex)
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
    
    static let colorHexMap: [String: String] = [
        "yellow": "#FBE885",
        "orange": "#F5B748",
        "red": "#E46036",
        "pink": "#E6B1A4",
        "purple": "#611A36",
        "blue": "#376BE1",
        "ice": "#97CCEF",
        "teal": "#9FB0B6",
        "green": "#336C45",
        "lightgrey": "#DFDDD1",
        "darkgrey": "#ACA998",
        "black": "#2C2B28"
    ]
    
    static let gradientColorsMap: [String: (startHex: String, endHex: String)] = [
        "yellow": ("#ffb522", "#ecd91b"),
        "red": ("#f55522", "#e51ca0"),
        "blue": ("#ab50cc", "#3e58eb"),
        "teal": ("#2aa7ee", "#0fc8ba")
    ]
}

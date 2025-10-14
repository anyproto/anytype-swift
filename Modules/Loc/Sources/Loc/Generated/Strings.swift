// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Loc {
  public static func agreementDisclamer(_ p1: Any, _ p2: Any) -> String {
    return Loc.tr("Auth", "Agreement Disclamer", String(describing: p1), String(describing: p2), fallback: "By continuing you agree to [Terms of Use](%@) and [Privacy Policy](%@)")
  }
  public static let loginKey = Loc.tr("Auth", "Login key", fallback: "Login Key")
  public enum AnyApp {
    public enum BetaAlert {
      public static let description = Loc.tr("Auth", "AnyApp.BetaAlert.Description", fallback: "You’re ahead of the curve! Some features are still in development or not production-ready – stay tuned for updates.")
      public static let title = Loc.tr("Auth", "AnyApp.BetaAlert.Title", fallback: "Welcome to the Alpha version")
    }
  }
  public enum Auth {
    public static let cameraPermissionTitle = Loc.tr("Auth", "Auth.CameraPermissionTitle", fallback: "Please allow access")
    public static let logIn = Loc.tr("Auth", "Auth.LogIn", fallback: "I already have a key")
    public static let next = Loc.tr("Auth", "Auth.Next", fallback: "Next")
    public enum Button {
      public static let join = Loc.tr("Auth", "Auth.Button.Join", fallback: "I am new here")
    }
    public enum JoinFlow {
      public enum Email {
        public static let description = Loc.tr("Auth", "Auth.JoinFlow.Email.description", fallback: "We’d love to share tips, tricks and product updates with you. Your email is never linked to your identity. We won’t share your data. Ever.")
        public static let incorrectError = Loc.tr("Auth", "Auth.JoinFlow.Email.incorrectError", fallback: "Incorrect email")
        public static let placeholder = Loc.tr("Auth", "Auth.JoinFlow.Email.placeholder", fallback: "Enter your email")
        public static let title = Loc.tr("Auth", "Auth.JoinFlow.Email.title", fallback: "Stay in the loop")
      }
      public enum Key {
        public static let description = Loc.tr("Auth", "Auth.JoinFlow.Key.Description", fallback: "It replaces login and password. Keep it safe — you control your data. You can find this Key later in app settings.")
        public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.Title", fallback: "This is your Key")
        public enum Button {
          public enum Copy {
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.Button.Copy.Title", fallback: "Copy to clipboard")
          }
          public enum Info {
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.Button.Info.Title", fallback: "Read more")
          }
          public enum Later {
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.Button.Later.Title", fallback: "Not now")
          }
          public enum Saved {
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.Button.Saved.Title", fallback: "Next")
          }
          public enum Show {
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.Button.Show.Title", fallback: "Reveal and copy")
          }
        }
        public enum ReadMore {
          public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Title", fallback: "How the Key works?")
          public enum Option1 {
            public static let description = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Option1.description", fallback: "Your key is represented by a recovery phrase — 12 random words that generate your vault on this device.")
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Option1.title", fallback: "It’s your login and password")
          }
          public enum Option2 {
            public static let description = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Option2.description", fallback: "Anyone who knows these words can access your vault. Right now, you are the only person in the world who knows them.")
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Option2.title", fallback: "Whoever has the key, has access")
          }
          public enum Option3 {
            public static let description = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Option3.description", fallback: "All computational resources on Earth are not enough to break in. If you lose your key, it cannot be recovered. Store it somewhere safe — in a password manager or written down on paper.")
            public static let title = Loc.tr("Auth", "Auth.JoinFlow.Key.ReadMore.Option3.title", fallback: "Only you responsible for it")
          }
        }
      }
      public enum PersonaInfo {
        public static let description = Loc.tr("Auth", "Auth.JoinFlow.PersonaInfo.description", fallback: "Select one role or background that best fits you")
        public static let title = Loc.tr("Auth", "Auth.JoinFlow.PersonaInfo.title", fallback: "Tell Us About Yourself")
      }
      public enum SelectionOption {
        public enum Persona {
          public static let artist = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.artist", fallback: "Artist / Content Creator")
          public static let consultant = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.consultant", fallback: "Consultant")
          public static let designer = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.designer", fallback: "Designer")
          public static let developer = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.developer", fallback: "Software Developer")
          public static let entrepreneur = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.entrepreneur", fallback: "Founder / Entrepreneur")
          public static let manager = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.manager", fallback: "Manager / IT Professional")
          public static let marketer = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.marketer", fallback: "Marketer")
          public static let researcher = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.researcher", fallback: "Researcher / Academic")
          public static let student = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.student", fallback: "Student")
          public static let writer = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.Persona.writer", fallback: "Writer / Journalist")
        }
        public enum UseCase {
          public static let habitTracking = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.habitTracking", fallback: "Habit tracking")
          public static let knowledge = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.knowledge", fallback: "Personal knowledge base / PKM")
          public static let lifePlanning = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.lifePlanning", fallback: "Life planning")
          public static let messaging = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.messaging", fallback: "Messaging & group chats")
          public static let notes = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.notes", fallback: "Personal note-taking")
          public static let projects = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.projects", fallback: "Projects & tasks management")
          public static let teamWork = Loc.tr("Auth", "Auth.JoinFlow.SelectionOption.UseCase.teamWork", fallback: "Team work & shared docs")
        }
      }
      public enum Soul {
        public static let button = Loc.tr("Auth", "Auth.JoinFlow.Soul.Button", fallback: "Done")
        public static let description = Loc.tr("Auth", "Auth.JoinFlow.Soul.Description", fallback: "Only seen by people you share something with. There is no central registry of these names.")
        public static let title = Loc.tr("Auth", "Auth.JoinFlow.Soul.Title", fallback: "Add Your Name")
      }
      public enum UseCaseInfo {
        public static let description = Loc.tr("Auth", "Auth.JoinFlow.UseCaseInfo.description", fallback: "Pick one use case that fits you best")
        public static let title = Loc.tr("Auth", "Auth.JoinFlow.UseCaseInfo.title", fallback: "What do you want to use Anytype for?")
      }
    }
    public enum Login {
      public enum Or {
        public static let title = Loc.tr("Auth", "Auth.Login.Or.title", fallback: "or enter with")
      }
    }
    public enum LoginFlow {
      public static let or = Loc.tr("Auth", "Auth.LoginFlow.Or", fallback: "OR")
      public enum Enter {
        public static let title = Loc.tr("Auth", "Auth.LoginFlow.Enter.Title", fallback: "Enter my Vault")
      }
      public enum Entering {
        public enum Void {
          public static let title = Loc.tr("Auth", "Auth.LoginFlow.Entering.Void.Title", fallback: "Entering the Void")
        }
      }
      public enum Textfield {
        public static let placeholder = Loc.tr("Auth", "Auth.LoginFlow.Textfield.Placeholder", fallback: "Enter your key")
      }
      public enum Use {
        public enum Keychain {
          public static let title = Loc.tr("Auth", "Auth.LoginFlow.Use.Keychain.Title", fallback: "Use keychain")
        }
      }
    }
    public enum Primary {
      public enum Greeting {
        public static let pt1 = Loc.tr("Auth", "Auth.Primary.Greeting.pt1", fallback: "Encrypted, local,")
        public static let pt2 = Loc.tr("Auth", "Auth.Primary.Greeting.pt2", fallback: "yours forever")
      }
    }
  }
  public enum Initial {
    public enum UnstableMiddle {
      public static let `continue` = Loc.tr("Auth", "Initial.UnstableMiddle.Continue", fallback: "Continue with current vault")
      public static let logout = Loc.tr("Auth", "Initial.UnstableMiddle.Logout", fallback: "Logout from current vault")
      public static let message = Loc.tr("Auth", "Initial.UnstableMiddle.Message", fallback: "You launch app with a unstable middleware. Don't use your production vault. Your vault may be broken.")
      public static let title = Loc.tr("Auth", "Initial.UnstableMiddle.Title", fallback: "Warning")
      public static let wontUseProd = Loc.tr("Auth", "Initial.UnstableMiddle.WontUseProd", fallback: "I won't be using my production vault")
    }
  }
  public enum Keychain {
    public static let haveYouBackedUpYourKey = Loc.tr("Auth", "Keychain.Have you backed up your key?", fallback: "Have you backed up your key?")
    public static let key = Loc.tr("Auth", "Keychain.Key", fallback: "Key")
    public static let seedPhrasePlaceholder = Loc.tr("Auth", "Keychain.SeedPhrasePlaceholder", fallback: "witch collapse practice feed shame open despair creek road again ice least lake tree young address brain despair")
    public static let showAndCopyKey = Loc.tr("Auth", "Keychain.Show and copy key", fallback: "Show and copy key")
    public enum Error {
      public static let dataToStringConversionError = Loc.tr("Auth", "Keychain.Error.Data to String conversion error", fallback: "Data to String conversion error")
      public static let stringToDataConversionError = Loc.tr("Auth", "Keychain.Error.String to Data conversion error", fallback: "String to Data conversion error")
      public static let unknownKeychainError = Loc.tr("Auth", "Keychain.Error.Unknown Keychain Error", fallback: "Unknown Keychain Error")
    }
    public enum Key {
      public static let description = Loc.tr("Auth", "Keychain.Key.description", fallback: "You will need it to enter your vault. Keep it in a safe place. If you lose it, you can no longer enter your vault.")
      public enum Copy {
        public enum Toast {
          public static let title = Loc.tr("Auth", "Keychain.Key.Copy.Toast.title", fallback: "Key copied")
        }
      }
    }
  }
  public enum Migration {
    public enum Error {
      public enum NotEnoughtSpace {
        public static func message(_ p1: Any) -> String {
          return Loc.tr("Auth", "Migration.Error.NotEnoughtSpace.message", String(describing: p1), fallback: "Please clear approximately %@ of space and run the process again.")
        }
        public static let title = Loc.tr("Auth", "Migration.Error.NotEnoughtSpace.title", fallback: "Not enough space")
      }
    }
    public enum Initial {
      public static let readMore = Loc.tr("Auth", "Migration.Initial.readMore", fallback: "Read More")
      public static let startUpdate = Loc.tr("Auth", "Migration.Initial.startUpdate", fallback: "Start Update")
      public static let subtitle = Loc.tr("Auth", "Migration.Initial.subtitle", fallback: "We're laying the groundwork for our new chats. Including counters, notifications and other features needed for smooth chat experience. It might take a little while, but don't worry, your data is safe.")
      public static let title = Loc.tr("Auth", "Migration.Initial.title", fallback: "New Version Update")
    }
    public enum Progress {
      public static let subtitle = Loc.tr("Auth", "Migration.Progress.subtitle", fallback: "This may take some time. Please don’t close the app until the process is complete.")
      public static let title = Loc.tr("Auth", "Migration.Progress.title", fallback: "Update is in progress...")
    }
    public enum ReadMore {
      public static let description1 = Loc.tr("Auth", "Migration.ReadMore.description1", fallback: "You'll see a loading screen during the update. Once finished, you can continue using the app normally.")
      public static let description2 = Loc.tr("Auth", "Migration.ReadMore.description2", fallback: "During this update, your data remains fully secure. The update is performed directly on your device, and your synced data remains unaffected. We’ll just copy it to a new format, and a local backup will be created on your device, containing all your data in the previous format.")
      public static let description3 = Loc.tr("Auth", "Migration.ReadMore.description3", fallback: "The reason we’re retaining this backup is to debug and assist you, in case of unforeseen.")
      public static let option1 = Loc.tr("Auth", "Migration.ReadMore.option1", fallback: "What to Expect")
      public static let option2 = Loc.tr("Auth", "Migration.ReadMore.option2", fallback: "Your Data Remains Safe")
    }
  }
  public enum Vault {
    public enum Select {
      public enum Incompatible {
        public enum Version {
          public enum Error {
            public static let text = Loc.tr("Auth", "Vault.Select.Incompatible.Version.Error.Text", fallback: "We were unable to retrieve your vault data because your version is out-of-date. Please update Anytype to the latest version.")
          }
        }
      }
    }
  }
  public static let about = Loc.tr("UI", "About", fallback: "About")
  public static let access = Loc.tr("UI", "Access", fallback: "Key")
  public static let accessToKeyFromKeychain = Loc.tr("UI", "Access to key from keychain", fallback: "Access to key from keychain")
  public static let actionFocusedLayoutWithACheckbox = Loc.tr("UI", "Action-focused layout with a checkbox", fallback: "Action-focused layout with a checkbox")
  public static let actions = Loc.tr("UI", "Actions", fallback: "Actions")
  public static let add = Loc.tr("UI", "Add", fallback: "Add")
  public static let addADescription = Loc.tr("UI", "Add a description", fallback: "Add a description...")
  public static let addBelow = Loc.tr("UI", "Add below", fallback: "Add below")
  public static let addEmail = Loc.tr("UI", "Add email", fallback: "Add email")
  public static let addLink = Loc.tr("UI", "Add link", fallback: "Add link")
  public static let addPhone = Loc.tr("UI", "Add phone", fallback: "Add phone")
  public static let addProperty = Loc.tr("UI", "Add property", fallback: "Add property")
  public static let alignCenter = Loc.tr("UI", "Align center", fallback: "Align center")
  public static let alignJustify = Loc.tr("UI", "Align justify", fallback: "Align justify")
  public static let alignLeft = Loc.tr("UI", "Align left", fallback: "Align left")
  public static let alignRight = Loc.tr("UI", "Align right", fallback: "Align right")
  public static let alignment = Loc.tr("UI", "Alignment", fallback: "Alignment")
  public static let all = Loc.tr("UI", "All", fallback: "All")
  public static let allObjects = Loc.tr("UI", "All objects", fallback: "All Objects")
  public static let amber = Loc.tr("UI", "Amber", fallback: "Amber")
  public static let amberBackground = Loc.tr("UI", "Amber background", fallback: "Amber background")
  public static let anytypeLibrary = Loc.tr("UI", "Anytype Library", fallback: "Anytype Library")
  public static let anytypeNetwork = Loc.tr("UI", "Anytype Network", fallback: "Anytype Network")
  public static let appearance = Loc.tr("UI", "Appearance", fallback: "Appearance")
  public static let application = Loc.tr("UI", "Application", fallback: "Application")
  public static let applicationIcon = Loc.tr("UI", "Application icon", fallback: "Application icon")
  public static let apply = Loc.tr("UI", "Apply", fallback: "Apply")
  public static func areYouSureYouWantToDelete(_ p1: Int) -> String {
    return Loc.tr("UI", "Are you sure you want to delete", p1, fallback: "Are you sure you want to delete %#@object@?")
  }
  public static let areYouSure = Loc.tr("UI", "AreYouSure", fallback: "Are you sure?")
  public static let attachObject = Loc.tr("UI", "Attach Object", fallback: "Attach Object")
  public static func attachment(_ p1: Int) -> String {
    return Loc.tr("UI", "Attachment", p1, fallback: "Plural format key: Attachment")
  }
  public static func audio(_ p1: Int) -> String {
    return Loc.tr("UI", "Audio", p1, fallback: "Plural format key: Audio")
  }
  public static let back = Loc.tr("UI", "Back", fallback: "Back")
  public static let backUpKey = Loc.tr("UI", "Back up key", fallback: "Back up key")
  public static let background = Loc.tr("UI", "Background", fallback: "Background")
  public static func backlinksCount(_ p1: Int) -> String {
    return Loc.tr("UI", "Backlinks count", p1, fallback: "Plural format key: Backlinks count")
  }
  public static let basic = Loc.tr("UI", "Basic", fallback: "Basic")
  public static let bin = Loc.tr("UI", "Bin", fallback: "Bin")
  public static let black = Loc.tr("UI", "Black", fallback: "Black")
  public static let blue = Loc.tr("UI", "Blue", fallback: "Blue")
  public static let blueBackground = Loc.tr("UI", "Blue background", fallback: "Blue background")
  public static let blurredIcon = Loc.tr("UI", "Blurred icon", fallback: "Blurred\n icon")
  public static func bookmark(_ p1: Int) -> String {
    return Loc.tr("UI", "Bookmark", p1, fallback: "Plural format key: Bookmark")
  }
  public static let bookmarks = Loc.tr("UI", "Bookmarks", fallback: "Bookmarks")
  public static let callout = Loc.tr("UI", "Callout", fallback: "Callout")
  public static let camera = Loc.tr("UI", "Camera", fallback: "Camera")
  public static let cameraBlockTitle = Loc.tr("UI", "Camera block title", fallback: "Take photo or video")
  public static let cancel = Loc.tr("UI", "Cancel", fallback: "Cancel")
  public static let cancelDeletion = Loc.tr("UI", "Cancel deletion", fallback: "Cancel deletion")
  public static let changeCover = Loc.tr("UI", "Change cover", fallback: "Change cover")
  public static let changeEmail = Loc.tr("UI", "Change email", fallback: "Change email")
  public static let changeIcon = Loc.tr("UI", "Change icon", fallback: "Change icon")
  public static let changeType = Loc.tr("UI", "Change type", fallback: "Change type")
  public static let changeWallpaper = Loc.tr("UI", "Change wallpaper", fallback: "Change wallpaper")
  public static let channelType = Loc.tr("UI", "ChannelType", fallback: "Channel Type")
  public static let chat = Loc.tr("UI", "Chat", fallback: "Chat")
  public static let chooseDefaultObjectType = Loc.tr("UI", "Choose default object type", fallback: "Choose default object type")
  public static let chooseLayoutType = Loc.tr("UI", "Choose layout type", fallback: "Choose layout type")
  public static let clear = Loc.tr("UI", "Clear", fallback: "Clear")
  public static let close = Loc.tr("UI", "Close", fallback: "Close")
  public static let codeSnippet = Loc.tr("UI", "Code snippet", fallback: "Code snippet")
  public static let collection = Loc.tr("UI", "Collection", fallback: "Collection")
  public static let collectionOfObjects = Loc.tr("UI", "Collection of objects", fallback: "Collection of objects")
  public static let collections = Loc.tr("UI", "Collections", fallback: "Collections")
  public static let color = Loc.tr("UI", "Color", fallback: "Color")
  public static let companiesContactsFriendsAndFamily = Loc.tr("UI", "Companies, contacts, friends and family", fallback: "Companies, contacts, friends and family")
  public static let confirm = Loc.tr("UI", "Confirm", fallback: "Confirm")
  public static let connecting = Loc.tr("UI", "Connecting", fallback: "Connecting...")
  public static let contentModel = Loc.tr("UI", "Content Model", fallback: "Content Model")
  public static let `continue` = Loc.tr("UI", "Continue", fallback: "Continue")
  public static let copied = Loc.tr("UI", "Copied", fallback: "Copied")
  public static func copiedToClipboard(_ p1: Any) -> String {
    return Loc.tr("UI", "copied to clipboard", String(describing: p1), fallback: "%@ copied to clipboard")
  }
  public static let copy = Loc.tr("UI", "Copy", fallback: "Copy")
  public static let copyLink = Loc.tr("UI", "Copy link", fallback: "Copy link")
  public static let copySpaceInfo = Loc.tr("UI", "Copy space info", fallback: "Copy space info")
  public static let cover = Loc.tr("UI", "Cover", fallback: "Cover")
  public static let create = Loc.tr("UI", "Create", fallback: "Create")
  public static let createANewOneOrSearchForSomethingElse = Loc.tr("UI", "Create a new one or search for something else", fallback: "Create a new one or search for something else")
  public static let createNewObject = Loc.tr("UI", "Create new object", fallback: "Create new object")
  public static func createNewObjectWithName(_ p1: Any) -> String {
    return Loc.tr("UI", "Create new object with name", String(describing: p1), fallback: "Create new object \"%@\"")
  }
  public static let createNewType = Loc.tr("UI", "Create new type", fallback: "Create new type")
  public static let createObject = Loc.tr("UI", "Create object", fallback: "Create Object")
  public static let createObjectFromClipboard = Loc.tr("UI", "Create object from clipboard", fallback: "Create object from clipboard")
  public static func createOptionWith(_ p1: Any) -> String {
    return Loc.tr("UI", "Create option with", String(describing: p1), fallback: "Create option ‘%@’")
  }
  public static func createRelation(_ p1: Any) -> String {
    return Loc.tr("UI", "Create relation", String(describing: p1), fallback: "Create property ‘%@’")
  }
  public static let createSet = Loc.tr("UI", "Create Set", fallback: "Create Query")
  public static let createSpace = Loc.tr("UI", "Create Space", fallback: "Create Space")
  public static let createType = Loc.tr("UI", "Create type", fallback: "Create type")
  public static let current = Loc.tr("UI", "Current", fallback: "Current")
  public static let customizeURL = Loc.tr("UI", "Customize URL", fallback: "Customize URL")
  public static func date(_ p1: Int) -> String {
    return Loc.tr("UI", "Date", p1, fallback: "Plural format key: Date")
  }
  public static let dates = Loc.tr("UI", "Dates", fallback: "Dates")
  public static func daysToDeletionVault(_ p1: Int) -> String {
    return Loc.tr("UI", "Days to deletion vault", p1, fallback: "This vault will be deleted %#@days@")
  }
  public static let defaultBackground = Loc.tr("UI", "Default background", fallback: "Default background")
  public static let defaultObjectType = Loc.tr("UI", "Default object type", fallback: "Default object type")
  public static let delete = Loc.tr("UI", "Delete", fallback: "Delete")
  public static let deleteVault = Loc.tr("UI", "Delete vault", fallback: "Delete vault")
  public static let deleted = Loc.tr("UI", "Deleted", fallback: "Deleted")
  public static let deleteObjectType = Loc.tr("UI", "DeleteObjectType", fallback: "Delete Object Type")
  public static let deletionError = Loc.tr("UI", "Deletion error", fallback: "Deletion error")
  public static let description = Loc.tr("UI", "Description", fallback: "Description")
  public static let deselect = Loc.tr("UI", "Deselect", fallback: "Deselect")
  public static let deselectAll = Loc.tr("UI", "Deselect all", fallback: "Deselect all")
  public static let designedToCaptureThoughtsQuickly = Loc.tr("UI", "Designed to capture thoughts quickly", fallback: "Designed to capture thoughts quickly")
  public static func devicesConnected(_ p1: Int) -> String {
    return Loc.tr("UI", "Devices connected", p1, fallback: "%#@device@ connected")
  }
  public static let disabled = Loc.tr("UI", "Disabled", fallback: "Disabled")
  public static let documentScanFailed = Loc.tr("UI", "Document scan failed", fallback: "Document scan failed")
  public static let done = Loc.tr("UI", "Done", fallback: "Done")
  public static let download = Loc.tr("UI", "Download", fallback: "Download")
  public static let downloadingOrUploadingDataToSomeNode = Loc.tr("UI", "Downloading or uploading data to some node", fallback: "Downloading or uploading data to some node")
  public static let duplicate = Loc.tr("UI", "Duplicate", fallback: "Duplicate")
  public static let eMail = Loc.tr("UI", "E-mail", fallback: "E-mail")
  public static let edit = Loc.tr("UI", "Edit", fallback: "Edit")
  public static let editField = Loc.tr("UI", "Edit field", fallback: "Edit property")
  public static let editProfile = Loc.tr("UI", "Edit Profile", fallback: "Edit Profile")
  public static let editType = Loc.tr("UI", "Edit type", fallback: "Edit type")
  public static let egProject = Loc.tr("UI", "egProject", fallback: "e.g. Project")
  public static let egProjects = Loc.tr("UI", "egProjects", fallback: "e.g. Projects")
  public static let emailSuccessfullyValidated = Loc.tr("UI", "Email successfully validated", fallback: "Email successfully validated")
  public static let emoji = Loc.tr("UI", "Emoji", fallback: "Emoji")
  public static let empty = Loc.tr("UI", "Empty", fallback: "Empty")
  public static let enabled = Loc.tr("UI", "Enabled", fallback: "Enabled")
  public static let enter = Loc.tr("UI", "Enter", fallback: "Enter")
  public static let enterEmail = Loc.tr("UI", "Enter email", fallback: "Enter email")
  public static let enterNumber = Loc.tr("UI", "Enter number", fallback: "Enter number")
  public static let enterPhoneNumber = Loc.tr("UI", "Enter phone number", fallback: "Enter phone number")
  public static let enterText = Loc.tr("UI", "Enter text", fallback: "Enter text")
  public static let enterURL = Loc.tr("UI", "Enter URL", fallback: "Enter URL")
  public static let enterValue = Loc.tr("UI", "Enter value", fallback: "Enter value")
  public static let error = Loc.tr("UI", "Error", fallback: "Error")
  public static let errorCreatingWallet = Loc.tr("UI", "Error creating wallet", fallback: "Error creating wallet")
  public static let errorSelectVault = Loc.tr("UI", "Error select vault", fallback: "Error select vault")
  public static let errorWalletRecoverVault = Loc.tr("UI", "Error wallet recover vault", fallback: "Error wallet recover vault")
  public static let everywhere = Loc.tr("UI", "Everywhere", fallback: "Everywhere")
  public static let exactDay = Loc.tr("UI", "Exact day", fallback: "Exact day")
  public static let existingProperties = Loc.tr("UI", "Existing properties", fallback: "Existing properties")
  public static let experimentalFeatures = Loc.tr("UI", "Experimental Features", fallback: "Experimental Features")
  public static let export = Loc.tr("UI", "Export", fallback: "Export")
  public static let failedToSyncTryingAgain = Loc.tr("UI", "Failed to sync, trying again...", fallback: "Failed to sync, trying again...")
  public static let featuredRelations = Loc.tr("UI", "Featured relations", fallback: "Featured properties")
  public static let fields = Loc.tr("UI", "Fields", fallback: "Properties")
  public static func file(_ p1: Int) -> String {
    return Loc.tr("UI", "File", p1, fallback: "Plural format key: File")
  }
  public static let files = Loc.tr("UI", "Files", fallback: "Files")
  public static let filter = Loc.tr("UI", "Filter", fallback: "Filter")
  public static let forever = Loc.tr("UI", "Forever", fallback: "Forever")
  public static let foreverFree = Loc.tr("UI", "Forever free", fallback: "Forever free")
  public static let format = Loc.tr("UI", "Format", fallback: "Format")
  public static let gallery = Loc.tr("UI", "Gallery", fallback: "Gallery")
  public static let goBack = Loc.tr("UI", "Go back", fallback: "Go back")
  public static let gotIt = Loc.tr("UI", "Got it", fallback: "I got it!")
  public static let gradients = Loc.tr("UI", "Gradients", fallback: "Gradients")
  public static let green = Loc.tr("UI", "Green", fallback: "Green")
  public static let greenBackground = Loc.tr("UI", "Green background", fallback: "Green background")
  public static let grey = Loc.tr("UI", "Grey", fallback: "Grey")
  public static let greyBackground = Loc.tr("UI", "Grey background", fallback: "Grey background")
  public static let header = Loc.tr("UI", "Header", fallback: "Header")
  public static let hidden = Loc.tr("UI", "Hidden", fallback: "Hidden")
  public static let hide = Loc.tr("UI", "Hide", fallback: "Hide")
  public static let hideTypes = Loc.tr("UI", "Hide types", fallback: "Hide types")
  public static let highlight = Loc.tr("UI", "Highlight", fallback: "Highlight")
  public static let history = Loc.tr("UI", "History", fallback: "History")
  public static let home = Loc.tr("UI", "Home", fallback: "Home")
  public static let icon = Loc.tr("UI", "Icon", fallback: "Icon")
  public static func image(_ p1: Int) -> String {
    return Loc.tr("UI", "Image", p1, fallback: "Plural format key: Image")
  }
  public static let imageFromPhotoLibrary = Loc.tr("UI", "Image from Photo Library", fallback: "Image from Photo Library")
  public static let inThisObject = Loc.tr("UI", "In this object", fallback: "In this object")
  public static let incompatibleVersion = Loc.tr("UI", "Incompatible version", fallback: "Incompatible version")
  public static let initializingSync = Loc.tr("UI", "Initializing sync", fallback: "Initializing sync")
  public static let intoObject = Loc.tr("UI", "Into object", fallback: "Into object")
  public static func itemsSyncing(_ p1: Int) -> String {
    return Loc.tr("UI", "Items syncing", p1, fallback: "%#@item@ syncing...")
  }
  public static let join = Loc.tr("UI", "Join", fallback: "Join")
  public static let justEMail = Loc.tr("UI", "Just e-mail", fallback: "Just e-mail")
  public static let keychain = Loc.tr("UI", "Keychain", fallback: "Keychain")
  public static let layout = Loc.tr("UI", "Layout", fallback: "Layout")
  public static let learnMore = Loc.tr("UI", "Learn more", fallback: "Learn more")
  public static let leaveASpace = Loc.tr("UI", "Leave a space", fallback: "Leave a space")
  public static let letsGo = Loc.tr("UI", "Lets Go", fallback: "Let’s Go")
  public static let letsTryIt = Loc.tr("UI", "LetsTryIt", fallback: "Let's try it")
  public static let limitObjectTypes = Loc.tr("UI", "Limit object types", fallback: "Limit object types")
  public static let link = Loc.tr("UI", "Link", fallback: "Link")
  public static let linkTo = Loc.tr("UI", "Link to", fallback: "Link to")
  public static func linksCount(_ p1: Int) -> String {
    return Loc.tr("UI", "Links count", p1, fallback: "Plural format key: Links count")
  }
  public static func list(_ p1: Int) -> String {
    return Loc.tr("UI", "List", p1, fallback: "Plural format key: List")
  }
  public static let lists = Loc.tr("UI", "Lists", fallback: "Lists")
  public static let loadingPleaseWait = Loc.tr("UI", "Loading, please wait", fallback: "Loading, please wait")
  public static let localOnly = Loc.tr("UI", "Local Only", fallback: "Local Only")
  public static let lock = Loc.tr("UI", "Lock", fallback: "Lock")
  public static let logOut = Loc.tr("UI", "Log out", fallback: "Log Out")
  public static let logoutAndClearData = Loc.tr("UI", "Logout and clear data", fallback: "Logout and clear data")
  public static let managePayment = Loc.tr("UI", "Manage payment", fallback: "Manage payment")
  public static let media = Loc.tr("UI", "Media", fallback: "Media")
  public static func membersPlural(_ p1: Int) -> String {
    return Loc.tr("UI", "membersPlural", p1, fallback: "Plural format key: membersPlural")
  }
  public static let mentions = Loc.tr("UI", "Mentions", fallback: "Mentions")
  public static func minXCharacters(_ p1: Any) -> String {
    return Loc.tr("UI", "Min X characters", String(describing: p1), fallback: "Min %@ characters")
  }
  public static let misc = Loc.tr("UI", "Misc", fallback: "Misc")
  public static let mode = Loc.tr("UI", "Mode", fallback: "Mode")
  public static let more = Loc.tr("UI", "More", fallback: "More")
  public static let moreInfo = Loc.tr("UI", "MoreInfo", fallback: "More info")
  public static let move = Loc.tr("UI", "Move", fallback: "Move")
  public static let moveTo = Loc.tr("UI", "Move to", fallback: "Move to")
  public static let moveToBin = Loc.tr("UI", "Move To Bin", fallback: "Move To Bin")
  public static let mute = Loc.tr("UI", "Mute", fallback: "Mute")
  public static let myFirstSpace = Loc.tr("UI", "My First Space", fallback: "My First Space")
  public static let myProperties = Loc.tr("UI", "My Properties", fallback: "My Properties")
  public static let mySites = Loc.tr("UI", "My Sites", fallback: "My Sites")
  public static let mySpaces = Loc.tr("UI", "My spaces", fallback: "My Spaces")
  public static let myself = Loc.tr("UI", "Myself", fallback: "Myself")
  public static let name = Loc.tr("UI", "Name", fallback: "Name")
  public static let new = Loc.tr("UI", "New", fallback: "New")
  public static let newField = Loc.tr("UI", "New field", fallback: "New property")
  public static let newPage = Loc.tr("UI", "New Page", fallback: "New Page")
  public static let newSet = Loc.tr("UI", "New set", fallback: "New query")
  public static let newObject = Loc.tr("UI", "NewObject", fallback: "New Object")
  public static let next = Loc.tr("UI", "Next", fallback: "Next")
  public static let noConnection = Loc.tr("UI", "No connection", fallback: "No connection")
  public static let noDate = Loc.tr("UI", "No date", fallback: "No date")
  public static let noItemsMatchFilter = Loc.tr("UI", "No items match filter", fallback: "No items match filter")
  public static let noMatchesFound = Loc.tr("UI", "No matches found", fallback: "No matches found.\nTry a different keyword or check your spelling.")
  public static let noPropertiesYet = Loc.tr("UI", "No properties yet", fallback: "No properties yet. Add some to this type.")
  public static let noRelatedOptionsHere = Loc.tr("UI", "No related options here", fallback: "No related options here. You can add some")
  public static func noTypeFoundText(_ p1: Any) -> String {
    return Loc.tr("UI", "No type found text", String(describing: p1), fallback: "No type “%@” found. Change your request or create new type.")
  }
  public static let nonExistentObject = Loc.tr("UI", "Non-existent object", fallback: "Non-existent object")
  public static let `none` = Loc.tr("UI", "None", fallback: "None")
  public static let nothingFound = Loc.tr("UI", "Nothing found", fallback: "Nothing found")
  public static let nothingToRedo = Loc.tr("UI", "Nothing to redo", fallback: "Nothing to redo")
  public static let nothingToUndo = Loc.tr("UI", "Nothing to undo", fallback: "Nothing to undo")
  public static func object(_ p1: Int) -> String {
    return Loc.tr("UI", "Object", p1, fallback: "Plural format key: Object")
  }
  public static func objectSelected(_ p1: Int) -> String {
    return Loc.tr("UI", "Object selected", p1, fallback: "%#@object@ selected")
  }
  public static func objectType(_ p1: Int) -> String {
    return Loc.tr("UI", "Object type", p1, fallback: "Plural format key: Object type")
  }
  public static let objectTypes = Loc.tr("UI", "Object Types", fallback: "Object Types")
  public static let objects = Loc.tr("UI", "Objects", fallback: "Objects")
  public static let ok = Loc.tr("UI", "Ok", fallback: "Ok")
  public static let okay = Loc.tr("UI", "Okay", fallback: "Okay")
  public static let onAnalytics = Loc.tr("UI", "On analytics", fallback: "On analytics")
  public static let `open` = Loc.tr("UI", "Open", fallback: "Open")
  public static let openAsObject = Loc.tr("UI", "Open as Object", fallback: "Open as Object")
  public static let openFile = Loc.tr("UI", "Open file", fallback: "Open file")
  public static let openObject = Loc.tr("UI", "Open object", fallback: "Open object")
  public static let openSet = Loc.tr("UI", "Open Set", fallback: "Open Query")
  public static let openSource = Loc.tr("UI", "Open source", fallback: "Open source")
  public static func openTypeError(_ p1: Any) -> String {
    return Loc.tr("UI", "Open Type Error", String(describing: p1), fallback: "Not supported type \"%@\". You can open it via desktop.")
  }
  public static let openWebPage = Loc.tr("UI", "Open web page", fallback: "Open web page")
  public static let openSettings = Loc.tr("UI", "OpenSettings", fallback: "Open Settings")
  public static let other = Loc.tr("UI", "Other", fallback: "Other")
  public static let otherRelations = Loc.tr("UI", "Other relations", fallback: "Other properties")
  public static let p2PConnection = Loc.tr("UI", "P2P Connection", fallback: "P2P Connection")
  public static func paidBy(_ p1: Any) -> String {
    return Loc.tr("UI", "Paid by", String(describing: p1), fallback: "Paid by %@")
  }
  public static let paste = Loc.tr("UI", "Paste", fallback: "Paste")
  public static let pasteOrTypeURL = Loc.tr("UI", "Paste or type URL", fallback: "Paste or type URL")
  public static let pasteProcessing = Loc.tr("UI", "Paste processing...", fallback: "Paste processing...")
  public static let payByCard = Loc.tr("UI", "Pay by Card", fallback: "Pay by Card")
  public static func pdf(_ p1: Int) -> String {
    return Loc.tr("UI", "PDF", p1, fallback: "Plural format key: PDF")
  }
  public static let pending = Loc.tr("UI", "Pending", fallback: "Pending...")
  public static let pendingDeletionText = Loc.tr("UI", "Pending deletion text", fallback: "We're sorry to see you go. You have 30 days to cancel this request. After 30 days, your encrypted vault data will be permanently removed from the backup node.")
  public static let per = Loc.tr("UI", "per", fallback: "per")
  public static func perDay(_ p1: Int) -> String {
    return Loc.tr("UI", "Per Day", p1, fallback: "per %#@day@")
  }
  public static func perMonth(_ p1: Int) -> String {
    return Loc.tr("UI", "Per Month", p1, fallback: "per %#@month@")
  }
  public static func perWeek(_ p1: Int) -> String {
    return Loc.tr("UI", "Per Week", p1, fallback: "per %#@week@")
  }
  public static func perYear(_ p1: Int) -> String {
    return Loc.tr("UI", "Per Year", p1, fallback: "per %#@year@")
  }
  public static let personalization = Loc.tr("UI", "Personalization", fallback: "Personalization")
  public static let photo = Loc.tr("UI", "Photo", fallback: "Photo")
  public static let photos = Loc.tr("UI", "Photos", fallback: "Photos")
  public static let picture = Loc.tr("UI", "Picture", fallback: "Picture")
  public static let pin = Loc.tr("UI", "Pin", fallback: "Pin")
  public static func pinLimitReached(_ p1: Int) -> String {
    return Loc.tr("UI", "Pin limit reached", p1, fallback: "You've reached the limit of %d pinned spaces.")
  }
  public static let pinOnTop = Loc.tr("UI", "Pin on top", fallback: "Pin on top")
  public static let pink = Loc.tr("UI", "Pink", fallback: "Pink")
  public static let pinkBackground = Loc.tr("UI", "Pink background", fallback: "Pink background")
  public static let pinned = Loc.tr("UI", "Pinned", fallback: "Pinned")
  public static let preferences = Loc.tr("UI", "Preferences", fallback: "Preferences")
  public static let preview = Loc.tr("UI", "Preview", fallback: "Preview")
  public static let previewLayout = Loc.tr("UI", "Preview layout", fallback: "Preview layout")
  public static let profile = Loc.tr("UI", "Profile", fallback: "Profile")
  public static let progress = Loc.tr("UI", "Progress...", fallback: "Progress...")
  public static let publish = Loc.tr("UI", "Publish", fallback: "Publish")
  public static let publishToWeb = Loc.tr("UI", "Publish to Web", fallback: "Publish to Web")
  public static let purple = Loc.tr("UI", "Purple", fallback: "Purple")
  public static let purpleBackground = Loc.tr("UI", "Purple background", fallback: "Purple background")
  public static let puzzle = Loc.tr("UI", "Puzzle", fallback: "Puzzle")
  public static let puzzles = Loc.tr("UI", "Puzzles", fallback: "Puzzles")
  public static let qrCode = Loc.tr("UI", "QR Code", fallback: "QR Code")
  public static let random = Loc.tr("UI", "Random", fallback: "Random")
  public static let recent = Loc.tr("UI", "Recent", fallback: "Recent")
  public static let red = Loc.tr("UI", "Red", fallback: "Red")
  public static let redBackground = Loc.tr("UI", "Red background", fallback: "Red background")
  public static let redo = Loc.tr("UI", "Redo", fallback: "Redo")
  public static func relation(_ p1: Int) -> String {
    return Loc.tr("UI", "Relation", p1, fallback: "Plural format key: Relation")
  }
  public static let remove = Loc.tr("UI", "Remove", fallback: "Remove")
  public static let removePhoto = Loc.tr("UI", "Remove photo", fallback: "Remove photo")
  public static let resend = Loc.tr("UI", "Resend", fallback: "Resend")
  public static func resendIn(_ p1: Any) -> String {
    return Loc.tr("UI", "Resend in", String(describing: p1), fallback: "Resend in %@ sec")
  }
  public static let resetToDefault = Loc.tr("UI", "Reset to default", fallback: "Reset to default")
  public static let resolveLayoutConflict = Loc.tr("UI", "Resolve layout conflict", fallback: "Resolve layout conflict")
  public static let restore = Loc.tr("UI", "Restore", fallback: "Restore")
  public static let restoreFromKeychain = Loc.tr("UI", "Restore from keychain", fallback: "Restore from keychain")
  public static let restoreKeyFromKeychain = Loc.tr("UI", "Restore key from keychain", fallback: "Restore Key from the keychain")
  public static let save = Loc.tr("UI", "Save", fallback: "Save")
  public static let scanDocuments = Loc.tr("UI", "Scan documents", fallback: "Scan documents")
  public static let scanQRCode = Loc.tr("UI", "Scan QR code", fallback: "Scan QR code")
  public static let search = Loc.tr("UI", "Search", fallback: "Search...")
  public static let searchForLanguage = Loc.tr("UI", "Search for language", fallback: "Search for language")
  public static let searchOrCreateNew = Loc.tr("UI", "Search or create new", fallback: "Search or create new")
  public static let seeAll = Loc.tr("UI", "SeeAll", fallback: "See all")
  public static let selectAll = Loc.tr("UI", "Select all", fallback: "Select all")
  public static let selectDate = Loc.tr("UI", "Select date", fallback: "Select date")
  public static let selectFile = Loc.tr("UI", "Select file", fallback: "Select file")
  public static let selectObject = Loc.tr("UI", "Select object", fallback: "Select object")
  public static let selectObjects = Loc.tr("UI", "Select Objects", fallback: "Select Objects")
  public static let selectOption = Loc.tr("UI", "Select option", fallback: "Select option")
  public static let selectOptions = Loc.tr("UI", "Select options", fallback: "Select options")
  public static let selectRelationType = Loc.tr("UI", "Select relation type", fallback: "Select property format")
  public static let selectVaultError = Loc.tr("UI", "Select vault error", fallback: "Select vault error")
  public static func selectedBlocks(_ p1: Int) -> String {
    return Loc.tr("UI", "Selected blocks", p1, fallback: "Plural format key: Selected blocks")
  }
  public static let selfHost = Loc.tr("UI", "Self Host", fallback: "Self Host")
  public static let send = Loc.tr("UI", "Send", fallback: "Send")
  public static let `set` = Loc.tr("UI", "Set", fallback: "Query")
  public static let setAccess = Loc.tr("UI", "Set access", fallback: "Set access")
  public static let setAsDefault = Loc.tr("UI", "Set as default", fallback: "Set as default")
  public static func setOf(_ p1: Any) -> String {
    return Loc.tr("UI", "Set of", String(describing: p1), fallback: "Query of %@")
  }
  public static let sets = Loc.tr("UI", "Sets", fallback: "Queries")
  public static let settings = Loc.tr("UI", "Settings", fallback: "Settings")
  public static let share = Loc.tr("UI", "Share", fallback: "Share")
  public static let show = Loc.tr("UI", "Show", fallback: "Show")
  public static let showTypes = Loc.tr("UI", "Show types", fallback: "Show types")
  public static let skip = Loc.tr("UI", "Skip", fallback: "Skip")
  public static let sky = Loc.tr("UI", "Sky", fallback: "Sky")
  public static let skyBackground = Loc.tr("UI", "Sky background", fallback: "Sky background")
  public static let solidColors = Loc.tr("UI", "Solid colors", fallback: "Solid colors")
  public static let sort = Loc.tr("UI", "Sort", fallback: "Sort")
  public static let standardLayoutForCanvasBlocks = Loc.tr("UI", "Standard layout for canvas blocks", fallback: "Standard layout for canvas blocks")
  public static let start = Loc.tr("UI", "Start", fallback: "Start")
  public static let style = Loc.tr("UI", "Style", fallback: "Style")
  public static let submit = Loc.tr("UI", "Submit", fallback: "Submit")
  public static func successfullyDeleted(_ p1: Any) -> String {
    return Loc.tr("UI", "SuccessfullyDeleted ", String(describing: p1), fallback: "%@ deleted successfully")
  }
  public static let synced = Loc.tr("UI", "Synced", fallback: "Synced")
  public static let systemProperties = Loc.tr("UI", "System Properties", fallback: "System Properties")
  public static func tag(_ p1: Int) -> String {
    return Loc.tr("UI", "Tag", p1, fallback: "Plural format key: Tag")
  }
  public static let teal = Loc.tr("UI", "Teal", fallback: "Teal")
  public static let tealBackground = Loc.tr("UI", "Teal background", fallback: "Teal background")
  public static let templates = Loc.tr("UI", "Templates", fallback: "Templates")
  public static let textStyle = Loc.tr("UI", "Text Style", fallback: "Text Style")
  public static let thereAreNoSpacesYet = Loc.tr("UI", "There are no spaces yet", fallback: "There are no spaces yet")
  public static let thereIsNoEmojiNamed = Loc.tr("UI", "There is no emoji named", fallback: "There is no emoji named")
  public static let thereIsNoIconNamed = Loc.tr("UI", "There is no icon named", fallback: "There is no icon named")
  public static func thereIsNoObjectNamed(_ p1: Any) -> String {
    return Loc.tr("UI", "There is no object named", String(describing: p1), fallback: "There is no object named %@")
  }
  public static func thereIsNoPropertyNamed(_ p1: Any) -> String {
    return Loc.tr("UI", "There is no property named", String(describing: p1), fallback: "There is no property named %@")
  }
  public static func thereIsNoTypeNamed(_ p1: Any) -> String {
    return Loc.tr("UI", "There is no type named", String(describing: p1), fallback: "There is no type named %@")
  }
  public static let theseObjectsWillBeDeletedIrrevocably = Loc.tr("UI", "These objects will be deleted irrevocably", fallback: "These objects will be deleted irrevocably. You can’t undo this action.")
  public static let toBin = Loc.tr("UI", "To Bin", fallback: "To Bin")
  public static let today = Loc.tr("UI", "Today", fallback: "Today")
  public static let tomorrow = Loc.tr("UI", "Tomorrow", fallback: "Tomorrow")
  public static let tryToFindANewOne = Loc.tr("UI", "Try to find a new one", fallback: "Try to find a new one")
  public static let tryToFindANewOneOrUploadYourImage = Loc.tr("UI", "Try to find a new one or upload your image", fallback: "Try to find a new one or upload your image")
  public static let tryAgain = Loc.tr("UI", "TryAgain", fallback: "Try again")
  public static let typeName = Loc.tr("UI", "Type Name", fallback: "Type Name")
  public static let typePluralName = Loc.tr("UI", "Type Plural name", fallback: "Type Plural name")
  public static let types = Loc.tr("UI", "Types", fallback: "Types")
  public static let undo = Loc.tr("UI", "Undo", fallback: "Undo")
  public static let undoTyping = Loc.tr("UI", "Undo typing", fallback: "Undo typing")
  public static let undoRedo = Loc.tr("UI", "Undo/Redo", fallback: "Undo/Redo")
  public static let unknown = Loc.tr("UI", "Unknown", fallback: "Unknown")
  public static let unknownError = Loc.tr("UI", "Unknown error", fallback: "Unknown error")
  public static let unlimited = Loc.tr("UI", "unlimited", fallback: "Unlimited")
  public static let unlock = Loc.tr("UI", "Unlock", fallback: "Unlock")
  public static let unmute = Loc.tr("UI", "Unmute", fallback: "Unmute")
  public static let unpin = Loc.tr("UI", "Unpin", fallback: "Unpin")
  public static let unpublish = Loc.tr("UI", "Unpublish", fallback: "Unpublish")
  public static let unread = Loc.tr("UI", "Unread", fallback: "Unread")
  public static let unselectAll = Loc.tr("UI", "Unselect all", fallback: "Unselect all")
  public static let unsetAsDefault = Loc.tr("UI", "Unset as default", fallback: "Unset as default")
  public static let unsetDefault = Loc.tr("UI", "Unset default", fallback: "Unset default")
  public static let unsplash = Loc.tr("UI", "Unsplash", fallback: "Unsplash")
  public static let unsupported = Loc.tr("UI", "Unsupported", fallback: "Unsupported")
  public static let unsupportedBlock = Loc.tr("UI", "Unsupported block", fallback: "Unsupported block")
  public static let unsupportedDeeplink = Loc.tr("UI", "Unsupported deeplink", fallback: "Unsupported deeplink")
  public static let unsupportedValue = Loc.tr("UI", "Unsupported value", fallback: "Unsupported value")
  public static let untitled = Loc.tr("UI", "Untitled", fallback: "Untitled")
  public static let update = Loc.tr("UI", "Update", fallback: "Update")
  public static let upgrade = Loc.tr("UI", "Upgrade", fallback: "Upgrade")
  public static let upload = Loc.tr("UI", "Upload", fallback: "Upload")
  public static let validUntil = Loc.tr("UI", "Valid until", fallback: "Valid until:")
  public static func validUntilDate(_ p1: Any) -> String {
    return Loc.tr("UI", "Valid until date", String(describing: p1), fallback: "Valid until %@")
  }
  public static let vault = Loc.tr("UI", "Vault", fallback: "Vault")
  public static let vaultDeleted = Loc.tr("UI", "Vault deleted", fallback: "Vault deleted")
  public static let vaultRecoverError = Loc.tr("UI", "Vault recover error", fallback: "Vault recover error, try again")
  public static let vaultRecoverErrorNoInternet = Loc.tr("UI", "Vault recover error no internet", fallback: "Vault recover error, probably no internet connection")
  public static func video(_ p1: Int) -> String {
    return Loc.tr("UI", "Video", p1, fallback: "Plural format key: Video")
  }
  public static let view = Loc.tr("UI", "View", fallback: "View")
  public static let viewInBrowser = Loc.tr("UI", "View in Browser", fallback: "View in Browser")
  public static let views = Loc.tr("UI", "Views", fallback: "Views")
  public static let wallpaper = Loc.tr("UI", "Wallpaper", fallback: "Wallpaper")
  public static let webPages = Loc.tr("UI", "Web pages", fallback: "Web pages")
  public static let whatSIncluded = Loc.tr("UI", "What’s included", fallback: "What’s included")
  public static let yellow = Loc.tr("UI", "Yellow", fallback: "Yellow")
  public static let yellowBackground = Loc.tr("UI", "Yellow background", fallback: "Yellow background")
  public static let yesterday = Loc.tr("UI", "Yesterday", fallback: "Yesterday")
  public static func youJoined(_ p1: Any) -> String {
    return Loc.tr("UI", "You joined", String(describing: p1), fallback: "You joined %@")
  }
  public static let yourCurrentStatus = Loc.tr("UI", "Your current status", fallback: "Your current status:")
  public enum About {
    public static func analyticsId(_ p1: Any) -> String {
      return Loc.tr("UI", "About.analyticsId", String(describing: p1), fallback: "Analytics ID: %@")
    }
    public static let anytypeCommunity = Loc.tr("UI", "About.AnytypeCommunity", fallback: "Anytype Community")
    public static func anytypeId(_ p1: Any) -> String {
      return Loc.tr("UI", "About.anytypeId", String(describing: p1), fallback: "Anytype ID: %@")
    }
    public static func appVersion(_ p1: Any) -> String {
      return Loc.tr("UI", "About.AppVersion", String(describing: p1), fallback: "App version: %@")
    }
    public static func buildNumber(_ p1: Any) -> String {
      return Loc.tr("UI", "About.BuildNumber", String(describing: p1), fallback: "Build number: %@")
    }
    public static let contactUs = Loc.tr("UI", "About.ContactUs", fallback: "Contact Us")
    public static func device(_ p1: Any) -> String {
      return Loc.tr("UI", "About.Device", String(describing: p1), fallback: "Device: %@")
    }
    public static func deviceId(_ p1: Any) -> String {
      return Loc.tr("UI", "About.deviceId", String(describing: p1), fallback: "Device ID: %@")
    }
    public static let helpCommunity = Loc.tr("UI", "About.HelpCommunity", fallback: "Help & Community")
    public static let helpTutorials = Loc.tr("UI", "About.HelpTutorials", fallback: "Help & Tutorials")
    public static let legal = Loc.tr("UI", "About.Legal", fallback: "Legal")
    public static func library(_ p1: Any) -> String {
      return Loc.tr("UI", "About.Library", String(describing: p1), fallback: "Library version: %@")
    }
    public static func osVersion(_ p1: Any) -> String {
      return Loc.tr("UI", "About.OSVersion", String(describing: p1), fallback: "OS version: %@")
    }
    public static let privacyPolicy = Loc.tr("UI", "About.PrivacyPolicy", fallback: "Privacy Policy")
    public static let techInfo = Loc.tr("UI", "About.TechInfo", fallback: "Tech Info")
    public static let termsOfUse = Loc.tr("UI", "About.TermsOfUse", fallback: "Terms of Use")
    public static let whatsNew = Loc.tr("UI", "About.WhatsNew", fallback: "What’s New")
    public enum Mail {
      public static func body(_ p1: Any) -> String {
        return Loc.tr("UI", "About.Mail.Body", String(describing: p1), fallback: "\n\nTechnical information\n%@")
      }
      public static func subject(_ p1: Any) -> String {
        return Loc.tr("UI", "About.Mail.Subject", String(describing: p1), fallback: "Support request, Vault ID %@")
      }
    }
  }
  public enum Actions {
    public static let linkItself = Loc.tr("UI", "Actions.LinkItself", fallback: "Link to")
    public static let makeAsTemplate = Loc.tr("UI", "Actions.MakeAsTemplate", fallback: "Make template")
    public static let templateMakeDefault = Loc.tr("UI", "Actions.TemplateMakeDefault", fallback: "Make default")
  }
  public enum Alert {
    public enum CameraPermissions {
      public static let goToSettings = Loc.tr("UI", "Alert.CameraPermissions.GoToSettings", fallback: "Anytype needs access to your camera to scan QR codes.\n\nPlease, go to your device's Settings -> Anytype and set Camera to ON")
      public static let settings = Loc.tr("UI", "Alert.CameraPermissions.Settings", fallback: "Settings")
    }
  }
  public enum AllObjects {
    public enum Search {
      public enum Empty {
        public enum State {
          public static let subtitle = Loc.tr("UI", "AllObjects.Search.Empty.State.subtitle", fallback: "Try searching with different keywords.")
          public static let title = Loc.tr("UI", "AllObjects.Search.Empty.State.title", fallback: "No results found.")
        }
      }
    }
    public enum Settings {
      public static let viewBin = Loc.tr("UI", "AllObjects.Settings.ViewBin", fallback: "View Bin")
      public enum Sort {
        public static let title = Loc.tr("UI", "AllObjects.Settings.Sort.Title", fallback: "Sort by")
      }
      public enum Unlinked {
        public static let description = Loc.tr("UI", "AllObjects.Settings.Unlinked.Description", fallback: "Unlinked objects that do not have a direct link or backlink with other objects in the graph.")
        public static let title = Loc.tr("UI", "AllObjects.Settings.Unlinked.Title", fallback: "Only unlinked")
      }
    }
    public enum Sort {
      public static let dateCreated = Loc.tr("UI", "AllObjects.Sort.DateCreated", fallback: "Date created")
      public static let dateUpdated = Loc.tr("UI", "AllObjects.Sort.DateUpdated", fallback: "Date updated")
      public enum Date {
        public static let asc = Loc.tr("UI", "AllObjects.Sort.Date.Asc", fallback: "Oldest first")
        public static let desc = Loc.tr("UI", "AllObjects.Sort.Date.Desc", fallback: "Newest first")
      }
      public enum Name {
        public static let asc = Loc.tr("UI", "AllObjects.Sort.Name.Asc", fallback: "A → Z")
        public static let desc = Loc.tr("UI", "AllObjects.Sort.Name.Desc", fallback: "Z → A")
      }
    }
  }
  public enum BlockLink {
    public enum PreviewSettings {
      public enum IconSize {
        public static let medium = Loc.tr("UI", "BlockLink.PreviewSettings.IconSize.Medium", fallback: "Medium")
        public static let `none` = Loc.tr("UI", "BlockLink.PreviewSettings.IconSize.None", fallback: "None")
        public static let small = Loc.tr("UI", "BlockLink.PreviewSettings.IconSize.Small", fallback: "Small")
      }
      public enum Layout {
        public enum Card {
          public static let title = Loc.tr("UI", "BlockLink.PreviewSettings.Layout.Card.Title", fallback: "Card")
        }
        public enum Text {
          public static let title = Loc.tr("UI", "BlockLink.PreviewSettings.Layout.Text.Title", fallback: "Text")
        }
      }
    }
  }
  public enum BlockText {
    public enum ContentType {
      public enum Bulleted {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Bulleted.Placeholder", fallback: "Bulleted list item")
      }
      public enum Checkbox {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Checkbox.Placeholder", fallback: "Checkbox")
      }
      public enum Description {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Description.Placeholder", fallback: "Add a description")
      }
      public enum Header {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Header.Placeholder", fallback: "Title")
      }
      public enum Header2 {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Header2.Placeholder", fallback: "Heading")
      }
      public enum Header3 {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Header3.Placeholder", fallback: "Subheading")
      }
      public enum Numbered {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Numbered.Placeholder", fallback: "Numbered list item")
      }
      public enum Quote {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Quote.Placeholder", fallback: "Highlighted text")
      }
      public enum Title {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Title.Placeholder", fallback: "Untitled")
      }
      public enum Toggle {
        public static let placeholder = Loc.tr("UI", "BlockText.ContentType.Toggle.Placeholder", fallback: "Toggle block")
      }
    }
  }
  public enum ClearCache {
    public static let error = Loc.tr("UI", "ClearCache.Error", fallback: "Error, try again later")
    public static let success = Loc.tr("UI", "ClearCache.Success", fallback: "Cache sucessfully cleared")
  }
  public enum ClearCacheAlert {
    public static let description = Loc.tr("UI", "ClearCacheAlert.Description", fallback: "All media files stored in Anytype will be deleted from your current device. They can be downloaded again from a backup node or another device.")
    public static let title = Loc.tr("UI", "ClearCacheAlert.Title", fallback: "Are you sure?")
  }
  public enum CommonOpenErrorView {
    public static let message = Loc.tr("UI", "CommonOpenErrorView.Message", fallback: "No data found")
  }
  public enum ConvertChannelTypeAlert {
    public static let confirm = Loc.tr("UI", "ConvertChannelTypeAlert.confirm", fallback: "Yes, convert")
    public static let message = Loc.tr("UI", "ConvertChannelTypeAlert.message", fallback: "Switching between Space and Chat will significantly change the experience.")
    public static let title = Loc.tr("UI", "ConvertChannelTypeAlert.title", fallback: "Convert Channel Type?")
  }
  public enum DataviewType {
    public static let calendar = Loc.tr("UI", "DataviewType.calendar", fallback: "Calendar")
    public static let gallery = Loc.tr("UI", "DataviewType.gallery", fallback: "Gallery")
    public static let graph = Loc.tr("UI", "DataviewType.graph", fallback: "Graph")
    public static let grid = Loc.tr("UI", "DataviewType.grid", fallback: "Grid")
    public static let kanban = Loc.tr("UI", "DataviewType.kanban", fallback: "Kanban")
    public static let list = Loc.tr("UI", "DataviewType.list", fallback: "List")
  }
  public enum Date {
    public enum Object {
      public enum Empty {
        public enum State {
          public static let title = Loc.tr("UI", "Date.Object.Empty.State.title", fallback: "There is nothing here for this date yet")
        }
      }
    }
    public enum Open {
      public enum Action {
        public static let title = Loc.tr("UI", "Date.Open.Action.title", fallback: "Open selected date")
      }
    }
  }
  public enum Debug {
    public static let info = Loc.tr("UI", "Debug.Info", fallback: "Debug Info")
    public static func mimeTypes(_ p1: Any) -> String {
      return Loc.tr("UI", "Debug.MimeTypes", String(describing: p1), fallback: "Mime Types - %@")
    }
  }
  public enum DebugMenu {
    public static func toggleAuthor(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("UI", "DebugMenu.ToggleAuthor", String(describing: p1), String(describing: p2), fallback: "Release: %@, %@")
    }
  }
  public enum DeletionAlert {
    public static let description = Loc.tr("UI", "DeletionAlert.description", fallback: "You will be logged out on all other devices. You'll have 30 days to recover your vault. Afterwards, it will be deleted permanently.")
    public static let title = Loc.tr("UI", "DeletionAlert.title", fallback: "Are you sure you want to delete your vault?")
  }
  public enum Embed {
    public enum Block {
      public enum Content {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("UI", "Embed.Block.Content.title", String(describing: p1), fallback: "%@ embed. This content is not available on mobile")
        }
        public enum Url {
          public static func title(_ p1: Any) -> String {
            return Loc.tr("UI", "Embed.Block.Content.Url.title", String(describing: p1), fallback: "%@ embed. Opens in external app or browser")
          }
        }
      }
      public enum Empty {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("UI", "Embed.Block.Empty.title", String(describing: p1), fallback: "%@ embed is empty")
        }
      }
    }
  }
  public enum EmptyView {
    public enum Bin {
      public static let subtitle = Loc.tr("UI", "EmptyView.Bin.subtitle", fallback: "Looks like you’re all tidy and organized!")
      public static let title = Loc.tr("UI", "EmptyView.Bin.title", fallback: "Your bin is empty.")
    }
    public enum Default {
      public static let subtitle = Loc.tr("UI", "EmptyView.Default.subtitle", fallback: "Create your first objects to get started.")
      public static let title = Loc.tr("UI", "EmptyView.Default.title", fallback: "It’s empty here.")
    }
    public enum Publishing {
      public static let subtitle = Loc.tr("UI", "EmptyView.Publishing.subtitle", fallback: "Publish your first web site to get started.")
    }
  }
  public enum Error {
    public static let unableToConnect = Loc.tr("UI", "Error.UnableToConnect", fallback: "Please connect to the internet")
    public enum AnytypeNeedsUpgrate {
      public static let confirm = Loc.tr("UI", "Error.AnytypeNeedsUpgrate.Confirm", fallback: "Update")
      public static let message = Loc.tr("UI", "Error.AnytypeNeedsUpgrate.Message", fallback: "This object was modified in a newer version of Anytype. Please update the app to open it on this device")
      public static let title = Loc.tr("UI", "Error.AnytypeNeedsUpgrate.Title", fallback: "Update Your App")
    }
    public enum Common {
      public static let message = Loc.tr("UI", "Error.Common.Message", fallback: "Please check your internet connection and try again or [post a report on forum](http://community.anytype.io/report-bug).")
      public static let title = Loc.tr("UI", "Error.Common.Title", fallback: "Oops!")
    }
  }
  public enum ErrorOccurred {
    public static let pleaseTryAgain = Loc.tr("UI", "Error occurred. Please try again", fallback: "Error occurred. Please try again")
  }
  public enum Experimental {
    public enum NewObjectCreationMenu {
      public static let subtitle = Loc.tr("UI", "Experimental.NewObjectCreationMenu.subtitle", fallback: "Always pick object type when creating")
      public static let title = Loc.tr("UI", "Experimental.NewObjectCreationMenu.title", fallback: "New Object Creation Menu")
    }
  }
  public enum FileStorage {
    public static let cleanUpFiles = Loc.tr("UI", "FileStorage.CleanUpFiles", fallback: "Clean up files")
    public static let limitError = Loc.tr("UI", "FileStorage.LimitError", fallback: "You exceeded file limit upload")
    public static let offloadTitle = Loc.tr("UI", "FileStorage.OffloadTitle", fallback: "Offload files")
    public static let title = Loc.tr("UI", "FileStorage.Title", fallback: "File storage")
    public enum LimitLegend {
      public static func current(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("UI", "FileStorage.LimitLegend.Current", String(describing: p1), String(describing: p2), fallback: "%@ | %@")
      }
      public static func free(_ p1: Any) -> String {
        return Loc.tr("UI", "FileStorage.LimitLegend.Free", String(describing: p1), fallback: "Free | %@")
      }
      public static func other(_ p1: Any) -> String {
        return Loc.tr("UI", "FileStorage.LimitLegend.Other", String(describing: p1), fallback: "Other spaces | %@")
      }
    }
    public enum Local {
      public static let instruction = Loc.tr("UI", "FileStorage.Local.Instruction", fallback: "In order to save space on your local device, you can offload all your files to our encrypted backup node. The files will be loaded back when you open them.")
      public static let title = Loc.tr("UI", "FileStorage.Local.Title", fallback: "Local Storage")
      public static func used(_ p1: Any) -> String {
        return Loc.tr("UI", "FileStorage.Local.Used", String(describing: p1), fallback: "%@ used")
      }
    }
    public enum Space {
      public static let getMore = Loc.tr("UI", "FileStorage.Space.GetMore", fallback: "Get more space")
      public static func instruction(_ p1: Any) -> String {
        return Loc.tr("UI", "FileStorage.Space.Instruction", String(describing: p1), fallback: "You can store up to %@ of your files on our encrypted backup node for free. If you reach the limit, files will be stored only locally.")
      }
      public static let localOnlyInstruction = Loc.tr("UI", "FileStorage.Space.LocalOnlyInstruction", fallback: "Remote storage is not available in local-only mode. Your files are stored locally on your device.")
      public static let title = Loc.tr("UI", "FileStorage.Space.Title", fallback: "Remote storage")
      public static func used(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("UI", "FileStorage.Space.Used", String(describing: p1), String(describing: p2), fallback: "%@ of %@ used")
      }
    }
  }
  public enum FilesList {
    public static let title = Loc.tr("UI", "FilesList.Title", fallback: "Clean up files")
    public enum ForceDelete {
      public static let title = Loc.tr("UI", "FilesList.ForceDelete.Title", fallback: "Are you sure you want to permanently delete the files?")
    }
  }
  public enum Gallery {
    public static func author(_ p1: Any) -> String {
      return Loc.tr("UI", "Gallery.Author", String(describing: p1), fallback: "Made by @%@")
    }
    public static let install = Loc.tr("UI", "Gallery.Install", fallback: "Install")
    public static let installToNew = Loc.tr("UI", "Gallery.InstallToNew", fallback: "Install to new space")
    public enum Notification {
      public static let button = Loc.tr("UI", "Gallery.Notification.Button", fallback: "Go to space")
      public static func error(_ p1: Any) -> String {
        return Loc.tr("UI", "Gallery.Notification.Error", String(describing: p1), fallback: "Oops! \"%@\" wasn't installed. Please check your internet connection and try again or post a report on forum.")
      }
      public static func success(_ p1: Any) -> String {
        return Loc.tr("UI", "Gallery.Notification.Success", String(describing: p1), fallback: "Experience was successfully installed to the \"%@\" space. You can now open and start using it.")
      }
    }
  }
  public enum GlobalSearch {
    public enum EmptyFilteredState {
      public static let title = Loc.tr("UI", "GlobalSearch.EmptyFilteredState.title", fallback: "No related objects found")
    }
    public enum EmptyState {
      public static let subtitle = Loc.tr("UI", "GlobalSearch.EmptyState.subtitle", fallback: "Create new object or search for something else")
    }
    public enum Swipe {
      public enum Tip {
        public static let subtitle = Loc.tr("UI", "GlobalSearch.Swipe.Tip.subtitle", fallback: "Swipe left to see related objects. Note, it works only for objects that have related objects.")
        public static let title = Loc.tr("UI", "GlobalSearch.Swipe.Tip.title", fallback: "Related objects")
      }
    }
  }
  public enum Home {
    public enum Snackbar {
      public static let library = Loc.tr("UI", "Home.Snackbar.Library", fallback: "Library is available in desktop app")
    }
  }
  public enum InterfaceStyle {
    public static let dark = Loc.tr("UI", "InterfaceStyle.dark", fallback: "Dark")
    public static let light = Loc.tr("UI", "InterfaceStyle.light", fallback: "Light")
    public static let system = Loc.tr("UI", "InterfaceStyle.system", fallback: "System")
  }
  public enum LinkAppearance {
    public enum Description {
      public enum Content {
        public static let title = Loc.tr("UI", "LinkAppearance.Description.Content.Title", fallback: "Content preview")
      }
      public enum None {
        public static let title = Loc.tr("UI", "LinkAppearance.Description.None.Title", fallback: "None")
      }
      public enum Object {
        public static let title = Loc.tr("UI", "LinkAppearance.Description.Object.Title", fallback: "Object description")
      }
    }
    public enum ObjectType {
      public static let title = Loc.tr("UI", "LinkAppearance.ObjectType.Title", fallback: "Object type")
    }
  }
  public enum LinkPaste {
    public static let bookmark = Loc.tr("UI", "LinkPaste.bookmark", fallback: "Create bookmark")
    public static let link = Loc.tr("UI", "LinkPaste.link", fallback: "Paste as link")
    public static let text = Loc.tr("UI", "LinkPaste.text", fallback: "Paste as text")
  }
  public enum LongTapCreateTip {
    public static let message = Loc.tr("UI", "LongTapCreateTip.Message", fallback: "Long tap on Create Object button to open menu with types")
    public static let title = Loc.tr("UI", "LongTapCreateTip.Title", fallback: "Create Objects with specific Type")
  }
  public enum Mention {
    public enum Subtitle {
      public static let placeholder = Loc.tr("UI", "Mention.Subtitle.Placeholder", fallback: "Object")
    }
  }
  public enum ObjectTypeDeleteAlert {
    public static let message = Loc.tr("UI", "ObjectTypeDeleteAlert.message", fallback: "Are you sure you want to delete this Type? All existing objects of this type will be preserved, but will no longer be associated with it.")
    public static let title = Loc.tr("UI", "ObjectTypeDeleteAlert.title", fallback: "Delete Object Type?")
  }
  public enum Primitives {
    public enum LayoutConflict {
      public static let description = Loc.tr("UI", "Primitives.LayoutConflict.Description", fallback: "This layout differs from the type's default. Reset to match?")
    }
  }
  public enum QuickAction {
    public static func create(_ p1: Any) -> String {
      return Loc.tr("UI", "QuickAction.create", String(describing: p1), fallback: "Create %@")
    }
  }
  public enum RedactedText {
    public static let pageTitle = Loc.tr("UI", "RedactedText.pageTitle", fallback: "Wake up, Neo")
    public static let pageType = Loc.tr("UI", "RedactedText.pageType", fallback: "Red pill")
  }
  public enum ReindexingWarningAlert {
    public static let description = Loc.tr("UI", "ReindexingWarningAlert.Description", fallback: "We've implemented a new search library for faster and more accurate results.\nReindexing may take a few minutes.")
    public static let title = Loc.tr("UI", "ReindexingWarningAlert.Title", fallback: "Upgrading your search experience")
  }
  public enum RelativeFormatter {
    public static let days14 = Loc.tr("UI", "RelativeFormatter.days14", fallback: "Previous 14 days")
    public static let days7 = Loc.tr("UI", "RelativeFormatter.days7", fallback: "Previous 7 days")
  }
  public enum ReturnToWidgets {
    public enum Tip {
      public static let text = Loc.tr("UI", "ReturnToWidgets.Tip.Text", fallback: "Long press the back button to return to widgets instead of tapping it repeatedly.")
      public static let title = Loc.tr("UI", "ReturnToWidgets.Tip.Title", fallback: "Long Press to Return to Widgets")
    }
  }
  public enum Scanner {
    public enum Error {
      public static let scanningNotSupported = Loc.tr("UI", "Scanner.Error.Scanning not supported", fallback: "Scanning not supported")
    }
  }
  public enum Search {
    public enum Links {
      public enum Header {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("UI", "Search.Links.Header.title", String(describing: p1), fallback: "Related to: %@")
        }
      }
      public enum Show {
        public static let title = Loc.tr("UI", "Search.Links.Show.title", fallback: "Show related objects")
      }
      public enum Swipe {
        public static let title = Loc.tr("UI", "Search.Links.Swipe.title", fallback: "Related to")
      }
    }
  }
  public enum SecureAlert {
    public static let message = Loc.tr("UI", "SecureAlert.message", fallback: "You phone doesn’t have a passcode or biometric authorization. It might make it easier to steal your data. Enable it in your app settings to secure your data.")
    public static let title = Loc.tr("UI", "SecureAlert.title", fallback: "Secure your phone")
    public enum Proceed {
      public static let button = Loc.tr("UI", "SecureAlert.Proceed.button", fallback: "Proceed anyway")
    }
  }
  public enum Server {
    public static let addButton = Loc.tr("UI", "Server.AddButton", fallback: "Add Self-hosted Network")
    public static let anytype = Loc.tr("UI", "Server.Anytype", fallback: "Anytype")
    public static let localOnly = Loc.tr("UI", "Server.LocalOnly", fallback: "Local-only")
    public static let network = Loc.tr("UI", "Server.Network", fallback: "Select Network")
    public static let networks = Loc.tr("UI", "Server.Networks", fallback: "Networks")
    public enum LocalOnly {
      public enum Alert {
        public static let message = Loc.tr("UI", "Server.LocalOnly.Alert.message", fallback: "Local-only mode is an experimental feature and does not provide security benefits. Please use it at your own risk, as data loss may occur.")
        public static let title = Loc.tr("UI", "Server.LocalOnly.Alert.title", fallback: "Are you sure?")
        public enum Action {
          public static let agree = Loc.tr("UI", "Server.LocalOnly.Alert.Action.agree", fallback: "Yes, I accept risks")
          public static let disagree = Loc.tr("UI", "Server.LocalOnly.Alert.Action.disagree", fallback: "No, don’t use it")
        }
      }
    }
  }
  public enum SetViewTypesPicker {
    public static let title = Loc.tr("UI", "SetViewTypesPicker.Title", fallback: "Edit view")
    public enum New {
      public static let title = Loc.tr("UI", "SetViewTypesPicker.New.Title", fallback: "New view")
    }
    public enum Section {
      public enum Types {
        public static let title = Loc.tr("UI", "SetViewTypesPicker.Section.Types.Title", fallback: "View as")
      }
    }
    public enum Settings {
      public enum Delete {
        public static let view = Loc.tr("UI", "SetViewTypesPicker.Settings.Delete.View", fallback: "Delete view")
      }
      public enum Duplicate {
        public static let view = Loc.tr("UI", "SetViewTypesPicker.Settings.Duplicate.View", fallback: "Duplicate")
      }
      public enum Textfield {
        public enum Placeholder {
          public static let untitled = Loc.tr("UI", "SetViewTypesPicker.Settings.Textfield.Placeholder.Untitled", fallback: "Untitled")
          public enum New {
            public static let view = Loc.tr("UI", "SetViewTypesPicker.Settings.Textfield.Placeholder.New.View", fallback: "New view")
          }
        }
      }
    }
  }
  public enum Settings {
    public static let autoCreateTypeWidgets = Loc.tr("UI", "Settings.AutoCreateTypeWidgets", fallback: "Auto Create Type Widgets")
    public static let chatDisabled = Loc.tr("UI", "Settings.ChatDisabled", fallback: "Chat is disabled")
    public static let chatEnabled = Loc.tr("UI", "Settings.ChatEnabled", fallback: "Chat is enabled")
    public static let dataManagement = Loc.tr("UI", "Settings.DataManagement", fallback: "Data Management")
    public static let editPicture = Loc.tr("UI", "Settings.Edit picture", fallback: "Edit picture")
    public static let spaceType = Loc.tr("UI", "Settings.SpaceType", fallback: "Space type")
    public static let title = Loc.tr("UI", "Settings.Title", fallback: "Settings")
    public static let updated = Loc.tr("UI", "Settings.Updated", fallback: "Space information updated")
  }
  public enum SimpleTableMenu {
    public enum Item {
      public static let clearContents = Loc.tr("UI", "SimpleTableMenu.Item.clearContents", fallback: "Clear")
      public static let clearStyle = Loc.tr("UI", "SimpleTableMenu.Item.clearStyle", fallback: "Reset style")
      public static let color = Loc.tr("UI", "SimpleTableMenu.Item.color", fallback: "Color")
      public static let delete = Loc.tr("UI", "SimpleTableMenu.Item.Delete", fallback: "Delete")
      public static let duplicate = Loc.tr("UI", "SimpleTableMenu.Item.Duplicate", fallback: "Duplicate")
      public static let insertAbove = Loc.tr("UI", "SimpleTableMenu.Item.InsertAbove", fallback: "Insert above")
      public static let insertBelow = Loc.tr("UI", "SimpleTableMenu.Item.InsertBelow", fallback: "Insert below")
      public static let insertLeft = Loc.tr("UI", "SimpleTableMenu.Item.InsertLeft", fallback: "Insert left")
      public static let insertRight = Loc.tr("UI", "SimpleTableMenu.Item.InsertRight", fallback: "Insert right")
      public static let moveDown = Loc.tr("UI", "SimpleTableMenu.Item.MoveDown", fallback: "Move down")
      public static let moveLeft = Loc.tr("UI", "SimpleTableMenu.Item.MoveLeft", fallback: "Move left")
      public static let moveRight = Loc.tr("UI", "SimpleTableMenu.Item.MoveRight", fallback: "Move right")
      public static let moveUp = Loc.tr("UI", "SimpleTableMenu.Item.MoveUp", fallback: "Move up")
      public static let sort = Loc.tr("UI", "SimpleTableMenu.Item.Sort", fallback: "Sort")
      public static let style = Loc.tr("UI", "SimpleTableMenu.Item.style", fallback: "Style")
    }
  }
  public enum StoreKitServiceError {
    public static let needUserAction = Loc.tr("UI", "StoreKitServiceError.needUserAction", fallback: "Payment unsuccessfull, User Actions on Apple side required to pay.")
    public static let userCancelled = Loc.tr("UI", "StoreKitServiceError.userCancelled", fallback: "Purchase cancelled")
  }
  public enum StyleMenu {
    public enum Color {
      public enum TextColor {
        public static let placeholder = Loc.tr("UI", "StyleMenu.Color.TextColor.Placeholder", fallback: "A")
      }
    }
  }
  public enum Swipe {
    public enum Tip {
      public static let subtitle = Loc.tr("UI", "Swipe.Tip.Subtitle", fallback: "Create objects inside widgets by easily swiping them left.")
      public static let title = Loc.tr("UI", "Swipe.Tip.Title", fallback: "Swipe to Create Objects")
    }
  }
  public enum Sync {
    public enum Status {
      public enum Version {
        public enum Outdated {
          public static let description = Loc.tr("UI", "Sync.Status.Version.Outdated.Description", fallback: "Version outdated. Please update Anytype")
        }
      }
    }
  }
  public enum SyncStatus {
    public enum Error {
      public static let incompatibleVersion = Loc.tr("UI", "SyncStatus.Error.incompatibleVersion", fallback: "Incompatible version")
      public static let networkError = Loc.tr("UI", "SyncStatus.Error.networkError", fallback: "No access to the space")
      public static let storageLimitExceed = Loc.tr("UI", "SyncStatus.Error.storageLimitExceed", fallback: "Storage limit reached")
      public static let unrecognized = Loc.tr("UI", "SyncStatus.Error.UNRECOGNIZED", fallback: "Unrecognized error")
    }
    public enum Info {
      public static let anytypeNetwork = Loc.tr("UI", "SyncStatus.Info.AnytypeNetwork", fallback: "End-to-end encrypted")
      public static let localOnly = Loc.tr("UI", "SyncStatus.Info.localOnly", fallback: "Data backup is disabled")
      public static let networkNeedsUpdate = Loc.tr("UI", "SyncStatus.Info.NetworkNeedsUpdate", fallback: "Sync might be slow. Update the app.")
    }
    public enum P2P {
      public static let notConnected = Loc.tr("UI", "SyncStatus.P2P.NotConnected", fallback: "Not connected")
      public static let notPossible = Loc.tr("UI", "SyncStatus.P2P.NotPossible", fallback: "Connection not possible")
      public static let restricted = Loc.tr("UI", "SyncStatus.P2P.Restricted", fallback: "Restricted. Tap to open device settings.")
    }
  }
  public enum TalbeOfContents {
    public static let empty = Loc.tr("UI", "TalbeOfContents.Empty", fallback: "Add headings to create a table of contents")
  }
  public enum Templates {
    public enum Popup {
      public static let `default` = Loc.tr("UI", "Templates.Popup.Default", fallback: "The template was set as default")
      public static let duplicated = Loc.tr("UI", "Templates.Popup.Duplicated", fallback: "The template was duplicated")
      public static let removed = Loc.tr("UI", "Templates.Popup.Removed", fallback: "The template was removed")
      public static let wasAddedTo = Loc.tr("UI", "Templates.Popup.WasAddedTo", fallback: "New template was added to the type")
      public enum WasAddedTo {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("UI", "Templates.Popup.WasAddedTo.title", String(describing: p1), fallback: "New template was added to the type %@")
        }
      }
    }
  }
  public enum TextStyle {
    public enum Bold {
      public static let title = Loc.tr("UI", "TextStyle.Bold.Title", fallback: "Bold")
    }
    public enum Bulleted {
      public static let title = Loc.tr("UI", "TextStyle.Bulleted.Title", fallback: "Bulleted")
    }
    public enum Callout {
      public static let title = Loc.tr("UI", "TextStyle.Callout.Title", fallback: "Callout")
    }
    public enum Checkbox {
      public static let title = Loc.tr("UI", "TextStyle.Checkbox.Title", fallback: "Checkbox")
    }
    public enum Code {
      public static let title = Loc.tr("UI", "TextStyle.Code.Title", fallback: "Code")
    }
    public enum Heading {
      public static let title = Loc.tr("UI", "TextStyle.Heading.Title", fallback: "Heading")
    }
    public enum Highlighted {
      public static let title = Loc.tr("UI", "TextStyle.Highlighted.Title", fallback: "Highlighted")
    }
    public enum Italic {
      public static let title = Loc.tr("UI", "TextStyle.Italic.Title", fallback: "Italic")
    }
    public enum Link {
      public static let title = Loc.tr("UI", "TextStyle.Link.Title", fallback: "Link")
    }
    public enum Numbered {
      public static let title = Loc.tr("UI", "TextStyle.Numbered.Title", fallback: "Numbered list")
    }
    public enum Strikethrough {
      public static let title = Loc.tr("UI", "TextStyle.Strikethrough.Title", fallback: "Strikethrough")
    }
    public enum Subheading {
      public static let title = Loc.tr("UI", "TextStyle.Subheading.Title", fallback: "Subheading")
    }
    public enum Text {
      public static let title = Loc.tr("UI", "TextStyle.Text.Title", fallback: "Text")
    }
    public enum Title {
      public static let title = Loc.tr("UI", "TextStyle.Title.Title", fallback: "Title")
    }
    public enum Toggle {
      public static let title = Loc.tr("UI", "TextStyle.Toggle.Title", fallback: "Toggle")
    }
    public enum Underline {
      public static let title = Loc.tr("UI", "TextStyle.Underline.Title", fallback: "Underline")
    }
  }
  public enum ToggleEmpty {
    public static let tapToCreateBlock = Loc.tr("UI", "Toggle empty. Tap to create block.", fallback: "Toggle empty. Tap to create block.")
  }
  public enum VersionHistory {
    public static let title = Loc.tr("UI", "VersionHistory.Title", fallback: "Version History")
    public enum Toast {
      public static func message(_ p1: Any) -> String {
        return Loc.tr("UI", "VersionHistory.Toast.message", String(describing: p1), fallback: "Version %@ was restored")
      }
    }
  }
  public enum Wallet {
    public enum Recovery {
      public enum Error {
        public static let description = Loc.tr("UI", "Wallet.Recovery.Error.description", fallback: "Invalid Key")
      }
    }
  }
  public enum WidgetExtension {
    public enum LockScreen {
      public static let description = Loc.tr("UI", "WidgetExtension.LockScreen.Description", fallback: "Create a new object on the fly")
      public static let title = Loc.tr("UI", "WidgetExtension.LockScreen.Title", fallback: "New object")
    }
  }
  public enum WidgetObjectList {
    public enum ForceDelete {
      public static let message = Loc.tr("UI", "WidgetObjectList.ForceDelete.Message", fallback: "You can’t undo this action.")
    }
  }
  public enum Widgets {
    public static let appUpdate = Loc.tr("UI", "Widgets.AppUpdate", fallback: "Anytype is ready to update")
    public static func autoAddedAlert(_ p1: Any) -> String {
      return Loc.tr("UI", "Widgets.AutoAddedAlert", String(describing: p1), fallback: "Widget %@ was added")
    }
    public enum Actions {
      public static func binConfirm(_ p1: Int) -> String {
        return Loc.tr("UI", "Widgets.Actions.BinConfirm", p1, fallback: "Plural format key: Widgets.Actions.BinConfirm")
      }
      public static let changeWidgetType = Loc.tr("UI", "Widgets.Actions.ChangeWidgetType", fallback: "Change Widget Type")
      public static let emptyBin = Loc.tr("UI", "Widgets.Actions.EmptyBin", fallback: "Empty Bin")
      public static let newObject = Loc.tr("UI", "Widgets.Actions.NewObject", fallback: "New Object")
      public static let removeWidget = Loc.tr("UI", "Widgets.Actions.RemoveWidget", fallback: "Remove Widget")
      public static let seeAllObjects = Loc.tr("UI", "Widgets.Actions.SeeAllObjects", fallback: "See all objects")
    }
    public enum Empty {
      public static let createObject = Loc.tr("UI", "Widgets.Empty.CreateObject", fallback: "Create Object")
      public static let title = Loc.tr("UI", "Widgets.Empty.Title", fallback: "There are no objects here")
    }
    public enum Layout {
      public enum CompactList {
        public static let description = Loc.tr("UI", "Widgets.Layout.CompactList.Description", fallback: "Widget with a compact list view")
        public static let title = Loc.tr("UI", "Widgets.Layout.CompactList.Title", fallback: "Сompact list")
      }
      public enum Link {
        public static let description = Loc.tr("UI", "Widgets.Layout.Link.Description", fallback: "Compact widget view")
        public static let title = Loc.tr("UI", "Widgets.Layout.Link.Title", fallback: "Link")
      }
      public enum List {
        public static let description = Loc.tr("UI", "Widgets.Layout.List.Description", fallback: "Widget with a list view")
        public static let title = Loc.tr("UI", "Widgets.Layout.List.Title", fallback: "List")
      }
      public enum Screen {
        public static let title = Loc.tr("UI", "Widgets.Layout.Screen.Title", fallback: "Widget type")
      }
      public enum Tree {
        public static let description = Loc.tr("UI", "Widgets.Layout.Tree.Description", fallback: "Widget with a hierarchical structure")
        public static let title = Loc.tr("UI", "Widgets.Layout.Tree.Title", fallback: "Tree")
      }
      public enum View {
        public static let description = Loc.tr("UI", "Widgets.Layout.View.Description", fallback: "Widget with a Query or Collection layout")
        public static let title = Loc.tr("UI", "Widgets.Layout.View.Title", fallback: "View")
      }
    }
    public enum Library {
      public enum RecentlyEdited {
        public static let name = Loc.tr("UI", "Widgets.Library.RecentlyEdited.Name", fallback: "Recently edited")
      }
      public enum RecentlyOpened {
        public static let description = Loc.tr("UI", "Widgets.Library.RecentlyOpened.Description", fallback: "On this device")
        public static let name = Loc.tr("UI", "Widgets.Library.RecentlyOpened.Name", fallback: "Recently opened")
      }
    }
    public enum Source {
      public static let library = Loc.tr("UI", "Widgets.Source.Library", fallback: "System")
      public static let objects = Loc.tr("UI", "Widgets.Source.Objects", fallback: "Your objects")
      public static let suggested = Loc.tr("UI", "Widgets.Source.Suggested", fallback: "Suggested")
    }
    public enum System {
      public enum DeleteAlert {
        public static let message = Loc.tr("UI", "Widgets.System.DeleteAlert.message", fallback: "We’ve redesigned how widgets work, and this widget is no longer supported. Once deleted, this widget cannot be restored.")
        public static let title = Loc.tr("UI", "Widgets.System.DeleteAlert.title", fallback: "This Widget Cannot Be Restored")
      }
    }
  }
  public static let collaboration = Loc.tr("Workspace", "Collaboration", fallback: "Collaboration")
  public static let createChat = Loc.tr("Workspace", "CreateChat", fallback: "Create Chat")
  public static let invite = Loc.tr("Workspace", "Invite", fallback: "Invite")
  public static let joinSpace = Loc.tr("Workspace", "Join Space", fallback: "Join Space")
  public static let joinSpaceButton = Loc.tr("Workspace", "Join Space Button", fallback: "Join Space Button")
  public static let members = Loc.tr("Workspace", "Members", fallback: "Members")
  public static let membership = Loc.tr("Workspace", "Membership", fallback: "Membership")
  public static let newProperty = Loc.tr("Workspace", "NewProperty", fallback: "New Property")
  public static let note = Loc.tr("Workspace", "Note", fallback: "Note")
  public static let notifications = Loc.tr("Workspace", "Notifications", fallback: "Notifications")
  public static let page = Loc.tr("Workspace", "Page", fallback: "Page")
  public static let pages = Loc.tr("Workspace", "Pages", fallback: "Pages")
  public static let properties = Loc.tr("Workspace", "Properties", fallback: "Properties")
  public static let propertiesFormats = Loc.tr("Workspace", "Properties formats", fallback: "Properties formats")
  public static let shared = Loc.tr("Workspace", "Shared", fallback: "Shared")
  public static let task = Loc.tr("Workspace", "Task", fallback: "Task")
  public enum Chat {
    public static let editMessage = Loc.tr("Workspace", "Chat.EditMessage", fallback: "Edit Message")
    public static let newMessages = Loc.tr("Workspace", "Chat.NewMessages", fallback: "New Messages")
    public static func replyTo(_ p1: Any) -> String {
      return Loc.tr("Workspace", "Chat.ReplyTo", String(describing: p1), fallback: "Reply to %@")
    }
    public enum AttachedObject {
      public static let attach = Loc.tr("Workspace", "Chat.AttachedObject.Attach", fallback: "Attach")
    }
    public enum AttachmentsError {
      public static let fileCreationFailed = Loc.tr("Workspace", "Chat.AttachmentsError.fileCreationFailed", fallback: "Failed to create file. Try again.")
      public static let invalidFile = Loc.tr("Workspace", "Chat.AttachmentsError.invalidFile", fallback: "Invalid file. Try again")
      public static func limitExceeded(_ p1: Int) -> String {
        return Loc.tr("Workspace", "Chat.AttachmentsError.LimitExceeded", p1, fallback: "Plural format key: Chat.AttachmentsError.LimitExceeded")
      }
    }
    public enum CreateObject {
      public enum Dismiss {
        public static let message = Loc.tr("Workspace", "Chat.CreateObject.Dismiss.Message", fallback: "If you leave it, all your changes will be lost.")
        public static let ok = Loc.tr("Workspace", "Chat.CreateObject.Dismiss.Ok", fallback: "Yes, close")
        public static let title = Loc.tr("Workspace", "Chat.CreateObject.Dismiss.Title", fallback: "Are you sure you want to close this screen?")
      }
    }
    public enum DeleteMessage {
      public static let description = Loc.tr("Workspace", "Chat.DeleteMessage.Description", fallback: "It cannot be restored after confirmation")
      public static let title = Loc.tr("Workspace", "Chat.DeleteMessage.Title", fallback: "Delete this message?")
    }
    public enum Empty {
      public static let title = Loc.tr("Workspace", "Chat.Empty.Title", fallback: "You just created a chat")
      public enum Button {
        public static let title = Loc.tr("Workspace", "Chat.Empty.Button.title", fallback: "Invite members")
      }
      public enum Editor {
        public static let description = Loc.tr("Workspace", "Chat.Empty.Editor.Description", fallback: "Write the first message to spark it up!")
      }
      public enum Owner {
        public static let description = Loc.tr("Workspace", "Chat.Empty.Owner.Description", fallback: "Invite people and start the conversation!")
      }
    }
    public enum FileSyncError {
      public enum IncompatibleVersion {
        public static let action = Loc.tr("Workspace", "Chat.FileSyncError.IncompatibleVersion.Action", fallback: "Update App")
        public static let description = Loc.tr("Workspace", "Chat.FileSyncError.IncompatibleVersion.Description", fallback: "This version doesn’t support sending files or images. Update the app to share media in chats.")
        public static let title = Loc.tr("Workspace", "Chat.FileSyncError.IncompatibleVersion.Title", fallback: "Incompatible Version")
      }
      public enum Network {
        public static let description = Loc.tr("Workspace", "Chat.FileSyncError.Network.description", fallback: "We couldn’t connect right now. This may be due to no internet or a temporary sync issue. We’ll keep trying in the background.")
        public static let done = Loc.tr("Workspace", "Chat.FileSyncError.Network.done", fallback: "Got it")
        public static let title = Loc.tr("Workspace", "Chat.FileSyncError.Network.title", fallback: "Network Error")
      }
    }
    public enum Participant {
      public static let badge = Loc.tr("Workspace", "Chat.Participant.Badge", fallback: "(You)")
    }
    public enum Reactions {
      public enum Empty {
        public static let subtitle = Loc.tr("Workspace", "Chat.Reactions.Empty.Subtitle", fallback: "Probably someone has just removed the reaction or technical issue happened")
        public static let title = Loc.tr("Workspace", "Chat.Reactions.Empty.Title", fallback: "No reactions yet")
      }
    }
    public enum Reply {
      public static func attachments(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Chat.Reply.Attachments", String(describing: p1), fallback: "Attachments (%@)")
      }
      public static func files(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Chat.Reply.Files", String(describing: p1), fallback: "Files (%@)")
      }
      public static func images(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Chat.Reply.Images", String(describing: p1), fallback: "Images (%@)")
      }
    }
    public enum SendLimitAlert {
      public static let message = Loc.tr("Workspace", "Chat.SendLimitAlert.Message", fallback: "Looks like you're sending messages at lightning speed. Give it a sec before your next one.")
      public static let title = Loc.tr("Workspace", "Chat.SendLimitAlert.Title", fallback: "Hold up! Turbo typing detected!")
    }
  }
  public enum ChatTip {
    public enum Step1 {
      public static let description = Loc.tr("Workspace", "ChatTip.Step1.Description", fallback: "Anytype now supports real-time chat in Shared Channels — so your thoughts and dialogues can grow together.")
      public static let title = Loc.tr("Workspace", "ChatTip.Step1.Title", fallback: "Ideas need conversations")
    }
    public enum Step2 {
      public static let description = Loc.tr("Workspace", "ChatTip.Step2.Description", fallback: "Spaces and Chats now show live previews and updates — one place to follow everything that matters.")
      public static let title = Loc.tr("Workspace", "ChatTip.Step2.Title", fallback: "Your Vault just leveled up")
    }
    public enum Step3 {
      public static let description = Loc.tr("Workspace", "ChatTip.Step3.Description", fallback: "Share ideas, drop docs, edit together — everything flows in real time.")
      public static let title = Loc.tr("Workspace", "ChatTip.Step3.Title", fallback: "Chats that do more")
    }
    public enum Step4 {
      public static let description = Loc.tr("Workspace", "ChatTip.Step4.Description", fallback: "Your pages, lists, and files — structured, surfaced, and always within reach.")
      public static let title = Loc.tr("Workspace", "ChatTip.Step4.Title", fallback: "Everything in Its Right Place")
    }
  }
  public enum Collection {
    public enum View {
      public enum Empty {
        public static let subtitle = Loc.tr("Workspace", "Collection.View.Empty.Subtitle", fallback: "Create first object to continue")
        public static let title = Loc.tr("Workspace", "Collection.View.Empty.Title", fallback: "No objects")
        public enum Button {
          public static let title = Loc.tr("Workspace", "Collection.View.Empty.Button.Title", fallback: "Create object")
        }
      }
    }
  }
  public enum Content {
    public enum Audio {
      public static let upload = Loc.tr("Workspace", "Content.Audio.Upload", fallback: "Upload audio")
    }
    public enum Bookmark {
      public static let add = Loc.tr("Workspace", "Content.Bookmark.Add", fallback: "Add a web bookmark")
      public static let loading = Loc.tr("Workspace", "Content.Bookmark.Loading", fallback: "Loading, please wait...")
    }
    public enum Common {
      public static let error = Loc.tr("Workspace", "Content.Common.Error", fallback: "Something went wrong, try again")
      public static let uploading = Loc.tr("Workspace", "Content.Common.Uploading", fallback: "Uploading...")
    }
    public enum DataView {
      public enum InlineCollection {
        public static let subtitle = Loc.tr("Workspace", "Content.DataView.InlineCollection.Subtitle", fallback: "Inline collection")
        public static let untitled = Loc.tr("Workspace", "Content.DataView.InlineCollection.Untitled", fallback: "Untitled collection")
      }
      public enum InlineSet {
        public static let noData = Loc.tr("Workspace", "Content.DataView.InlineSet.NoData", fallback: "No data")
        public static let noSource = Loc.tr("Workspace", "Content.DataView.InlineSet.NoSource", fallback: "No source")
        public static let subtitle = Loc.tr("Workspace", "Content.DataView.InlineSet.Subtitle", fallback: "Inline query")
        public static let untitled = Loc.tr("Workspace", "Content.DataView.InlineSet.Untitled", fallback: "Untitled query")
        public enum Toast {
          public static let failure = Loc.tr("Workspace", "Content.DataView.InlineSet.Toast.Failure", fallback: "This inline query doesn’t have a source")
        }
      }
    }
    public enum File {
      public static let upload = Loc.tr("Workspace", "Content.File.Upload", fallback: "Upload a file")
    }
    public enum Picture {
      public static let upload = Loc.tr("Workspace", "Content.Picture.Upload", fallback: "Upload a picture")
    }
    public enum Video {
      public static let upload = Loc.tr("Workspace", "Content.Video.Upload", fallback: "Upload a video")
    }
  }
  public enum EditSet {
    public enum Popup {
      public enum Filter {
        public enum Condition {
          public enum Checkbox {
            public static let equal = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Checkbox.Equal", fallback: "Is")
            public static let notEqual = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Checkbox.NotEqual", fallback: "Is not")
          }
          public enum Date {
            public static let after = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Date.After", fallback: "Is after")
            public static let before = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Date.Before", fallback: "Is before")
            public static let equal = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Date.Equal", fallback: "Is")
            public static let `in` = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Date.In", fallback: "Is within")
            public static let onOrAfter = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Date.OnOrAfter", fallback: "Is on or after")
            public static let onOrBefore = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Date.OnOrBefore", fallback: "Is on or before")
          }
          public enum General {
            public static let empty = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.General.Empty", fallback: "Is empty")
            public static let `none` = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.General.None", fallback: "All")
            public static let notEmpty = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.General.NotEmpty", fallback: "Is not empty")
          }
          public enum Number {
            public static let equal = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Number.Equal", fallback: "Is equal to")
            public static let greater = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Number.Greater", fallback: "Is greater than")
            public static let greaterOrEqual = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Number.GreaterOrEqual", fallback: "Is greater than or equal to")
            public static let less = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Number.Less", fallback: "Is less than")
            public static let lessOrEqual = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Number.LessOrEqual", fallback: "Is less than or equal to")
            public static let notEqual = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Number.NotEqual", fallback: "Is not equal to")
          }
          public enum Selected {
            public static let allIn = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Selected.AllIn", fallback: "Has all of")
            public static let `in` = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Selected.In", fallback: "Has any of")
            public static let notIn = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Selected.NotIn", fallback: "Has none of")
          }
          public enum Text {
            public static let equal = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Text.Equal", fallback: "Is")
            public static let like = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Text.Like", fallback: "Contains")
            public static let notEqual = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Text.NotEqual", fallback: "Is not")
            public static let notLike = Loc.tr("Workspace", "EditSet.Popup.Filter.Condition.Text.NotLike", fallback: "Doesn't contain")
          }
        }
        public enum Date {
          public enum Option {
            public static let currentMonth = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.CurrentMonth", fallback: "Current month")
            public static let currentWeek = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.CurrentWeek", fallback: "Current week")
            public static let currentYear = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.CurrentYear", fallback: "Current year")
            public static let exactDate = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.ExactDate", fallback: "Exact date")
            public static let lastMonth = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.LastMonth", fallback: "Last month")
            public static let lastWeek = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.LastWeek", fallback: "Last week")
            public static let lastYear = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.LastYear", fallback: "Last year")
            public static let nextMonth = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NextMonth", fallback: "Next month")
            public static let nextWeek = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NextWeek", fallback: "Next week")
            public static let nextYear = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NextYear", fallback: "Next year")
            public static let numberOfDaysAgo = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo", fallback: "Number of days ago")
            public static let numberOfDaysFromNow = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow", fallback: "Number of days from now")
            public static let today = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.Today", fallback: "Today")
            public static let tomorrow = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.Tomorrow", fallback: "Tomorrow")
            public static let yesterday = Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.Yesterday", fallback: "Yesterday")
            public enum NumberOfDaysAgo {
              public static func short(_ p1: Int) -> String {
                return Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo.Short", p1, fallback: "Plural format key: EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo.Short")
              }
            }
            public enum NumberOfDaysFromNow {
              public static func short(_ p1: Int) -> String {
                return Loc.tr("Workspace", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow.Short", p1, fallback: "Plural format key: EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow.Short")
              }
            }
          }
        }
        public enum Value {
          public static let checked = Loc.tr("Workspace", "EditSet.Popup.Filter.Value.Checked", fallback: "Checked")
          public static let unchecked = Loc.tr("Workspace", "EditSet.Popup.Filter.Value.Unchecked", fallback: "Unchecked")
        }
      }
      public enum Filters {
        public enum EmptyView {
          public static let title = Loc.tr("Workspace", "EditSet.Popup.Filters.EmptyView.Title", fallback: "No filters here. You can add some")
        }
        public enum NavigationView {
          public static let title = Loc.tr("Workspace", "EditSet.Popup.Filters.NavigationView.Title", fallback: "Filters")
        }
        public enum TextView {
          public static let placeholder = Loc.tr("Workspace", "EditSet.Popup.Filters.TextView.Placeholder", fallback: "Value")
        }
      }
      public enum Sort {
        public enum Add {
          public static let searchPlaceholder = Loc.tr("Workspace", "EditSet.Popup.Sort.Add.SearchPlaceholder", fallback: "Сhoose a property to sort")
        }
        public enum EmptyTypes {
          public static let end = Loc.tr("Workspace", "EditSet.Popup.Sort.EmptyTypes.End", fallback: "On bottom")
          public static let start = Loc.tr("Workspace", "EditSet.Popup.Sort.EmptyTypes.Start", fallback: "On top")
          public enum Section {
            public static let title = Loc.tr("Workspace", "EditSet.Popup.Sort.EmptyTypes.Section.Title", fallback: "Show empty values")
          }
        }
        public enum Types {
          public static let ascending = Loc.tr("Workspace", "EditSet.Popup.Sort.Types.Ascending", fallback: "Ascending")
          public static let descending = Loc.tr("Workspace", "EditSet.Popup.Sort.Types.Descending", fallback: "Descending")
        }
      }
      public enum Sorts {
        public enum EmptyView {
          public static let title = Loc.tr("Workspace", "EditSet.Popup.Sorts.EmptyView.Title", fallback: "No sorts here. You can add some")
        }
        public enum NavigationView {
          public static let title = Loc.tr("Workspace", "EditSet.Popup.Sorts.NavigationView.Title", fallback: "Sorts")
        }
      }
    }
  }
  public enum Editor {
    public enum LinkToObject {
      public static let linkedTo = Loc.tr("Workspace", "Editor.LinkToObject.LinkedTo", fallback: "Linked to")
      public static let pasteFromClipboard = Loc.tr("Workspace", "Editor.LinkToObject.PasteFromClipboard", fallback: "Paste from clipboard")
      public static let removeLink = Loc.tr("Workspace", "Editor.LinkToObject.RemoveLink", fallback: "Remove link")
      public static let searchPlaceholder = Loc.tr("Workspace", "Editor.LinkToObject.SearchPlaceholder", fallback: "Paste link or search objects")
    }
    public enum MovingState {
      public static let scrollToSelectedPlace = Loc.tr("Workspace", "Editor.MovingState.ScrollToSelectedPlace", fallback: "Scroll to select a place")
    }
    public enum Toast {
      public static let linkedTo = Loc.tr("Workspace", "Editor.Toast.LinkedTo", fallback: "linked to")
      public static let movedTo = Loc.tr("Workspace", "Editor.Toast.MovedTo", fallback: "Block moved to")
    }
  }
  public enum EditorSet {
    public enum View {
      public enum Not {
        public enum Supported {
          public static let title = Loc.tr("Workspace", "EditorSet.View.Not.Supported.Title", fallback: "Unsupported")
        }
      }
    }
  }
  public enum Fields {
    public static let addToType = Loc.tr("Workspace", "Fields.addToType", fallback: "Add to the current type")
    public static func created(_ p1: Any) -> String {
      return Loc.tr("Workspace", "Fields.Created", String(describing: p1), fallback: "Property ‘%@’ has been created")
    }
    public static let foundInObjects = Loc.tr("Workspace", "Fields.foundInObjects", fallback: "Found in objects")
    public static let local = Loc.tr("Workspace", "Fields.local", fallback: "Local")
    public static let menu = Loc.tr("Workspace", "Fields.menu", fallback: "Properties panel")
    public static let missingInfo = Loc.tr("Workspace", "Fields.missingInfo", fallback: "These properties exist in some objects but aren’t part of the Type. Add them to make them appear in all objects of this Type.")
    public static let removeFromObject = Loc.tr("Workspace", "Fields.removeFromObject", fallback: "Remove from the object")
    public static func updated(_ p1: Any) -> String {
      return Loc.tr("Workspace", "Fields.Updated", String(describing: p1), fallback: "Property ‘%@’ has been updated")
    }
  }
  public enum Membership {
    public static let emailValidation = Loc.tr("Workspace", "Membership.EmailValidation", fallback: "Enter the code sent to your email")
    public static let unavailable = Loc.tr("Workspace", "Membership.unavailable", fallback: "This tier is not available in the app. We know it's not ideal.")
    public enum Ad {
      public static let subtitle = Loc.tr("Workspace", "Membership.Ad.Subtitle", fallback: "Joining Anytype network means contributing to its story")
      public static let title = Loc.tr("Workspace", "Membership.Ad.Title", fallback: "Membership")
    }
    public enum Banner {
      public static let subtitle1 = Loc.tr("Workspace", "Membership.Banner.Subtitle1", fallback: "As a valued member your voice matters! Engage in exclusive events, shape strategic choices, and influence our roadmap.")
      public static let subtitle2 = Loc.tr("Workspace", "Membership.Banner.Subtitle2", fallback: "Members enjoy higher backup storage & sync limits, invitations for multiple guests to collaborate in shared spaces, and a unique identity on the Anytype Network.")
      public static let subtitle3 = Loc.tr("Workspace", "Membership.Banner.Subtitle3", fallback: "Your contribution supports our team and endorses our vision of a user-owned, secure, and collaborative digital network.")
      public static let subtitle4 = Loc.tr("Workspace", "Membership.Banner.Subtitle4", fallback: "Our network's value exceeds the sum of its parts. Your membership sustains the infrastructure for its growth which underpins this network.")
      public static let title1 = Loc.tr("Workspace", "Membership.Banner.Title1", fallback: "Build the Vision Together")
      public static let title2 = Loc.tr("Workspace", "Membership.Banner.Title2", fallback: "Unlock Member Benefits")
      public static let title3 = Loc.tr("Workspace", "Membership.Banner.Title3", fallback: "Support Digital Independence")
      public static let title4 = Loc.tr("Workspace", "Membership.Banner.Title4", fallback: "Invest in Connectivity")
    }
    public enum Email {
      public static let body = Loc.tr("Workspace", "Membership.Email.Body", fallback: "Hello Anytype team! I would like to extend my current membership for more (please choose an option):\n- Extra remote storage\n- More space editors\n- Additional shared spaces\nSpecifically,\nPlease provide specific details of your needs here.")
    }
    public enum EmailForm {
      public static let subtitle = Loc.tr("Workspace", "Membership.EmailForm.Subtitle", fallback: "It is not linked to your account in any way.")
      public static let title = Loc.tr("Workspace", "Membership.EmailForm.Title", fallback: "Get updates and enjoy free perks!")
    }
    public enum Feature {
      public static let localName = Loc.tr("Workspace", "Membership.Feature.LocalName", fallback: "Local, non-unique name")
      public static func sharedSpaces(_ p1: Int) -> String {
        return Loc.tr("Workspace", "Membership.Feature.SharedSpaces", p1, fallback: "Plural format key: Membership.Feature.SharedSpaces")
      }
      public static func spaceWriters(_ p1: Int) -> String {
        return Loc.tr("Workspace", "Membership.Feature.SpaceWriters", p1, fallback: "Plural format key: Membership.Feature.SpaceWriters")
      }
      public static func storageGB(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Membership.Feature.StorageGB", String(describing: p1), fallback: "%@ GB of backup & sync space on the Anytype network")
      }
      public static func uniqueName(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Membership.Feature.UniqueName", String(describing: p1), fallback: "Unique Network name (%@+ characters)")
      }
      public static let unlimitedViewers = Loc.tr("Workspace", "Membership.Feature.UnlimitedViewers", fallback: "Unlimited Viewers for shared spaces")
      public static func viewers(_ p1: Int) -> String {
        return Loc.tr("Workspace", "Membership.Feature.Viewers", p1, fallback: "Plural format key: Membership.Feature.Viewers")
      }
    }
    public enum Legal {
      public static let alreadyPurchasedTier = Loc.tr("Workspace", "Membership.Legal.AlreadyPurchasedTier", fallback: "Already purchased tier?")
      public static let details = Loc.tr("Workspace", "Membership.Legal.Details", fallback: "Membership plan details")
      public static let letUsKnow = Loc.tr("Workspace", "Membership.Legal.LetUsKnow", fallback: "Please let us know here.")
      public static let privacy = Loc.tr("Workspace", "Membership.Legal.Privacy", fallback: "Privacy policy")
      public static let restorePurchases = Loc.tr("Workspace", "Membership.Legal.RestorePurchases", fallback: "Restore purchases")
      public static let terms = Loc.tr("Workspace", "Membership.Legal.Terms", fallback: "Terms and conditions")
      public static let wouldYouLike = Loc.tr("Workspace", "Membership.Legal.WouldYouLike", fallback: "Would you like to use Anytype for business, education, etc.?")
    }
    public enum ManageTier {
      public static let android = Loc.tr("Workspace", "Membership.ManageTier.Android", fallback: "You can manage tier on Android platform")
      public static let appleId = Loc.tr("Workspace", "Membership.ManageTier.AppleId", fallback: "You can manage tier on another AppleId account")
      public static let desktop = Loc.tr("Workspace", "Membership.ManageTier.Desktop", fallback: "You can manage tier on Desktop platform")
    }
    public enum NameForm {
      public static let subtitle = Loc.tr("Workspace", "Membership.NameForm.Subtitle", fallback: "This is your unique name on the Anytype network, confirming your Membership. It acts as your personal domain and cannot be changed.")
      public static let title = Loc.tr("Workspace", "Membership.NameForm.Title", fallback: "Pick your unique name")
      public static let validated = Loc.tr("Workspace", "Membership.NameForm.Validated", fallback: "This name is up for grabs")
      public static let validating = Loc.tr("Workspace", "Membership.NameForm.Validating", fallback: "Wait a second...")
    }
    public enum Payment {
      public static let appleSubscription = Loc.tr("Workspace", "Membership.Payment.Apple subscription", fallback: "Apple subscription")
      public static let card = Loc.tr("Workspace", "Membership.Payment.Card", fallback: "Card")
      public static let crypto = Loc.tr("Workspace", "Membership.Payment.Crypto", fallback: "Crypto")
      public static let googleSubscription = Loc.tr("Workspace", "Membership.Payment.Google subscription", fallback: "Google subscription")
    }
    public enum Success {
      public static let curiosity = Loc.tr("Workspace", "Membership.Success.Curiosity", fallback: "Big cheers for your curiosity!")
      public static let support = Loc.tr("Workspace", "Membership.Success.Support", fallback: "Big cheers for your support!")
      public static func title(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Membership.Success.Title", String(describing: p1), fallback: "Welcome to the network, %@")
      }
    }
    public enum Upgrade {
      public static let button = Loc.tr("Workspace", "Membership.Upgrade.Button", fallback: "Contact Anytype Team")
      public static let moreMembers = Loc.tr("Workspace", "Membership.Upgrade.MoreMembers", fallback: "Upgrade to add more members")
      public static let moreSpaces = Loc.tr("Workspace", "Membership.Upgrade.MoreSpaces", fallback: "Upgrade to add more spaces")
      public static let noMoreEditors = Loc.tr("Workspace", "Membership.Upgrade.NoMoreEditors", fallback: "You can’t add more editors")
      public static let noMoreMembers = Loc.tr("Workspace", "Membership.Upgrade.NoMoreMembers", fallback: "You can’t add more members")
      public static func spacesLimit(_ p1: Int) -> String {
        return Loc.tr("Workspace", "Membership.Upgrade.SpacesLimit", p1, fallback: "Plural format key: Membership.Upgrade.SpacesLimit")
      }
      public static let text = Loc.tr("Workspace", "Membership.Upgrade.Text", fallback: "Reach us for extra storage, space editors, or more shared spaces. Anytype team will provide details and conditions tailored to your needs.")
      public static let title = Loc.tr("Workspace", "Membership.Upgrade.Title", fallback: "Membership upgrade")
    }
  }
  public enum MembershipServiceError {
    public static let invalidBillingIdFormat = Loc.tr("Workspace", "MembershipServiceError.invalidBillingIdFormat", fallback: "Internal problem with billing format, we are working on this. Try again later or contact support.")
    public static let tierNotFound = Loc.tr("Workspace", "MembershipServiceError.tierNotFound", fallback: "Not found tier data, restart app and try again")
  }
  public enum Message {
    public static let edited = Loc.tr("Workspace", "Message.edited", fallback: "edited")
    public enum Action {
      public static let addReaction = Loc.tr("Workspace", "Message.Action.AddReaction", fallback: "Add Reaction")
      public static let copyPlainText = Loc.tr("Workspace", "Message.Action.CopyPlainText", fallback: "Copy Plain Text")
      public static let reply = Loc.tr("Workspace", "Message.Action.Reply", fallback: "Reply")
      public static let unread = Loc.tr("Workspace", "Message.Action.Unread", fallback: "Mark Unread")
    }
    public enum ChatTitle {
      public static let placeholder = Loc.tr("Workspace", "Message.ChatTitle.Placeholder", fallback: "Untitled Chat")
    }
    public enum Input {
      public enum Chat {
        public static let emptyPlaceholder = Loc.tr("Workspace", "Message.Input.Chat.EmptyPlaceholder", fallback: "Write a message...")
      }
      public enum Stream {
        public static let emptyPlaceholder = Loc.tr("Workspace", "Message.Input.Stream.EmptyPlaceholder", fallback: "Broadcast")
      }
    }
  }
  public enum Object {
    public enum Deleted {
      public static let placeholder = Loc.tr("Workspace", "Object.Deleted.Placeholder", fallback: "Deleted object")
    }
  }
  public enum ObjectType {
    public static func addedToLibrary(_ p1: Any) -> String {
      return Loc.tr("Workspace", "ObjectType.AddedToLibrary", String(describing: p1), fallback: "Type ‘%@’ has been created")
    }
    public static let deletedName = Loc.tr("Workspace", "ObjectType.DeletedName", fallback: "Deleted type")
    public static let editingType = Loc.tr("Workspace", "ObjectType.editingType", fallback: "You're editing type")
    public static let fallbackDescription = Loc.tr("Workspace", "ObjectType.fallbackDescription", fallback: "Blank canvas with no title")
    public static let myTypes = Loc.tr("Workspace", "ObjectType.MyTypes", fallback: "My Types")
    public static let search = Loc.tr("Workspace", "ObjectType.Search", fallback: "Search for Type")
    public static let searchOrInstall = Loc.tr("Workspace", "ObjectType.SearchOrInstall", fallback: "Search or install a new type")
  }
  public enum ParticipantRemoveNotification {
    public static func text(_ p1: Any) -> String {
      return Loc.tr("Workspace", "ParticipantRemoveNotification.Text", String(describing: p1), fallback: "You were removed from **%@** space, or the space has been deleted by the owner.")
    }
  }
  public enum ParticipantRequestApprovedNotification {
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Workspace", "ParticipantRequestApprovedNotification.Text", String(describing: p1), String(describing: p2), fallback: "Your request to join the **%@** space has been approved with **%@** access rights. The space will be available on your device soon.")
    }
  }
  public enum ParticipantRequestDeclineNotification {
    public static func text(_ p1: Any) -> String {
      return Loc.tr("Workspace", "ParticipantRequestDeclineNotification.Text", String(describing: p1), fallback: "Your request to join the **%@** space has been declined.")
    }
  }
  public enum PermissionChangeNotification {
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Workspace", "PermissionChangeNotification.Text", String(describing: p1), String(describing: p2), fallback: "Your access rights were changed to **%@** in the **%@** space.")
    }
  }
  public enum Publishing {
    public enum Error {
      public static let noDomain = Loc.tr("Workspace", "Publishing.Error.NoDomain", fallback: "Failed to load your domain. Please try again.")
      public static let noObjectData = Loc.tr("Workspace", "Publishing.Error.NoObjectData", fallback: "Failed to load object data. Please try again.")
    }
    public enum Url {
      public static let placeholder = Loc.tr("Workspace", "Publishing.URL.placeholder", fallback: "insert-page-name-here")
    }
    public enum WebBanner {
      public static let liveOnWeb = Loc.tr("Workspace", "Publishing.WebBanner.LiveOnWeb", fallback: "This object is live on the web.")
      public static let viewSite = Loc.tr("Workspace", "Publishing.WebBanner.ViewSite", fallback: "View site ↗︎")
    }
  }
  public enum PublishingToWeb {
    public static let published = Loc.tr("Workspace", "PublishingToWeb.published", fallback: "Successfully published")
    public static let unpublished = Loc.tr("Workspace", "PublishingToWeb.unpublished", fallback: "Successfully unpublished")
    public static let updated = Loc.tr("Workspace", "PublishingToWeb.updated", fallback: "Successfully updated")
  }
  public enum PushNotifications {
    public enum DisabledAlert {
      public static let description = Loc.tr("Workspace", "PushNotifications.DisabledAlert.description", fallback: "It looks like you didn’t allow notifications. That means you won’t see new messages, mentions, or invites. Go to settings to turn them on.")
      public static let title = Loc.tr("Workspace", "PushNotifications.DisabledAlert.title", fallback: "Notifications are still turned off")
      public enum Skip {
        public static let button = Loc.tr("Workspace", "PushNotifications.DisabledAlert.Skip.button", fallback: "Skip for now")
      }
    }
    public enum Message {
      public enum Attachment {
        public static let title = Loc.tr("Workspace", "PushNotifications.Message.Attachment.title", fallback: "Attachment")
      }
    }
    public enum RequestAlert {
      public static let description = Loc.tr("Workspace", "PushNotifications.RequestAlert.Description", fallback: "Get notified instantly when someone messages or mentions you in your spaces.")
      public static let notificationTitle = Loc.tr("Workspace", "PushNotifications.RequestAlert.NotificationTitle", fallback: "New Message")
      public static let primaryButton = Loc.tr("Workspace", "PushNotifications.RequestAlert.PrimaryButton", fallback: "Enable notifications")
      public static let secondaryButton = Loc.tr("Workspace", "PushNotifications.RequestAlert.SecondaryButton", fallback: "Not now")
      public static let title = Loc.tr("Workspace", "PushNotifications.RequestAlert.Title", fallback: "Turn on push notifications")
    }
    public enum Settings {
      public enum DisabledAlert {
        public static let description = Loc.tr("Workspace", "PushNotifications.Settings.DisabledAlert.description", fallback: "Receive notifications about new messages by enabling them in your device settings.")
        public static let title = Loc.tr("Workspace", "PushNotifications.Settings.DisabledAlert.title", fallback: "Notifications are disabled")
      }
      public enum Status {
        public static let title = Loc.tr("Workspace", "PushNotifications.Settings.Status.title", fallback: "Message Notifications")
      }
    }
  }
  public enum Qr {
    public enum Join {
      public static let title = Loc.tr("Workspace", "QR.join.title", fallback: "Join via QR Code")
    }
    public enum Scan {
      public enum Error {
        public static let tryAgain = Loc.tr("Workspace", "QR.scan.error.tryAgain", fallback: "Try again")
        public enum Custom {
          public static let title = Loc.tr("Workspace", "QR.scan.error.custom.title", fallback: "Scanning error")
        }
        public enum InvalidFormat {
          public static let message = Loc.tr("Workspace", "QR.scan.error.invalidFormat.message", fallback: "The scanned QR code contains URL in invalid format")
        }
        public enum InvalidQR {
          public static let title = Loc.tr("Workspace", "QR.scan.error.invalidQR.title", fallback: "Invalid QR Code")
        }
        public enum NotUrl {
          public static let message = Loc.tr("Workspace", "QR.scan.error.notUrl.message", fallback: "The scanned QR code doesn't contain a valid URL")
        }
        public enum WrongLink {
          public static let message = Loc.tr("Workspace", "QR.scan.error.wrongLink.message", fallback: "The scanned QR code contains different action")
        }
      }
    }
  }
  public enum Relation {
    public static let deleted = Loc.tr("Workspace", "Relation.Deleted", fallback: "Deleted property")
    public static let myRelations = Loc.tr("Workspace", "Relation.MyRelations", fallback: "My properties")
    public enum Create {
      public enum Row {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Workspace", "Relation.Create.Row.title", String(describing: p1), fallback: "Create “%@”")
        }
      }
      public enum Textfield {
        public static let placeholder = Loc.tr("Workspace", "Relation.Create.Textfield.placeholder", fallback: "Enter name...")
      }
    }
    public enum Delete {
      public enum Alert {
        public static let description = Loc.tr("Workspace", "Relation.Delete.Alert.Description", fallback: "The option will be permanently removed from your space.")
        public static let title = Loc.tr("Workspace", "Relation.Delete.Alert.Title", fallback: "Are you sure?")
      }
    }
    public enum EmptyState {
      public static let description = Loc.tr("Workspace", "Relation.EmptyState.description", fallback: "Nothing found. Create first option to start.")
      public static let title = Loc.tr("Workspace", "Relation.EmptyState.title", fallback: "No options")
      public enum Blocked {
        public static let title = Loc.tr("Workspace", "Relation.EmptyState.Blocked.title", fallback: "The property is empty")
      }
    }
    public enum Format {
      public enum Checkbox {
        public static let title = Loc.tr("Workspace", "Relation.Format.Checkbox.Title", fallback: "Checkbox")
      }
      public enum Date {
        public static let title = Loc.tr("Workspace", "Relation.Format.Date.Title", fallback: "Date")
      }
      public enum Email {
        public static let title = Loc.tr("Workspace", "Relation.Format.Email.Title", fallback: "Email")
      }
      public enum FileMedia {
        public static let title = Loc.tr("Workspace", "Relation.Format.FileMedia.Title", fallback: "File & Media")
      }
      public enum Number {
        public static let title = Loc.tr("Workspace", "Relation.Format.Number.Title", fallback: "Number")
      }
      public enum Object {
        public static let title = Loc.tr("Workspace", "Relation.Format.Object.Title", fallback: "Relation object")
      }
      public enum Phone {
        public static let title = Loc.tr("Workspace", "Relation.Format.Phone.Title", fallback: "Phone number")
      }
      public enum Status {
        public static let title = Loc.tr("Workspace", "Relation.Format.Status.Title", fallback: "Select")
      }
      public enum Tag {
        public static let title = Loc.tr("Workspace", "Relation.Format.Tag.Title", fallback: "Multi-select")
      }
      public enum Text {
        public static let title = Loc.tr("Workspace", "Relation.Format.Text.Title", fallback: "Text")
      }
      public enum Url {
        public static let title = Loc.tr("Workspace", "Relation.Format.Url.Title", fallback: "URL")
      }
    }
    public enum From {
      public static func type(_ p1: Any) -> String {
        return Loc.tr("Workspace", "Relation.From.Type", String(describing: p1), fallback: "From type %@")
      }
    }
    public enum ImportType {
      public static let csv = Loc.tr("Workspace", "Relation.ImportType.Csv", fallback: "CSV")
      public static let html = Loc.tr("Workspace", "Relation.ImportType.Html", fallback: "HTML")
      public static let markdown = Loc.tr("Workspace", "Relation.ImportType.Markdown", fallback: "Markdown")
      public static let notion = Loc.tr("Workspace", "Relation.ImportType.Notion", fallback: "Notion")
      public static let obsidian = Loc.tr("Workspace", "Relation.ImportType.Obsidian", fallback: "Obsidian")
      public static let protobuf = Loc.tr("Workspace", "Relation.ImportType.Protobuf", fallback: "Any-Block")
      public static let text = Loc.tr("Workspace", "Relation.ImportType.Text", fallback: "TXT")
    }
    public enum Object {
      public enum Delete {
        public enum Alert {
          public static let description = Loc.tr("Workspace", "Relation.Object.Delete.Alert.Description", fallback: "The object will be moved to Bin.")
        }
      }
    }
    public enum ObjectType {
      public enum Header {
        public static let title = Loc.tr("Workspace", "Relation.ObjectType.Header.title", fallback: "Object type:")
      }
    }
    public enum ObjectTypes {
      public enum Header {
        public static let title = Loc.tr("Workspace", "Relation.ObjectTypes.Header.title", fallback: "Object types:")
      }
    }
    public enum Origin {
      public static let api = Loc.tr("Workspace", "Relation.Origin.API", fallback: "API")
      public static let bookmark = Loc.tr("Workspace", "Relation.Origin.Bookmark", fallback: "Bookmark")
      public static let builtin = Loc.tr("Workspace", "Relation.Origin.Builtin", fallback: "Library installed")
      public static let clipboard = Loc.tr("Workspace", "Relation.Origin.Clipboard", fallback: "Clipboard")
      public static let dragAndDrop = Loc.tr("Workspace", "Relation.Origin.DragAndDrop", fallback: "Drag'n'Drop")
      public static let `import` = Loc.tr("Workspace", "Relation.Origin.Import", fallback: "Imported object")
      public static let sharingExtension = Loc.tr("Workspace", "Relation.Origin.SharingExtension", fallback: "Mobile sharing extension")
      public static let useCase = Loc.tr("Workspace", "Relation.Origin.UseCase", fallback: "Use case")
      public static let webClipper = Loc.tr("Workspace", "Relation.Origin.WebClipper", fallback: "Web clipper")
    }
    public enum View {
      public enum Create {
        public static let title = Loc.tr("Workspace", "Relation.View.Create.title", fallback: "Create option")
      }
      public enum Edit {
        public static let title = Loc.tr("Workspace", "Relation.View.Edit.title", fallback: "Edit option")
      }
      public enum Hint {
        public static let empty = Loc.tr("Workspace", "Relation.View.Hint.Empty", fallback: "empty")
      }
    }
  }
  public enum RelationAction {
    public static let callPhone = Loc.tr("Workspace", "RelationAction.CallPhone", fallback: "Call phone numbler")
    public static let copied = Loc.tr("Workspace", "RelationAction.Copied", fallback: "Copied")
    public static let copyEmail = Loc.tr("Workspace", "RelationAction.CopyEmail", fallback: "Copy email")
    public static let copyPhone = Loc.tr("Workspace", "RelationAction.CopyPhone", fallback: "Copy phone number")
    public static let openLink = Loc.tr("Workspace", "RelationAction.OpenLink", fallback: "Open link")
    public static let reloadContent = Loc.tr("Workspace", "RelationAction.ReloadContent", fallback: "Reload object content")
    public static let reloadingContent = Loc.tr("Workspace", "RelationAction.ReloadingContent", fallback: "Reloading content")
    public static let sendEmail = Loc.tr("Workspace", "RelationAction.SendEmail", fallback: "Send email")
  }
  public enum RequestToJoinNotification {
    public static let goToSpace = Loc.tr("Workspace", "RequestToJoinNotification.GoToSpace", fallback: "Go to Space")
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Workspace", "RequestToJoinNotification.Text", String(describing: p1), String(describing: p2), fallback: "**%@** requested to join the **%@** space.")
    }
    public static let viewRequest = Loc.tr("Workspace", "RequestToJoinNotification.ViewRequest", fallback: "View request")
  }
  public enum RequestToLeaveNotification {
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Workspace", "RequestToLeaveNotification.Text", String(describing: p1), String(describing: p2), fallback: "**%@** wants to leave the **%@** space.")
    }
  }
  public enum Set {
    public enum Bookmark {
      public enum Create {
        public static let placeholder = Loc.tr("Workspace", "Set.Bookmark.Create.Placeholder", fallback: "Paste link")
      }
      public enum Error {
        public static let message = Loc.tr("Workspace", "Set.Bookmark.Error.Message", fallback: "Oops - something went wrong. Please try again")
      }
    }
    public enum FeaturedRelations {
      public static let query = Loc.tr("Workspace", "Set.FeaturedRelations.Query", fallback: "Select query")
      public static let relation = Loc.tr("Workspace", "Set.FeaturedRelations.Relation", fallback: "Property:")
      public static let relationsList = Loc.tr("Workspace", "Set.FeaturedRelations.RelationsList", fallback: "Properties:")
      public static let type = Loc.tr("Workspace", "Set.FeaturedRelations.Type", fallback: "Type:")
    }
    public enum SourceType {
      public static let selectQuery = Loc.tr("Workspace", "Set.SourceType.SelectQuery", fallback: "Select query")
      public enum Cancel {
        public enum Toast {
          public static let title = Loc.tr("Workspace", "Set.SourceType.Cancel.Toast.Title", fallback: "This query can be changed on desktop only")
        }
      }
    }
    public enum TypeRelation {
      public enum ContextMenu {
        public static let changeQuery = Loc.tr("Workspace", "Set.TypeRelation.ContextMenu.ChangeQuery", fallback: "Change query")
        public static let turnIntoCollection = Loc.tr("Workspace", "Set.TypeRelation.ContextMenu.TurnIntoCollection", fallback: "Turn Query into Collection")
      }
    }
    public enum View {
      public static let unsupportedAlert = Loc.tr("Workspace", "Set.View.UnsupportedAlert", fallback: "View is unsupported on mobile")
      public enum Empty {
        public static let subtitle = Loc.tr("Workspace", "Set.View.Empty.Subtitle", fallback: "Add search query to aggregate objects with equal types and properties in a live mode")
        public static let title = Loc.tr("Workspace", "Set.View.Empty.Title", fallback: "No query selected")
      }
      public enum Kanban {
        public enum Column {
          public enum Paging {
            public enum Title {
              public static let showMore = Loc.tr("Workspace", "Set.View.Kanban.Column.Paging.Title.ShowMore", fallback: "Show more objects")
            }
          }
          public enum Settings {
            public enum Color {
              public static let title = Loc.tr("Workspace", "Set.View.Kanban.Column.Settings.Color.Title", fallback: "Column color")
            }
            public enum Hide {
              public enum Column {
                public static let title = Loc.tr("Workspace", "Set.View.Kanban.Column.Settings.Hide.Column.Title", fallback: "Hide column")
              }
            }
          }
          public enum Title {
            public static func checked(_ p1: Any) -> String {
              return Loc.tr("Workspace", "Set.View.Kanban.Column.Title.Checked", String(describing: p1), fallback: "%@ is checked")
            }
            public static let uncategorized = Loc.tr("Workspace", "Set.View.Kanban.Column.Title.Uncategorized", fallback: "Uncategorized")
            public static func unchecked(_ p1: Any) -> String {
              return Loc.tr("Workspace", "Set.View.Kanban.Column.Title.Unchecked", String(describing: p1), fallback: "%@ is unchecked")
            }
          }
        }
      }
      public enum Settings {
        public enum CardSize {
          public static let title = Loc.tr("Workspace", "Set.View.Settings.CardSize.Title", fallback: "Card size")
          public enum Large {
            public static let title = Loc.tr("Workspace", "Set.View.Settings.CardSize.Large.Title", fallback: "Large")
          }
          public enum Small {
            public static let title = Loc.tr("Workspace", "Set.View.Settings.CardSize.Small.Title", fallback: "Small")
          }
        }
        public enum GroupBackgroundColors {
          public static let title = Loc.tr("Workspace", "Set.View.Settings.GroupBackgroundColors.Title", fallback: "Color columns")
        }
        public enum GroupBy {
          public static let title = Loc.tr("Workspace", "Set.View.Settings.GroupBy.Title", fallback: "Group by")
        }
        public enum ImageFit {
          public static let title = Loc.tr("Workspace", "Set.View.Settings.ImageFit.Title", fallback: "Fit image")
        }
        public enum ImagePreview {
          public static let title = Loc.tr("Workspace", "Set.View.Settings.ImagePreview.Title", fallback: "Image preview")
        }
        public enum NoFilters {
          public static let placeholder = Loc.tr("Workspace", "Set.View.Settings.NoFilters.Placeholder", fallback: "No filters")
        }
        public enum NoRelations {
          public static let placeholder = Loc.tr("Workspace", "Set.View.Settings.NoRelations.Placeholder", fallback: "No properties")
        }
        public enum NoSorts {
          public static let placeholder = Loc.tr("Workspace", "Set.View.Settings.NoSorts.Placeholder", fallback: "No sorts")
        }
        public enum Objects {
          public enum Applied {
            public static func title(_ p1: Int) -> String {
              return Loc.tr("Workspace", "Set.View.Settings.Objects.Applied.Title", p1, fallback: "%d applied")
            }
          }
        }
      }
    }
  }
  public enum Sharing {
    public static let inputPlaceholder = Loc.tr("Workspace", "Sharing.InputPlaceholder", fallback: "Add a comment...")
    public static let sendToChat = Loc.tr("Workspace", "Sharing.SendToChat", fallback: "Send to chat")
    public static let title = Loc.tr("Workspace", "Sharing.Title", fallback: "Select Space")
    public enum Navigation {
      public static let title = Loc.tr("Workspace", "Sharing.Navigation.title", fallback: "Add to Anytype")
    }
    public enum ObjectList {
      public static let title = Loc.tr("Workspace", "Sharing.ObjectList.title", fallback: "Select destination")
    }
    public enum Tip {
      public static let title = Loc.tr("Workspace", "Sharing.Tip.Title", fallback: "Share Extension")
      public enum Button {
        public static let title = Loc.tr("Workspace", "Sharing.Tip.Button.title", fallback: "Show share menu")
      }
      public enum Steps {
        public static let _1 = Loc.tr("Workspace", "Sharing.Tip.Steps.1", fallback: "Tap the iOS sharing button")
        public static let _2 = Loc.tr("Workspace", "Sharing.Tip.Steps.2", fallback: "Scroll past the app and tap More")
        public static let _3 = Loc.tr("Workspace", "Sharing.Tip.Steps.3", fallback: "Tap Edit to find “Anytype” and tap")
      }
    }
  }
  public enum SlashMenu {
    public static let dotsDivider = Loc.tr("Workspace", "SlashMenu.DotsDivider", fallback: "Dots divider")
    public static let lineDivider = Loc.tr("Workspace", "SlashMenu.LineDivider", fallback: "Line divider")
    public static let table = Loc.tr("Workspace", "SlashMenu.Table", fallback: "Table")
    public static let tableOfContents = Loc.tr("Workspace", "SlashMenu.TableOfContents", fallback: "Table of contents")
  }
  public enum Space {
    public static func membersCount(_ p1: Int) -> String {
      return Loc.tr("Workspace", "Space.MembersCount", p1, fallback: "Plural format key: Space.MembersCount")
    }
    public enum Invite {
      public enum EditorAccess {
        public static let subtitle = Loc.tr("Workspace", "Space.Invite.EditorAccess.Subtitle", fallback: "People with link can edit and write in chat")
        public static let title = Loc.tr("Workspace", "Space.Invite.EditorAccess.Title", fallback: "Editor access")
      }
      public enum LinkDisabled {
        public static let subtitle = Loc.tr("Workspace", "Space.Invite.LinkDisabled.Subtitle", fallback: "Only already invited members have access")
        public static let title = Loc.tr("Workspace", "Space.Invite.LinkDisabled.Title", fallback: "Link disabled")
      }
      public enum RequestAccess {
        public static let subtitle = Loc.tr("Workspace", "Space.Invite.RequestAccess.Subtitle", fallback: "Owner must approve each join request")
        public static let title = Loc.tr("Workspace", "Space.Invite.RequestAccess.Title", fallback: "Request access")
      }
      public enum ViewerAccess {
        public static let subtitle = Loc.tr("Workspace", "Space.Invite.ViewerAccess.Subtitle", fallback: "People with link can view and read chat")
        public static let title = Loc.tr("Workspace", "Space.Invite.ViewerAccess.Title", fallback: "Viewer access")
      }
    }
    public enum Notifications {
      public enum Settings {
        public enum State {
          public static let all = Loc.tr("Workspace", "Space.Notifications.Settings.State.All", fallback: "All activity")
          public static let disabled = Loc.tr("Workspace", "Space.Notifications.Settings.State.Disabled", fallback: "Disable notifications")
          public static let mentions = Loc.tr("Workspace", "Space.Notifications.Settings.State.Mentions", fallback: "Mentions only")
        }
      }
    }
    public enum Status {
      public static let error = Loc.tr("Workspace", "Space.Status.Error", fallback: "Error")
      public static let loading = Loc.tr("Workspace", "Space.Status.Loading", fallback: "Loading")
      public static let missing = Loc.tr("Workspace", "Space.Status.Missing", fallback: "Missing")
      public static let ok = Loc.tr("Workspace", "Space.Status.Ok", fallback: "Ok")
      public static let remoteDeleted = Loc.tr("Workspace", "Space.Status.RemoteDeleted", fallback: "Remote Deleted")
      public static let remoteWaitingDeletion = Loc.tr("Workspace", "Space.Status.RemoteWaitingDeletion", fallback: "Waiting Deletion")
      public static let spaceActive = Loc.tr("Workspace", "Space.Status.SpaceActive", fallback: "Active")
      public static let spaceDeleted = Loc.tr("Workspace", "Space.Status.SpaceDeleted", fallback: "Deleted")
      public static let spaceJoining = Loc.tr("Workspace", "Space.Status.SpaceJoining", fallback: "Joining")
      public static let spaceRemoving = Loc.tr("Workspace", "Space.Status.SpaceRemoving", fallback: "Removing")
      public static let unknown = Loc.tr("Workspace", "Space.Status.Unknown", fallback: "Unknown")
    }
  }
  public enum SpaceCreate {
    public enum Chat {
      public static let title = Loc.tr("Workspace", "SpaceCreate.Chat.Title", fallback: "Create a chat")
    }
    public enum Space {
      public static let title = Loc.tr("Workspace", "SpaceCreate.Space.Title", fallback: "Create a space")
    }
    public enum Stream {
      public static let title = Loc.tr("Workspace", "SpaceCreate.Stream.Title", fallback: "Create a stream")
    }
  }
  public enum SpaceInvite {
    public enum Alert {
      public static let subtitle = Loc.tr("Workspace", "SpaceInvite.Alert.subtitle", fallback: "If you switch link type, your existing link will be deactivated.")
      public static let title = Loc.tr("Workspace", "SpaceInvite.Alert.title", fallback: "The current link will stop working")
    }
  }
  public enum SpaceManager {
    public static let cancelRequest = Loc.tr("Workspace", "SpaceManager.CancelRequest", fallback: "Cancel Join Request")
    public static let doNotCancel = Loc.tr("Workspace", "SpaceManager.DoNotCancel", fallback: "Do Not Cancel")
    public enum CancelRequestAlert {
      public static let title = Loc.tr("Workspace", "SpaceManager.CancelRequestAlert.Title", fallback: "You will have to send request access again")
      public static let toast = Loc.tr("Workspace", "SpaceManager.CancelRequestAlert.Toast", fallback: "The request was canceled.")
    }
  }
  public enum SpaceSettings {
    public static let deleteButton = Loc.tr("Workspace", "SpaceSettings.DeleteButton", fallback: "Delete space")
    public static let info = Loc.tr("Workspace", "SpaceSettings.Info", fallback: "Space information")
    public static let leaveButton = Loc.tr("Workspace", "SpaceSettings.LeaveButton", fallback: "Leave")
    public static let networkId = Loc.tr("Workspace", "SpaceSettings.NetworkId", fallback: "Network ID")
    public static let remoteStorage = Loc.tr("Workspace", "SpaceSettings.RemoteStorage", fallback: "Remote storage")
    public static let share = Loc.tr("Workspace", "SpaceSettings.Share", fallback: "Share")
    public static let title = Loc.tr("Workspace", "SpaceSettings.Title", fallback: "Space settings")
    public enum DeleteAlert {
      public static let message = Loc.tr("Workspace", "SpaceSettings.DeleteAlert.Message", fallback: "This space will be deleted irrevocably. You can’t undo this action.")
      public static func title(_ p1: Any) -> String {
        return Loc.tr("Workspace", "SpaceSettings.DeleteAlert.Title", String(describing: p1), fallback: "Delete ‘%@’ space")
      }
    }
    public enum LeaveAlert {
      public static func message(_ p1: Any) -> String {
        return Loc.tr("Workspace", "SpaceSettings.LeaveAlert.Message", String(describing: p1), fallback: "%@ space will be removed from your devices and you will no longer have access to it")
      }
      public static func toast(_ p1: Any) -> String {
        return Loc.tr("Workspace", "SpaceSettings.LeaveAlert.Toast", String(describing: p1), fallback: "You left the %@.")
      }
    }
  }
  public enum SpaceShare {
    public static let accessChanged = Loc.tr("Workspace", "SpaceShare.AccessChanged", fallback: "Access rights have been changed.")
    public static func changePermissions(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Workspace", "SpaceShare.ChangePermissions", String(describing: p1), String(describing: p2), fallback: "%@ access to the space would become %@.")
    }
    public static let joinRequest = Loc.tr("Workspace", "SpaceShare.JoinRequest", fallback: "Join request")
    public static let leaveRequest = Loc.tr("Workspace", "SpaceShare.LeaveRequest", fallback: "Leave request")
    public static let manage = Loc.tr("Workspace", "SpaceShare.Manage", fallback: "Manage")
    public static let manageSpaces = Loc.tr("Workspace", "SpaceShare.ManageSpaces", fallback: "Manage Spaces")
    public static let members = Loc.tr("Workspace", "SpaceShare.Members", fallback: "Members")
    public static func requestsCount(_ p1: Int) -> String {
      return Loc.tr("Workspace", "SpaceShare.RequestsCount", p1, fallback: "Plural format key: SpaceShare.RequestsCount")
    }
    public static let title = Loc.tr("Workspace", "SpaceShare.Title", fallback: "Sharing")
    public static func youSuffix(_ p1: Any) -> String {
      return Loc.tr("Workspace", "SpaceShare.YouSuffix", String(describing: p1), fallback: "%@ (you)")
    }
    public enum Action {
      public static let approve = Loc.tr("Workspace", "SpaceShare.Action.Approve", fallback: "Approve")
      public static let viewRequest = Loc.tr("Workspace", "SpaceShare.Action.ViewRequest", fallback: "View request")
    }
    public enum AlreadyJoin {
      public static let openSpace = Loc.tr("Workspace", "SpaceShare.AlreadyJoin.OpenSpace", fallback: "Open space")
      public static let title = Loc.tr("Workspace", "SpaceShare.AlreadyJoin.Title", fallback: "You are already a member of this space")
    }
    public enum Approve {
      public static func toast(_ p1: Any) -> String {
        return Loc.tr("Workspace", "SpaceShare.Approve.Toast", String(describing: p1), fallback: "You approved %@'s request.")
      }
    }
    public enum CopyInviteLink {
      public static let title = Loc.tr("Workspace", "SpaceShare.CopyInviteLink.Title", fallback: "Copy invite link")
    }
    public enum DeleteSharingLink {
      public static let message = Loc.tr("Workspace", "SpaceShare.DeleteSharingLink.Message", fallback: "New members won’t be able to join the space. You can generate a new link anytime")
      public static let title = Loc.tr("Workspace", "SpaceShare.DeleteSharingLink.Title", fallback: "Delete link")
    }
    public enum HowToShare {
      public static let step1 = Loc.tr("Workspace", "SpaceShare.HowToShare.Step1", fallback: "Please provide the link to the person you'd like to collaborate with.")
      public static let step2 = Loc.tr("Workspace", "SpaceShare.HowToShare.Step2", fallback: "By clicking the link, a person requests to join the space.")
      public static let step3 = Loc.tr("Workspace", "SpaceShare.HowToShare.Step3", fallback: "After approving the request, you can choose the access rights for that person.")
      public static let title = Loc.tr("Workspace", "SpaceShare.HowToShare.Title", fallback: "How to share a space?")
    }
    public enum Invite {
      public static let empty = Loc.tr("Workspace", "SpaceShare.Invite.Empty", fallback: "Create invite link to share space and add new members")
      public static let generate = Loc.tr("Workspace", "SpaceShare.Invite.Generate", fallback: "Generate invite link")
      public static func maxLimit(_ p1: Int) -> String {
        return Loc.tr("Workspace", "SpaceShare.Invite.MaxLimit", p1, fallback: "Plural format key: SpaceShare.Invite.MaxLimit")
      }
      public static let share = Loc.tr("Workspace", "SpaceShare.Invite.Share", fallback: "Share invite link")
      public static let title = Loc.tr("Workspace", "SpaceShare.Invite.Title", fallback: "Invite link")
      public enum Description {
        public static let part1 = Loc.tr("Workspace", "SpaceShare.Invite.Description.part1", fallback: "Share this invite link so that others can join your space")
        public static let part2 = Loc.tr("Workspace", "SpaceShare.Invite.Description.part2", fallback: "Once they click your link and request access, you can set their access rights.")
      }
      public enum Stream {
        public static let description = Loc.tr("Workspace", "SpaceShare.Invite.Stream.Description", fallback: "Share this link so that others can join your Stream.")
      }
    }
    public enum Join {
      public static let button = Loc.tr("Workspace", "SpaceShare.Join.Button", fallback: "Request to join")
      public static let commentPlaceholder = Loc.tr("Workspace", "SpaceShare.Join.CommentPlaceholder", fallback: "Leave a private comment for a space owner")
      public static let info = Loc.tr("Workspace", "SpaceShare.Join.Info", fallback: "Once the space owner approves your request, you'll join the space with the access rights owner determined.")
      public static func message(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Workspace", "SpaceShare.Join.Message", String(describing: p1), String(describing: p2), fallback: "You’ve been invited to join **%@** space, created by **%@**. Send a request so space owner can let you in.")
      }
      public static let spaceDeleted = Loc.tr("Workspace", "SpaceShare.Join.SpaceDeleted", fallback: "The space you try to access has been deleted")
      public static let title = Loc.tr("Workspace", "SpaceShare.Join.Title", fallback: "Join a space")
      public enum InviteNotFound {
        public static let message = Loc.tr("Workspace", "SpaceShare.Join.InviteNotFound.Message", fallback: "The link you are using does not seem to work. Please ask the owner to share a new one with you.")
      }
      public enum LimitReached {
        public static let message = Loc.tr("Workspace", "SpaceShare.Join.LimitReached.Message", fallback: "To join as an editor, ask the owner to add more editor seats or send you a new link with view-only access.")
        public static let title = Loc.tr("Workspace", "SpaceShare.Join.LimitReached.Title", fallback: "This space has reached its limit")
      }
      public enum NoAccess {
        public static let title = Loc.tr("Workspace", "SpaceShare.Join.NoAccess.Title", fallback: "No access to this space")
      }
      public enum NoApprove {
        public static let button = Loc.tr("Workspace", "SpaceShare.Join.NoApprove.button", fallback: "Join Space")
        public static func message(_ p1: Any, _ p2: Any) -> String {
          return Loc.tr("Workspace", "SpaceShare.Join.NoApprove.Message", String(describing: p1), String(describing: p2), fallback: "You've been invited to join %@, created by %@")
        }
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Workspace", "SpaceShare.Join.NoApprove.Title", String(describing: p1), fallback: "Join %@")
        }
      }
      public enum ObjectIsNotAvailable {
        public static let message = Loc.tr("Workspace", "SpaceShare.Join.ObjectIsNotAvailable.Message", fallback: "Ask the owner to share it with you.")
      }
    }
    public enum JoinConfirmation {
      public static let message = Loc.tr("Workspace", "SpaceShare.JoinConfirmation.Message", fallback: "You will receive a notification when the space owner will approve your request.")
      public static let title = Loc.tr("Workspace", "SpaceShare.JoinConfirmation.Title", fallback: "Request sent")
    }
    public enum Permissions {
      public static let owner = Loc.tr("Workspace", "SpaceShare.Permissions.Owner", fallback: "Owner")
      public static let reader = Loc.tr("Workspace", "SpaceShare.Permissions.Reader", fallback: "Viewer")
      public static let writer = Loc.tr("Workspace", "SpaceShare.Permissions.Writer", fallback: "Editor")
      public enum Grand {
        public static let edit = Loc.tr("Workspace", "SpaceShare.Permissions.Grand.Edit", fallback: "Edit")
        public static let view = Loc.tr("Workspace", "SpaceShare.Permissions.Grand.View", fallback: "View")
      }
    }
    public enum Qr {
      public static let button = Loc.tr("Workspace", "SpaceShare.QR.Button", fallback: "Show QR code")
      public static let title = Loc.tr("Workspace", "SpaceShare.QR.Title", fallback: "QR code for joining a Space")
    }
    public enum RemoveMember {
      public static func message(_ p1: Any) -> String {
        return Loc.tr("Workspace", "SpaceShare.RemoveMember.Message", String(describing: p1), fallback: "%@ will be removed from the space.")
      }
      public static let title = Loc.tr("Workspace", "SpaceShare.RemoveMember.Title", fallback: "Remove member")
    }
    public enum Share {
      public static let link = Loc.tr("Workspace", "SpaceShare.Share.link", fallback: "Share link")
    }
    public enum StopSharing {
      public static let action = Loc.tr("Workspace", "SpaceShare.StopSharing.Action", fallback: "Stop sharing")
      public static let message = Loc.tr("Workspace", "SpaceShare.StopSharing.Message", fallback: "Members will no longer sync to this space and the share link will be deactivated.")
      public static let title = Loc.tr("Workspace", "SpaceShare.StopSharing.Title", fallback: "Stop sharing the space")
      public static let toast = Loc.tr("Workspace", "SpaceShare.StopSharing.Toast", fallback: "The space is no longer shared")
    }
    public enum StopSharingEmptySpace {
      public static let message = Loc.tr("Workspace", "SpaceShare.StopSharingEmptySpace.Message", fallback: "You’ve removed the last member, so this space is now private and only accessible to you.")
      public static let title = Loc.tr("Workspace", "SpaceShare.StopSharingEmptySpace.Title", fallback: "The space is now private")
    }
    public enum Tip {
      public static let title = Loc.tr("Workspace", "SpaceShare.Tip.Title", fallback: "Collaborate on spaces")
      public enum Steps {
        public static let _1 = Loc.tr("Workspace", "SpaceShare.Tip.Steps.1", fallback: "Tap the Space widget to access settings")
        public static let _2 = Loc.tr("Workspace", "SpaceShare.Tip.Steps.2", fallback: "Open Share section")
        public static let _3 = Loc.tr("Workspace", "SpaceShare.Tip.Steps.3", fallback: "Generate an invite link and share it")
      }
    }
    public enum ViewRequest {
      public static let editAccess = Loc.tr("Workspace", "SpaceShare.ViewRequest.EditAccess", fallback: "Add as editor")
      public static let reject = Loc.tr("Workspace", "SpaceShare.ViewRequest.Reject", fallback: "Reject")
      public static func title(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Workspace", "SpaceShare.ViewRequest.Title", String(describing: p1), String(describing: p2), fallback: "%@ requested to join %@ space")
      }
      public static let viewAccess = Loc.tr("Workspace", "SpaceShare.ViewRequest.ViewAccess", fallback: "Add as viewer")
    }
  }
  public enum Spaces {
    public static let title = Loc.tr("Workspace", "Spaces.Title", fallback: "Spaces")
    public enum Accessibility {
      public static let personal = Loc.tr("Workspace", "Spaces.Accessibility.Personal", fallback: "Entry Space")
      public static let `private` = Loc.tr("Workspace", "Spaces.Accessibility.Private", fallback: "Private Space")
      public static let shared = Loc.tr("Workspace", "Spaces.Accessibility.Shared", fallback: "Shared Space")
    }
    public enum Info {
      public static let network = Loc.tr("Workspace", "Spaces.Info.Network", fallback: "Network:")
    }
    public enum UxType {
      public enum Chat {
        public static let changeDescription = Loc.tr("Workspace", "Spaces.UxType.Chat.ChangeDescription", fallback: "Group chat with shared data. Best for small groups or a single ongoing conversation.")
        public static let description = Loc.tr("Workspace", "Spaces.UxType.Chat.Description", fallback: "Group chat with content organization")
        public static let title = Loc.tr("Workspace", "Spaces.UxType.Chat.Title", fallback: "Chat")
      }
      public enum Space {
        public static let changeDescription = Loc.tr("Workspace", "Spaces.UxType.Space.ChangeDescription", fallback: "Hub for advanced data management. Multi-chats by topic coming soon. Ideal for larger teams.")
        public static let description = Loc.tr("Workspace", "Spaces.UxType.Space.Description", fallback: "Hub for advanced data management")
        public static let title = Loc.tr("Workspace", "Spaces.UxType.Space.Title", fallback: "Space")
      }
      public enum Stream {
        public static let description = Loc.tr("Workspace", "Spaces.UxType.Stream.Description", fallback: "For broadcasting your vibe")
        public static let title = Loc.tr("Workspace", "Spaces.UxType.Stream.Title", fallback: "Stream")
      }
    }
  }
  public enum Stream {
    public enum Empty {
      public static let description = Loc.tr("Workspace", "Stream.Empty.Description", fallback: "Invite people and start sharing your vibe")
      public static let title = Loc.tr("Workspace", "Stream.Empty.Title", fallback: "This stream is empty")
    }
  }
  public enum TemplateEditing {
    public static let title = Loc.tr("Workspace", "TemplateEditing.Title", fallback: "Edit template")
  }
  public enum TemplateOptions {
    public enum Alert {
      public static let delete = Loc.tr("Workspace", "TemplateOptions.Alert.Delete", fallback: "Delete")
      public static let duplicate = Loc.tr("Workspace", "TemplateOptions.Alert.Duplicate", fallback: "Duplicate")
      public static let editTemplate = Loc.tr("Workspace", "TemplateOptions.Alert.EditTemplate", fallback: "Edit template")
    }
  }
  public enum TemplatePicker {
    public static let chooseTemplate = Loc.tr("Workspace", "TemplatePicker.ChooseTemplate", fallback: "Choose template")
    public enum Buttons {
      public static let useTemplate = Loc.tr("Workspace", "TemplatePicker.Buttons.UseTemplate", fallback: "Use template")
    }
  }
  public enum TemplateSelection {
    public static let selectTemplate = Loc.tr("Workspace", "TemplateSelection.SelectTemplate", fallback: "Select template")
    public enum Available {
      public static func title(_ p1: Int) -> String {
        return Loc.tr("Workspace", "TemplateSelection.Available.Title", p1, fallback: "Plural format key: TemplateSelection.Available.Title")
      }
    }
    public enum ObjectType {
      public static let subtitle = Loc.tr("Workspace", "TemplateSelection.ObjectType.Subtitle", fallback: "Object type")
    }
    public enum Template {
      public static let subtitle = Loc.tr("Workspace", "TemplateSelection.Template.Subtitle", fallback: "Template")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: any CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type

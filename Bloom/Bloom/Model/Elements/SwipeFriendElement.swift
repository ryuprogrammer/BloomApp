import Foundation
import SwiftData

@Model
/// SwipeViewに表示する友達を保存
class SwipeFriendElement {
    var profile: MyProfileElement
    
    init(profile: MyProfileElement) {
        self.profile = profile
    }
}

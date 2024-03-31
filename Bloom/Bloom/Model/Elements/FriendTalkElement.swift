import Foundation
import SwiftData

// FriendListViewで一旦友達を
@Model
class FriendListRowElement {
    let profile: MyProfileElement
    var lastMessage: String?
    var newMessageCount: Int?
    var createAt: Date?
    
    init(profile: MyProfileElement, lastMessage: String?, newMessageCount: Int?, createAt: Date?) {
        self.profile = profile
        self.lastMessage = lastMessage
        self.newMessageCount = newMessageCount
        self.createAt = createAt
    }
}

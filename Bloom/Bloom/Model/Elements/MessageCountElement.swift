import Foundation

struct MessageCountElement: Codable, Identifiable {
    var id = UUID()
    let chatPartnerProfile: ProfileElement
    let newMessagesCount: Int
}

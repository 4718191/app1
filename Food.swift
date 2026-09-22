import Foundation
import SwiftData

@Model
class Food {
    var id: UUID = UUID()
    var name: String
    var expiryDate: Date

    init(name: String, expiryDate: Date) {
        self.name = name
        self.expiryDate = expiryDate
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
    }
}

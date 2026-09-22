import Foundation
import SwiftData

enum FoodCategory: String, CaseIterable, Codable {
    case fridge = "냉장"
    case freezer = "냉동"
    case room = "실온"
}

@Model
class Food {
    var id: UUID = UUID()
    var name: String
    var expiryDate: Date
    var category: FoodCategory

    init(name: String, expiryDate: Date, category: FoodCategory = .fridge) {
        self.name = name
        self.expiryDate = expiryDate
        self.category = category
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
    }
}

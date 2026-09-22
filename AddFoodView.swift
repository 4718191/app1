import SwiftUI
import SwiftData
import UserNotifications

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var expiryDate = Date()
    @State private var category: FoodCategory = .fridge

    var body: some View {
        NavigationStack {
            Form {
                TextField("음식 이름", text: $name)
                DatePicker("유통기한", selection: $expiryDate, displayedComponents: .date)
                Picker("보관 방법", selection: $category) {
                    ForEach(FoodCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
            }
            .navigationTitle("새 항목 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let newFood = Food(name: name, expiryDate: expiryDate, category: category)
                        modelContext.insert(newFood)
                        try? modelContext.save()
                        scheduleNotification(for: newFood)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    func scheduleNotification(for food: Food) {
        guard let notifyDate = Calendar.current.date(byAdding: .day, value: -1, to: food.expiryDate) else { return }

        let content = UNMutableNotificationContent()
        content.title = "유통기한 임박"
        content.body = "\(food.name)의 유통기한이 내일까지예요!"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: notifyDate)
        dateComponents.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: food.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

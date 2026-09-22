import SwiftUI
import SwiftData

struct EditFoodView: View {
    @Bindable var food: Food
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("음식 이름", text: $food.name)
                DatePicker("유통기한", selection: $food.expiryDate, displayedComponents: .date)
                Picker("보관 방법", selection: $food.category) {
                    ForEach(FoodCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
            }
            .navigationTitle("항목 수정")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

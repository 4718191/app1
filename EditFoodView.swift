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

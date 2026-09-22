import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Food.expiryDate) private var foods: [Food]
    @State private var showingAddSheet = false
    @State private var searchText = ""

    var filteredFoods: [Food] {
        if searchText.isEmpty {
            return foods
        } else {
            return foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredFoods) { food in
                    NavigationLink {
                        EditFoodView(food: food)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .font(.headline)
                            Text(food.expiryDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(statusColor(for: food))
                        }
                    }
                }
                .onDelete(perform: deleteFood)
            }
            .navigationTitle("유통기한 관리")
            .searchable(text: $searchText, prompt: "음식 이름 검색")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddFoodView()
            }
        }
    }

    func statusColor(for food: Food) -> Color {
        if food.daysRemaining < 0 {
            return .red
        } else if food.daysRemaining <= 3 {
            return .orange
        } else {
            return .green
        }
    }

    func deleteFood(at offsets: IndexSet) {
        for index in offsets {
            let food = filteredFoods[index]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [food.id.uuidString])
            modelContext.delete(food)
        }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Food.self, inMemory: true)
}

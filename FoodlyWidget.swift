import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FoodEntry {
        FoodEntry(date: Date(), urgentCount: 0, nextFoodName: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (FoodEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FoodEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    func loadEntry() -> FoodEntry {
        let appGroupID = "group.com.hanju.foodly"
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return FoodEntry(date: Date(), urgentCount: 0, nextFoodName: nil)
        }
        let storeURL = groupURL.appendingPathComponent("foodly.sqlite")

        do {
            let schema = Schema([Food.self])
            let config = ModelConfiguration(schema: schema, url: storeURL)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<Food>(sortBy: [SortDescriptor(\.expiryDate)])
            let foods = try context.fetch(descriptor)

            let urgent = foods.filter { food in
                let days = Calendar.current.dateComponents([.day], from: Date(), to: food.expiryDate).day ?? 0
                return days <= 3
            }

            return FoodEntry(date: Date(), urgentCount: urgent.count, nextFoodName: foods.first?.name)
        } catch {
            return FoodEntry(date: Date(), urgentCount: 0, nextFoodName: nil)
        }
    }
}

struct FoodEntry: TimelineEntry {
    let date: Date
    let urgentCount: Int
    let nextFoodName: String?
}

struct FoodlyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "refrigerator.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            Spacer()

            Text("\(entry.urgentCount)개")
                .font(.title)
                .bold()

            Text("임박한 음식")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let name = entry.nextFoodName {
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
    }
}

struct FoodlyWidget: Widget {
    let kind: String = "FoodlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FoodlyWidgetEntryView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("유통기한 관리")
        .description("임박한 음식 개수를 보여줘요")
    }
}

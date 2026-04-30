import Foundation
import Observation

enum HealthStatus: Equatable {
    case notRequested
    case unavailable
    case authorized
    case failed(String)

    var title: String {
        switch self {
        case .notRequested: "Health not connected"
        case .unavailable: "Health unavailable"
        case .authorized: "Health connected"
        case .failed: "Health sync failed"
        }
    }

    var detail: String {
        switch self {
        case .notRequested:
            "Allow access to read recent workouts and save new sessions."
        case .unavailable:
            "HealthKit is not available on this device."
        case .authorized:
            "Recent workouts can sync from Apple Health."
        case .failed(let message):
            message
        }
    }

    var symbolName: String {
        switch self {
        case .notRequested: "heart.text.square"
        case .unavailable: "exclamationmark.triangle"
        case .authorized: "heart.text.square.fill"
        case .failed: "xmark.octagon"
        }
    }
}

@MainActor
@Observable
final class WorkoutStore {
    var workouts: [WorkoutEntry]
    var selectedFocus: TrainingFocus
    var searchText: String
    var healthStatus: HealthStatus
    var isSyncing: Bool
    var weeklyGoalMinutes: Int

    private let healthKit: HealthKitClient
    private let persistenceURL: URL

    init(healthKit: HealthKitClient = HealthKitClient()) {
        self.healthKit = healthKit
        self.persistenceURL = Self.makePersistenceURL()
        self.workouts = []
        self.selectedFocus = .all
        self.searchText = ""
        self.healthStatus = healthKit.isHealthDataAvailable ? .notRequested : .unavailable
        self.isSyncing = false
        self.weeklyGoalMinutes = 180

        load()

        if workouts.isEmpty {
            workouts = WorkoutSeedData.workouts
            save()
        }
    }

    var filteredWorkouts: [WorkoutEntry] {
        workouts
            .filter { workout in
                let matchesFocus = selectedFocus == .all || workout.kind.focus == selectedFocus
                let matchesSearch = searchText.isEmpty
                    || workout.title.localizedCaseInsensitiveContains(searchText)
                    || workout.kind.rawValue.localizedCaseInsensitiveContains(searchText)
                    || workout.notes.localizedCaseInsensitiveContains(searchText)
                return matchesFocus && matchesSearch
            }
            .sorted { $0.startDate > $1.startDate }
    }

    var recentWorkouts: [WorkoutEntry] {
        Array(workouts.sorted { $0.startDate > $1.startDate }.prefix(4))
    }

    var weeklyWorkouts: [WorkoutEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now
        return workouts.filter { $0.startDate >= start }
    }

    var weeklyMinutes: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }

    var weeklyEnergy: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.energyKilocalories }
    }

    var averageEffort: Double {
        guard !weeklyWorkouts.isEmpty else { return 0 }
        let total = weeklyWorkouts.reduce(0) { $0 + $1.perceivedEffort }
        return Double(total) / Double(weeklyWorkouts.count)
    }

    var goalProgress: Double {
        guard weeklyGoalMinutes > 0 else { return 0 }
        return min(Double(weeklyMinutes) / Double(weeklyGoalMinutes), 1)
    }

    func requestHealthAccess() async {
        guard healthKit.isHealthDataAvailable else {
            healthStatus = .unavailable
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            try await healthKit.requestAuthorization()
            healthStatus = .authorized
            await refreshFromHealth(silent: true)
        } catch {
            healthStatus = .failed(error.localizedDescription)
        }
    }

    func refreshFromHealth(silent: Bool = false) async {
        guard healthKit.isHealthDataAvailable else {
            if !silent {
                healthStatus = .unavailable
            }
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            let synced = try await healthKit.fetchRecentWorkouts(limit: 40)
            mergeHealthWorkouts(synced)
            healthStatus = .authorized
            save()
        } catch {
            if !silent {
                healthStatus = .failed(error.localizedDescription)
            }
        }
    }

    func logWorkout(_ draft: WorkoutDraft, saveToHealth: Bool) async {
        var workout = WorkoutEntry(draft: draft)
        workouts.insert(workout, at: 0)
        save()

        guard saveToHealth else { return }

        do {
            try await healthKit.saveWorkout(workout)
            workout.source = .health
            replaceWorkout(workout)
            healthStatus = .authorized
            await refreshFromHealth(silent: true)
        } catch {
            healthStatus = .failed(error.localizedDescription)
        }
    }

    func deleteWorkouts(at offsets: IndexSet) {
        let visibleIDs = filteredWorkouts.map(\.id)
        let idsToDelete = offsets.compactMap { visibleIDs[safe: $0] }
        workouts.removeAll { idsToDelete.contains($0.id) && $0.source != .health }
        save()
    }

    private func mergeHealthWorkouts(_ synced: [WorkoutEntry]) {
        var existingByID = Dictionary(uniqueKeysWithValues: workouts.map { ($0.id, $0) })

        for workout in synced {
            existingByID[workout.id] = workout
        }

        workouts = existingByID.values.sorted { $0.startDate > $1.startDate }
    }

    private func replaceWorkout(_ workout: WorkoutEntry) {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        workouts[index] = workout
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: persistenceURL) else { return }
        guard let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) else { return }
        workouts = decoded
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(workouts) else { return }

        try? FileManager.default.createDirectory(
            at: persistenceURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try? data.write(to: persistenceURL, options: [.atomic])
    }

    private static func makePersistenceURL() -> URL {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return supportDirectory
            .appendingPathComponent("FitGlass", isDirectory: true)
            .appendingPathComponent("workouts.json")
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

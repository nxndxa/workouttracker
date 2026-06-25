import Foundation
import SwiftUI

enum WorkoutKind: String, CaseIterable, Codable, Identifiable {
    case run = "Run"
    case strength = "Strength"
    case cycling = "Cycling"
    case yoga = "Yoga"
    case walk = "Walk"
    case hiit = "HIIT"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .run: "figure.run"
        case .strength: "dumbbell"
        case .cycling: "figure.outdoor.cycle"
        case .yoga: "figure.mind.and.body"
        case .walk: "figure.walk"
        case .hiit: "flame"
        }
    }

    var accent: Color {
        switch self {
        case .run: .blue
        case .strength: .orange
        case .cycling: .green
        case .yoga: .purple
        case .walk: .teal
        case .hiit: .pink
        }
    }

    var focus: TrainingFocus {
        switch self {
        case .run, .cycling, .walk, .hiit: .cardio
        case .strength: .strength
        case .yoga: .mobility
        }
    }

    var tracksDistance: Bool {
        switch self {
        case .run, .cycling, .walk: true
        case .strength, .yoga, .hiit: false
        }
    }
}

enum TrainingFocus: String, CaseIterable, Codable, Identifiable {
    case all = "All"
    case cardio = "Cardio"
    case strength = "Strength"
    case mobility = "Mobility"

    var id: String { rawValue }
}

enum EnergyUnit: String, CaseIterable, Codable, Identifiable {
    case kilocalories = "kcal"
    case calories = "cal"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kilocalories: "Kilocalories"
        case .calories: "Calories"
        }
    }

    var shortTitle: String {
        rawValue
    }

    func valueText(forKilocalories kilocalories: Int) -> String {
        kilocalories.formatted(.number.grouping(.automatic))
    }

    func formattedEnergy(forKilocalories kilocalories: Int) -> String {
        "\(valueText(forKilocalories: kilocalories)) \(shortTitle)"
    }
}

enum DistanceUnit: String, CaseIterable, Codable, Identifiable {
    case kilometers = "km"
    case miles = "mi"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kilometers: "Kilometers"
        case .miles: "Miles"
        }
    }

    func valueText(forKilometers kilometers: Double) -> String {
        let value = switch self {
        case .kilometers: kilometers
        case .miles: kilometers * 0.621371
        }

        return value.formatted(.number.precision(.fractionLength(1)))
    }

    func formattedDistance(forKilometers kilometers: Double) -> String {
        "\(valueText(forKilometers: kilometers)) \(rawValue)"
    }
}

enum FitnessGoal: String, CaseIterable, Codable, Hashable, Identifiable {
    case weightLoss = "Weight Loss"
    case fitnessTracking = "Fitness Tracking"
    case hypertrophy = "Hypertrophy"
    case strength = "Strength"
    case endurance = "Endurance"
    case mobility = "Mobility"
    case consistency = "Consistency"
    case generalHealth = "General Health"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .weightLoss: "scalemass"
        case .fitnessTracking: "chart.xyaxis.line"
        case .hypertrophy: "dumbbell"
        case .strength: "bolt.fill"
        case .endurance: "figure.run"
        case .mobility: "figure.mind.and.body"
        case .consistency: "calendar.badge.checkmark"
        case .generalHealth: "heart.fill"
        }
    }
}

enum AuthProvider: String, Codable {
    case apple = "Apple"
    case google = "Google"
    case email = "Email"
}

struct EmailVerificationSession: Codable, Hashable {
    var email: String
    var expiresAt: Date?
}

enum WorkoutSource: String, Codable {
    case app = "Aether"
    case health = "Health"

    var symbolName: String {
        switch self {
        case .app: "square.and.pencil"
        case .health: "heart.text.square.fill"
        }
    }
}

enum WorkoutHistoryFilter: String, CaseIterable, Codable, Identifiable {
    case oneWeek = "1 Week"
    case oneMonth = "1 Month"
    case threeMonths = "3 Months"
    case oneYear = "1 Year"
    case allTime = "All Time"

    var id: String { rawValue }

    var startDate: Date? {
        let calendar = Calendar.current
        switch self {
        case .oneWeek:
            return calendar.date(byAdding: .day, value: -7, to: .now)
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: .now)
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: .now)
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: .now)
        case .allTime:
            return nil
        }
    }
}

struct HealthMetricsSnapshot: Codable, Equatable {
    var activeEnergyKilocalories: Int = 0
    var averageHeartRate: Int?
    var steps: Int = 0
    var walkingRunningDistanceKilometers: Double = 0
    var updatedAt: Date?

    var heartRateText: String {
        guard let averageHeartRate else { return "--" }
        return "\(averageHeartRate)"
    }
}

struct ProgressTrendPoint: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let completed: Int
    let target: Int

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(completed) / Double(target), 1)
    }
}

enum WorkoutDay: String, CaseIterable, Codable, Hashable, Identifiable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"

    var id: String { rawValue }

    var shortTitle: String {
        String(rawValue.prefix(1))
    }

    static var today: WorkoutDay {
        let weekday = Calendar.current.component(.weekday, from: .now)
        return Self.allCases[max(0, min(weekday - 1, Self.allCases.count - 1))]
    }
}

enum MuscleGroup: String, CaseIterable, Codable, Hashable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case legs = "Legs"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case core = "Core"
    case wholeBody = "Whole Body"

    var id: String { rawValue }
}

struct ExerciseOption: Identifiable, Hashable {
    let name: String
    let muscleGroup: MuscleGroup
    let aliases: [String]
    let symbolName: String

    var id: String { name }

    static let all: [ExerciseOption] = [
        ExerciseOption(name: "Bench Press", muscleGroup: .chest, aliases: ["Bench"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Squat", muscleGroup: .legs, aliases: ["Back Squat"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Deadlift", muscleGroup: .wholeBody, aliases: [], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Shoulder Press", muscleGroup: .shoulders, aliases: ["Overhead Press"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Pull Ups", muscleGroup: .back, aliases: ["Pullup", "Assisted Pull Up Machine"], symbolName: "figure.pullup"),
        ExerciseOption(name: "Dumbbell Bench Press", muscleGroup: .chest, aliases: ["Dumbbell Bench", "Dumbbell Chest Press"], symbolName: "dumbbell"),
        ExerciseOption(name: "Dumbbell Curl", muscleGroup: .biceps, aliases: [], symbolName: "dumbbell"),
        ExerciseOption(name: "Push Ups", muscleGroup: .chest, aliases: ["Press Up"], symbolName: "figure.core.training"),
        ExerciseOption(name: "Sled Leg Press", muscleGroup: .legs, aliases: ["Leg Press"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Barbell Curl", muscleGroup: .biceps, aliases: ["Bicep Curl", "Curl"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Incline Dumbbell Bench Press", muscleGroup: .chest, aliases: ["Incline Dumbbell Press"], symbolName: "dumbbell"),
        ExerciseOption(name: "Bent Over Row", muscleGroup: .back, aliases: ["Row", "Barbell Row"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Incline Bench Press", muscleGroup: .chest, aliases: ["Incline Bench", "Incline Press"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Dips", muscleGroup: .triceps, aliases: ["Tricep Dips", "Chest Dip"], symbolName: "figure.dips"),
        ExerciseOption(name: "Dumbbell Shoulder Press", muscleGroup: .shoulders, aliases: ["Dumbbell Press"], symbolName: "dumbbell"),
        ExerciseOption(name: "Lat Pulldown", muscleGroup: .back, aliases: ["Pulldown", "Machine Pulldown", "Lateral Pulldown"], symbolName: "figure.strengthtraining.traditional"),
        ExerciseOption(name: "Plank", muscleGroup: .core, aliases: ["Front Plank"], symbolName: "figure.core.training")
    ]
}

struct WorkoutTrackingDraft: Equatable {
    var kind: WorkoutKind = .strength
    var day: WorkoutDay = .today
    var muscleGroups: [MuscleGroup] = [.chest]
    var exercise: ExerciseOption = ExerciseOption.all[0]
    var workoutName: String = ""
    var splitName: String = "Push"
    var weightPounds: Int = 135
    var reps: Int = 8
    var distanceKilometers: Double = 5
    var notes: String = ""

    init(
        kind: WorkoutKind = .strength,
        day: WorkoutDay = .today,
        muscleGroups: [MuscleGroup] = [.chest],
        exercise: ExerciseOption = ExerciseOption.all[0],
        workoutName: String = "",
        splitName: String = "Push",
        weightPounds: Int = 135,
        reps: Int = 8,
        distanceKilometers: Double = 5,
        notes: String = ""
    ) {
        self.kind = kind
        self.day = day
        self.muscleGroups = muscleGroups
        self.exercise = exercise
        self.workoutName = workoutName
        self.splitName = splitName
        self.weightPounds = weightPounds
        self.reps = reps
        self.distanceKilometers = distanceKilometers
        self.notes = notes
    }

    var title: String {
        let trimmed = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Workout" : trimmed
    }

    var isSubmittable: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !muscleGroups.isEmpty
    }

    var summaryNotes: String {
        let muscles = muscleGroups.map(\.rawValue).joined(separator: ", ")
        let performance = kind.tracksDistance
            ? "\(distanceKilometers.formatted(.number.precision(.fractionLength(1)))) km"
            : "\(weightPounds) lb x \(reps) reps"
        let base = "\(day.rawValue) • \(muscles) • \(splitName) • \(title) • \(performance)"
        return notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? base : "\(base)\n\(notes)"
    }

    mutating func toggleMuscleGroup(_ group: MuscleGroup) {
        if muscleGroups.contains(group) {
            muscleGroups.removeAll { $0 == group }
        } else {
            muscleGroups.append(group)
        }
    }
}

struct WorkoutTemplate: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var kind: WorkoutKind
    var muscleGroups: [MuscleGroup]
    var workoutName: String
    var splitName: String
    var weightPounds: Int
    var reps: Int
    var distanceKilometers: Double

    init(
        id: UUID = UUID(),
        name: String,
        kind: WorkoutKind,
        muscleGroups: [MuscleGroup],
        workoutName: String,
        splitName: String,
        weightPounds: Int,
        reps: Int,
        distanceKilometers: Double
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.muscleGroups = muscleGroups
        self.workoutName = workoutName
        self.splitName = splitName
        self.weightPounds = weightPounds
        self.reps = reps
        self.distanceKilometers = distanceKilometers
    }

    init(draft: WorkoutTrackingDraft) {
        self.init(
            name: draft.splitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? draft.title : draft.splitName,
            kind: draft.kind,
            muscleGroups: draft.muscleGroups,
            workoutName: draft.title,
            splitName: draft.splitName,
            weightPounds: draft.weightPounds,
            reps: draft.reps,
            distanceKilometers: draft.distanceKilometers
        )
    }

    func draft(for day: WorkoutDay = .today) -> WorkoutTrackingDraft {
        WorkoutTrackingDraft(
            kind: kind,
            day: day,
            muscleGroups: muscleGroups,
            workoutName: workoutName,
            splitName: splitName,
            weightPounds: weightPounds,
            reps: reps,
            distanceKilometers: distanceKilometers
        )
    }

    static let defaults: [WorkoutTemplate] = [
        WorkoutTemplate(
            name: "Push Day",
            kind: .strength,
            muscleGroups: [.chest, .shoulders, .triceps],
            workoutName: "Push Day",
            splitName: "Push",
            weightPounds: 135,
            reps: 8,
            distanceKilometers: 0
        ),
        WorkoutTemplate(
            name: "5K Run",
            kind: .run,
            muscleGroups: [.wholeBody],
            workoutName: "5K Run",
            splitName: "Run",
            weightPounds: 0,
            reps: 1,
            distanceKilometers: 5
        )
    ]
}

struct WorkoutEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var kind: WorkoutKind
    var title: String
    var startDate: Date
    var durationMinutes: Int
    var energyKilocalories: Int
    var distanceKilometers: Double?
    var averageHeartRate: Int?
    var perceivedEffort: Int
    var source: WorkoutSource
    var notes: String
    var muscleGroups: [MuscleGroup]
    var splitName: String
    var weightPounds: Int?
    var reps: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case title
        case startDate
        case durationMinutes
        case energyKilocalories
        case distanceKilometers
        case averageHeartRate
        case perceivedEffort
        case source
        case notes
        case muscleGroups
        case splitName
        case weightPounds
        case reps
    }

    init(
        id: UUID = UUID(),
        kind: WorkoutKind,
        title: String,
        startDate: Date,
        durationMinutes: Int,
        energyKilocalories: Int,
        distanceKilometers: Double? = nil,
        averageHeartRate: Int? = nil,
        perceivedEffort: Int,
        source: WorkoutSource,
        notes: String,
        muscleGroups: [MuscleGroup] = [],
        splitName: String = "",
        weightPounds: Int? = nil,
        reps: Int? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.startDate = startDate
        self.durationMinutes = durationMinutes
        self.energyKilocalories = energyKilocalories
        self.distanceKilometers = distanceKilometers
        self.averageHeartRate = averageHeartRate
        self.perceivedEffort = perceivedEffort
        self.source = source
        self.notes = notes
        self.muscleGroups = muscleGroups
        self.splitName = splitName
        self.weightPounds = weightPounds
        self.reps = reps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        kind = try container.decode(WorkoutKind.self, forKey: .kind)
        title = try container.decode(String.self, forKey: .title)
        startDate = try container.decode(Date.self, forKey: .startDate)
        durationMinutes = try container.decodeIfPresent(Int.self, forKey: .durationMinutes) ?? 0
        energyKilocalories = try container.decodeIfPresent(Int.self, forKey: .energyKilocalories) ?? 0
        distanceKilometers = try container.decodeIfPresent(Double.self, forKey: .distanceKilometers)
        averageHeartRate = try container.decodeIfPresent(Int.self, forKey: .averageHeartRate)
        perceivedEffort = try container.decodeIfPresent(Int.self, forKey: .perceivedEffort) ?? 6
        source = try container.decodeIfPresent(WorkoutSource.self, forKey: .source) ?? .app
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        muscleGroups = try container.decodeIfPresent([MuscleGroup].self, forKey: .muscleGroups) ?? []
        splitName = try container.decodeIfPresent(String.self, forKey: .splitName) ?? ""
        weightPounds = try container.decodeIfPresent(Int.self, forKey: .weightPounds)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
    }

    var endDate: Date {
        startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    var distanceText: String {
        guard let distanceKilometers else { return "No distance" }
        return distanceKilometers.formatted(.number.precision(.fractionLength(1))) + " km"
    }

    var durationText: String {
        "\(durationMinutes) min"
    }

    var energyText: String {
        "\(energyKilocalories) kcal"
    }

    func energyText(in unit: EnergyUnit) -> String {
        unit.formattedEnergy(forKilocalories: energyKilocalories)
    }

    func distanceText(in unit: DistanceUnit) -> String {
        guard let distanceKilometers else { return "No distance" }
        return unit.formattedDistance(forKilometers: distanceKilometers)
    }

    var effortText: String {
        "\(perceivedEffort)/10"
    }

    var volumeLoad: Int {
        (weightPounds ?? 0) * (reps ?? 0)
    }
}

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

enum GenderIdentity: String, CaseIterable, Codable, Identifiable {
    case he = "He"
    case she = "She"
    case other = "Other"

    var id: String { rawValue }
}

enum AccessTier: String, Codable {
    case free = "Free"
    case pro = "Pro"
}

enum ProPlanOption: String, CaseIterable, Codable, Identifiable {
    case trial = "7-Day Free Trial"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }

    var headline: String {
        switch self {
        case .trial: "Try Pro free for 7 days"
        case .monthly: "$5 per month"
        case .yearly: "$50 per year"
        }
    }

    var detail: String {
        switch self {
        case .trial: "Then continue on the yearly plan unless canceled."
        case .monthly: "Flexible monthly access."
        case .yearly: "Best value for the full year."
        }
    }

    var ctaTitle: String {
        switch self {
        case .trial: "Start 7-Day Free Trial"
        case .monthly: "Choose Monthly"
        case .yearly: "Choose Yearly"
        }
    }
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

struct ScoreBreakdownItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: Int
    let maxValue: Int

    var progress: Double {
        guard maxValue > 0 else { return 0 }
        return min(Double(value) / Double(maxValue), 1)
    }
}

enum TrainingExperience: String, CaseIterable, Codable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .beginner: "Building the habit"
        case .intermediate: "Training with structure"
        case .advanced: "Chasing performance"
        }
    }
}

enum OnboardingChallenge: String, CaseIterable, Codable, Identifiable {
    case consistency = "Consistency"
    case motivation = "Motivation"
    case strengthPlateau = "Strength Plateau"
    case lowCardio = "Low Cardio"
    case bodyComposition = "Body Composition"
    case time = "Time"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .consistency: "A schedule that is easier to stick with."
        case .motivation: "More visible momentum and quick wins."
        case .strengthPlateau: "Better structure and progressive overload."
        case .lowCardio: "A stronger aerobic base and recovery."
        case .bodyComposition: "More weekly output and better habits."
        case .time: "Shorter, focused sessions."
        }
    }
}

struct OnboardingQuizProfile: Codable, Equatable {
    var experience: TrainingExperience = .beginner
    var trainingDaysPerWeek: Int = 3
    var biggestChallenge: OnboardingChallenge = .consistency
    var targetDate: Date = Calendar.current.date(byAdding: .day, value: 56, to: .now) ?? .now
    var genderIdentity: GenderIdentity = .other
    var dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
}

struct WorkoutPlanRecommendation: Hashable {
    var title: String
    var subtitle: String
    var insight: String
    var scoreTarget: Int
    var targetWorkoutMinutes: Int
    var recommendedDays: [WorkoutDay]
    var templates: [WorkoutTemplate]
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
    var workoutName: String = ""
    var splitName: String = ""
    var exercises: [WorkoutExercise] = []

    init(
        kind: WorkoutKind = .strength,
        day: WorkoutDay = .today,
        workoutName: String = "",
        splitName: String = "",
        exercises: [WorkoutExercise] = []
    ) {
        self.kind = kind
        self.day = day
        self.workoutName = workoutName
        self.splitName = splitName
        self.exercises = exercises
    }

    var filledExercises: [WorkoutExercise] {
        exercises.filter { $0.isFilled(for: kind) }
    }

    var title: String {
        let trimmed = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Workout" : trimmed
    }

    var isSubmittable: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !filledExercises.isEmpty
    }

    var summaryNotes: String {
        let base = splitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "\(day.rawValue) • \(title)"
            : "\(day.rawValue) • \(splitName) • \(title)"
        let exerciseLines = filledExercises.map { "- \($0.name) • \($0.summary(for: kind))" }.joined(separator: "\n")
        return "\(base)\n\(exerciseLines)"
    }

    var totalDistanceKilometers: Double {
        filledExercises.reduce(0) { $0 + $1.distanceKilometers }
    }

    var primaryWeightPounds: Int? {
        filledExercises.compactMap(\.primaryWeightPounds).max()
    }

    var primaryReps: Int? {
        filledExercises.first?.primaryReps
    }

    mutating func appendExercise(_ exercise: WorkoutExercise) {
        guard exercise.isFilled(for: kind) else { return }
        exercises.append(exercise)
    }

    mutating func removeExercise(id: UUID) {
        exercises.removeAll { $0.id == id }
    }
}

struct WorkoutSet: Identifiable, Codable, Hashable {
    var id: UUID
    var reps: Int
    var weightPounds: Int

    init(
        id: UUID = UUID(),
        reps: Int = 8,
        weightPounds: Int = 45
    ) {
        self.id = id
        self.reps = reps
        self.weightPounds = weightPounds
    }

    var volumeLoad: Int {
        reps * weightPounds
    }

    var summaryText: String {
        "\(reps) reps • \(weightPounds) lb"
    }
}

struct WorkoutExercise: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var sets: Int
    var weightPounds: Int
    var reps: Int
    var distanceKilometers: Double
    var notes: String
    var loggedSets: [WorkoutSet]

    init(
        id: UUID = UUID(),
        name: String = "",
        sets: Int = 3,
        weightPounds: Int = 135,
        reps: Int = 8,
        distanceKilometers: Double = 5,
        notes: String = "",
        loggedSets: [WorkoutSet] = []
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.weightPounds = weightPounds
        self.reps = reps
        self.distanceKilometers = distanceKilometers
        self.notes = notes
        if loggedSets.isEmpty && distanceKilometers == 0 && reps > 0 {
            self.loggedSets = (0..<max(sets, 1)).map { _ in
                WorkoutSet(reps: reps, weightPounds: weightPounds)
            }
        } else {
            self.loggedSets = loggedSets
        }
    }

    var activeSets: [WorkoutSet] {
        if !loggedSets.isEmpty {
            return loggedSets
        }

        guard reps > 0 else { return [] }
        return (0..<max(sets, 1)).map { _ in
            WorkoutSet(reps: reps, weightPounds: weightPounds)
        }
    }

    func isFilled(for kind: WorkoutKind) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (kind.tracksDistance ? distanceKilometers > 0 : activeSets.contains { $0.reps > 0 })
    }

    func summary(for kind: WorkoutKind) -> String {
        if kind.tracksDistance {
            return "\(distanceKilometers.formatted(.number.precision(.fractionLength(1)))) km"
        }

        let sets = activeSets
        let totalReps = sets.reduce(0) { $0 + $1.reps }
        let topWeight = sets.map(\.weightPounds).max() ?? 0
        return "\(sets.count) set\(sets.count == 1 ? "" : "s") • \(totalReps) reps • \(topWeight) lb top"
    }

    var volumeLoad: Int {
        if !activeSets.isEmpty {
            return activeSets.reduce(0) { $0 + $1.volumeLoad }
        }

        return sets * reps * weightPounds
    }

    var primaryWeightPounds: Int? {
        activeSets.map(\.weightPounds).max()
    }

    var primaryReps: Int? {
        activeSets.first?.reps
    }
}

struct WorkoutTemplate: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var kind: WorkoutKind
    var muscleGroups: [MuscleGroup]
    var workoutName: String
    var splitName: String
    var exercises: [WorkoutExercise]

    init(
        id: UUID = UUID(),
        name: String,
        kind: WorkoutKind,
        muscleGroups: [MuscleGroup],
        workoutName: String,
        splitName: String,
        exercises: [WorkoutExercise]
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.muscleGroups = muscleGroups
        self.workoutName = workoutName
        self.splitName = splitName
        self.exercises = exercises
    }

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
        self.init(
            id: id,
            name: name,
            kind: kind,
            muscleGroups: muscleGroups,
            workoutName: workoutName,
            splitName: splitName,
            exercises: [
                WorkoutExercise(
                    name: workoutName,
                    sets: kind.tracksDistance ? 1 : 3,
                    weightPounds: weightPounds,
                    reps: reps,
                    distanceKilometers: distanceKilometers
                )
            ]
        )
    }

    init(draft: WorkoutTrackingDraft) {
        self.init(
            name: draft.splitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? draft.title : draft.splitName,
            kind: draft.kind,
            muscleGroups: [],
            workoutName: draft.title,
            splitName: draft.splitName,
            exercises: draft.filledExercises
        )
    }

    func draft(for day: WorkoutDay = .today) -> WorkoutTrackingDraft {
        WorkoutTrackingDraft(
            kind: kind,
            day: day,
            workoutName: workoutName,
            splitName: splitName,
            exercises: exercises
        )
    }

    var previewExercises: [WorkoutExercise] {
        Array(exercises.prefix(4))
    }

    var exerciseCount: Int {
        exercises.count
    }

    static let defaults: [WorkoutTemplate] = [
        WorkoutTemplate(
            name: "Push Day",
            kind: .strength,
            muscleGroups: [.chest, .shoulders, .triceps],
            workoutName: "Push Day",
            splitName: "Push",
            exercises: [
                WorkoutExercise(name: "Bench Press", sets: 3, weightPounds: 135, reps: 8, distanceKilometers: 0),
                WorkoutExercise(name: "Incline Press", sets: 3, weightPounds: 115, reps: 10, distanceKilometers: 0),
                WorkoutExercise(name: "Cable Fly", sets: 2, weightPounds: 40, reps: 12, distanceKilometers: 0),
                WorkoutExercise(name: "Overhead Tricep Extension", sets: 3, weightPounds: 45, reps: 10, distanceKilometers: 0)
            ]
        ),
        WorkoutTemplate(
            name: "Pull Day",
            kind: .strength,
            muscleGroups: [.back, .biceps],
            workoutName: "Pull Day",
            splitName: "Pull",
            exercises: [
                WorkoutExercise(name: "Lat Pulldown", sets: 3, weightPounds: 120, reps: 10, distanceKilometers: 0),
                WorkoutExercise(name: "Chest Supported Row", sets: 3, weightPounds: 90, reps: 10, distanceKilometers: 0),
                WorkoutExercise(name: "Seated Cable Row", sets: 2, weightPounds: 105, reps: 12, distanceKilometers: 0),
                WorkoutExercise(name: "EZ Bar Curl", sets: 3, weightPounds: 55, reps: 10, distanceKilometers: 0)
            ]
        ),
        WorkoutTemplate(
            name: "Leg Day",
            kind: .strength,
            muscleGroups: [.legs, .core],
            workoutName: "Leg Day",
            splitName: "Legs",
            exercises: [
                WorkoutExercise(name: "Hack Squat", sets: 3, weightPounds: 185, reps: 6, distanceKilometers: 0),
                WorkoutExercise(name: "Romanian Deadlift", sets: 3, weightPounds: 155, reps: 8, distanceKilometers: 0),
                WorkoutExercise(name: "Leg Extension", sets: 2, weightPounds: 100, reps: 12, distanceKilometers: 0),
                WorkoutExercise(name: "Calf Raise", sets: 3, weightPounds: 160, reps: 12, distanceKilometers: 0)
            ]
        ),
        WorkoutTemplate(
            name: "Upper Heavy",
            kind: .strength,
            muscleGroups: [.chest, .back, .shoulders, .biceps, .triceps],
            workoutName: "Upper Heavy",
            splitName: "Upper",
            exercises: [
                WorkoutExercise(name: "Incline Press", sets: 2, weightPounds: 145, reps: 6, distanceKilometers: 0),
                WorkoutExercise(name: "T-Bar Row", sets: 2, weightPounds: 135, reps: 8, distanceKilometers: 0),
                WorkoutExercise(name: "Cable Lateral Raise", sets: 2, weightPounds: 20, reps: 15, distanceKilometers: 0),
                WorkoutExercise(name: "Preacher Curl", sets: 2, weightPounds: 55, reps: 8, distanceKilometers: 0)
            ]
        ),
        WorkoutTemplate(
            name: "5K Run Session",
            kind: .run,
            muscleGroups: [.wholeBody],
            workoutName: "5K Run Session",
            splitName: "Run",
            exercises: [
                WorkoutExercise(name: "Warm Up Jog", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 1.0),
                WorkoutExercise(name: "Main Run", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 5.0),
                WorkoutExercise(name: "Cool Down Walk", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 0.8)
            ]
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
    var exercises: [WorkoutExercise]
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
        case exercises
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
        exercises: [WorkoutExercise] = [],
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
        self.exercises = exercises
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
        exercises = try container.decodeIfPresent([WorkoutExercise].self, forKey: .exercises) ?? []
        weightPounds = try container.decodeIfPresent(Int.self, forKey: .weightPounds)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)

        if exercises.isEmpty, let fallbackExercise = WorkoutEntry.makeFallbackExercise(
            title: title,
            kind: kind,
            weightPounds: weightPounds,
            reps: reps,
            distanceKilometers: distanceKilometers
        ) {
            exercises = [fallbackExercise]
        }
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
        if !exercises.isEmpty {
            return exercises.reduce(0) { $0 + $1.volumeLoad }
        }

        return (weightPounds ?? 0) * (reps ?? 0)
    }

    private static func makeFallbackExercise(
        title: String,
        kind: WorkoutKind,
        weightPounds: Int?,
        reps: Int?,
        distanceKilometers: Double?
    ) -> WorkoutExercise? {
        if kind.tracksDistance {
            guard let distanceKilometers, distanceKilometers > 0 else { return nil }
            return WorkoutExercise(
                name: title,
                sets: 1,
                weightPounds: 0,
                reps: 1,
                distanceKilometers: distanceKilometers
            )
        }

        guard let reps, reps > 0 else { return nil }
        return WorkoutExercise(
            name: title,
            sets: 1,
            weightPounds: weightPounds ?? 0,
            reps: reps,
            distanceKilometers: 0
        )
    }
}

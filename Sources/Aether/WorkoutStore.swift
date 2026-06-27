import Foundation
import Observation
import UserNotifications

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
            "Allow access to read calories, heart rate, steps, and activity metrics from Apple Health."
        case .unavailable:
            "HealthKit is not available on this device."
        case .authorized:
            "Health metrics can sync from Apple Health."
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

private enum OnboardingStage: Int {
    case welcome = 1
    case goals
    case quiz
    case result
    case paywall
    case login
    case health

    static let totalCount = 7
}

private struct AetherSettings: Codable {
    var weeklyGoalMinutes: Int
    var energyUnit: EnergyUnit
    var distanceUnit: DistanceUnit
    var hasSeenWelcome: Bool
    var selectedGoals: [FitnessGoal]
    var onboardingQuizProfile: OnboardingQuizProfile?
    var hasSeenPlanPreview: Bool
    var accessTier: AccessTier?
    var isOnboarded: Bool
    var hasSeenHealthPrompt: Bool
    var userDisplayName: String
    var authProvider: AuthProvider?
    var emailAddress: String
    var genderIdentity: GenderIdentity
    var heightInches: Int
    var weightPounds: Int
    var dateOfBirth: Date
    var profilePhotoData: Data?
    var profilePhotoScale: Double
    var profilePhotoOffsetX: Double
    var profilePhotoOffsetY: Double
    var workoutTemplates: [WorkoutTemplate]
    var plannedWorkoutDays: [WorkoutDay]
    var remindersEnabled: Bool
    var selectedProPlan: ProPlanOption
    var prefersDirectSignIn: Bool

    static let defaults = AetherSettings(
        weeklyGoalMinutes: 180,
        energyUnit: .kilocalories,
        distanceUnit: .kilometers,
        hasSeenWelcome: false,
        selectedGoals: [],
        onboardingQuizProfile: nil,
        hasSeenPlanPreview: false,
        accessTier: nil,
        isOnboarded: false,
        hasSeenHealthPrompt: false,
        userDisplayName: "",
        authProvider: nil,
        emailAddress: "",
        genderIdentity: .other,
        heightInches: 68,
        weightPounds: 160,
        dateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now,
        profilePhotoData: nil,
        profilePhotoScale: 1,
        profilePhotoOffsetX: 0,
        profilePhotoOffsetY: 0,
        workoutTemplates: WorkoutTemplate.defaults,
        plannedWorkoutDays: [.monday, .wednesday, .friday],
        remindersEnabled: false,
        selectedProPlan: .trial,
        prefersDirectSignIn: false
    )

    init(
        weeklyGoalMinutes: Int,
        energyUnit: EnergyUnit,
        distanceUnit: DistanceUnit,
        hasSeenWelcome: Bool,
        selectedGoals: [FitnessGoal],
        onboardingQuizProfile: OnboardingQuizProfile?,
        hasSeenPlanPreview: Bool,
        accessTier: AccessTier?,
        isOnboarded: Bool,
        hasSeenHealthPrompt: Bool,
        userDisplayName: String,
        authProvider: AuthProvider?,
        emailAddress: String,
        genderIdentity: GenderIdentity,
        heightInches: Int,
        weightPounds: Int,
        dateOfBirth: Date,
        profilePhotoData: Data?,
        profilePhotoScale: Double,
        profilePhotoOffsetX: Double,
        profilePhotoOffsetY: Double,
        workoutTemplates: [WorkoutTemplate],
        plannedWorkoutDays: [WorkoutDay],
        remindersEnabled: Bool,
        selectedProPlan: ProPlanOption,
        prefersDirectSignIn: Bool
    ) {
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.energyUnit = energyUnit
        self.distanceUnit = distanceUnit
        self.hasSeenWelcome = hasSeenWelcome
        self.selectedGoals = selectedGoals
        self.onboardingQuizProfile = onboardingQuizProfile
        self.hasSeenPlanPreview = hasSeenPlanPreview
        self.accessTier = accessTier
        self.isOnboarded = isOnboarded
        self.hasSeenHealthPrompt = hasSeenHealthPrompt
        self.userDisplayName = userDisplayName
        self.authProvider = authProvider
        self.emailAddress = emailAddress
        self.genderIdentity = genderIdentity
        self.heightInches = heightInches
        self.weightPounds = weightPounds
        self.dateOfBirth = dateOfBirth
        self.profilePhotoData = profilePhotoData
        self.profilePhotoScale = profilePhotoScale
        self.profilePhotoOffsetX = profilePhotoOffsetX
        self.profilePhotoOffsetY = profilePhotoOffsetY
        self.workoutTemplates = workoutTemplates
        self.plannedWorkoutDays = plannedWorkoutDays
        self.remindersEnabled = remindersEnabled
        self.selectedProPlan = selectedProPlan
        self.prefersDirectSignIn = prefersDirectSignIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let legacyContainer = try decoder.container(keyedBy: LegacyCodingKeys.self)
        let defaults = Self.defaults

        weeklyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .weeklyGoalMinutes) ?? defaults.weeklyGoalMinutes
        energyUnit = try container.decodeIfPresent(EnergyUnit.self, forKey: .energyUnit) ?? defaults.energyUnit
        distanceUnit = try container.decodeIfPresent(DistanceUnit.self, forKey: .distanceUnit) ?? defaults.distanceUnit
        hasSeenWelcome = try container.decodeIfPresent(Bool.self, forKey: .hasSeenWelcome) ?? defaults.hasSeenWelcome
        selectedGoals = try container.decodeIfPresent([FitnessGoal].self, forKey: .selectedGoals) ?? defaults.selectedGoals
        onboardingQuizProfile = try container.decodeIfPresent(OnboardingQuizProfile.self, forKey: .onboardingQuizProfile) ?? defaults.onboardingQuizProfile
        hasSeenPlanPreview = try container.decodeIfPresent(Bool.self, forKey: .hasSeenPlanPreview) ?? defaults.hasSeenPlanPreview
        accessTier = try container.decodeIfPresent(AccessTier.self, forKey: .accessTier)
            ?? ((try legacyContainer.decodeIfPresent(Bool.self, forKey: .hasUnlockedPaywall) ?? false) ? .pro : defaults.accessTier)
        isOnboarded = try container.decodeIfPresent(Bool.self, forKey: .isOnboarded) ?? defaults.isOnboarded
        hasSeenHealthPrompt = try container.decodeIfPresent(Bool.self, forKey: .hasSeenHealthPrompt) ?? defaults.hasSeenHealthPrompt
        userDisplayName = try container.decodeIfPresent(String.self, forKey: .userDisplayName) ?? defaults.userDisplayName
        authProvider = try container.decodeIfPresent(AuthProvider.self, forKey: .authProvider) ?? defaults.authProvider
        emailAddress = try container.decodeIfPresent(String.self, forKey: .emailAddress) ?? defaults.emailAddress
        genderIdentity = try container.decodeIfPresent(GenderIdentity.self, forKey: .genderIdentity) ?? defaults.genderIdentity
        heightInches = try container.decodeIfPresent(Int.self, forKey: .heightInches) ?? defaults.heightInches
        weightPounds = try container.decodeIfPresent(Int.self, forKey: .weightPounds) ?? defaults.weightPounds
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth) ?? defaults.dateOfBirth
        profilePhotoData = try container.decodeIfPresent(Data.self, forKey: .profilePhotoData) ?? defaults.profilePhotoData
        profilePhotoScale = try container.decodeIfPresent(Double.self, forKey: .profilePhotoScale) ?? defaults.profilePhotoScale
        profilePhotoOffsetX = try container.decodeIfPresent(Double.self, forKey: .profilePhotoOffsetX) ?? defaults.profilePhotoOffsetX
        profilePhotoOffsetY = try container.decodeIfPresent(Double.self, forKey: .profilePhotoOffsetY) ?? defaults.profilePhotoOffsetY
        workoutTemplates = try container.decodeIfPresent([WorkoutTemplate].self, forKey: .workoutTemplates) ?? defaults.workoutTemplates
        plannedWorkoutDays = try container.decodeIfPresent([WorkoutDay].self, forKey: .plannedWorkoutDays) ?? defaults.plannedWorkoutDays
        remindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .remindersEnabled) ?? defaults.remindersEnabled
        selectedProPlan = try container.decodeIfPresent(ProPlanOption.self, forKey: .selectedProPlan) ?? defaults.selectedProPlan
        prefersDirectSignIn = try container.decodeIfPresent(Bool.self, forKey: .prefersDirectSignIn) ?? defaults.prefersDirectSignIn
    }

    private enum LegacyCodingKeys: String, CodingKey {
        case hasUnlockedPaywall
    }
}

@MainActor
@Observable
final class WorkoutStore {
    var workouts: [WorkoutEntry]
    var healthMetrics: HealthMetricsSnapshot
    var workoutHistoryFilter: WorkoutHistoryFilter
    var workoutTemplates: [WorkoutTemplate] {
        didSet { saveSettings() }
    }
    var plannedWorkoutDays: [WorkoutDay] {
        didSet { saveSettings() }
    }
    var remindersEnabled: Bool {
        didSet { saveSettings() }
    }
    var selectedFocus: TrainingFocus
    var searchText: String
    var healthStatus: HealthStatus
    var isSyncing: Bool
    var weeklyGoalMinutes: Int {
        didSet { saveSettings() }
    }
    var energyUnit: EnergyUnit {
        didSet { saveSettings() }
    }
    var distanceUnit: DistanceUnit {
        didSet { saveSettings() }
    }
    var hasSeenWelcome: Bool {
        didSet { saveSettings() }
    }
    var selectedGoals: [FitnessGoal] {
        didSet { saveSettings() }
    }
    var onboardingQuizProfile: OnboardingQuizProfile? {
        didSet { saveSettings() }
    }
    var hasSeenPlanPreview: Bool {
        didSet { saveSettings() }
    }
    var accessTier: AccessTier? {
        didSet { saveSettings() }
    }
    var isOnboarded: Bool {
        didSet { saveSettings() }
    }
    var hasSeenHealthPrompt: Bool {
        didSet { saveSettings() }
    }
    var userDisplayName: String {
        didSet { saveSettings() }
    }
    var authProvider: AuthProvider? {
        didSet { saveSettings() }
    }
    var emailAddress: String {
        didSet { saveSettings() }
    }
    var genderIdentity: GenderIdentity {
        didSet { saveSettings() }
    }
    var heightInches: Int {
        didSet { saveSettings() }
    }
    var weightPounds: Int {
        didSet { saveSettings() }
    }
    var dateOfBirth: Date {
        didSet { saveSettings() }
    }
    var profilePhotoData: Data? {
        didSet { saveSettings() }
    }
    var profilePhotoScale: Double {
        didSet { saveSettings() }
    }
    var profilePhotoOffsetX: Double {
        didSet { saveSettings() }
    }
    var profilePhotoOffsetY: Double {
        didSet { saveSettings() }
    }
    var selectedProPlan: ProPlanOption {
        didSet { saveSettings() }
    }
    var prefersDirectSignIn: Bool {
        didSet { saveSettings() }
    }

    private let healthKit: HealthKitClient
    private let persistenceURL: URL
    private let settingsURL: URL

    init(healthKit: HealthKitClient? = nil) {
        let healthKit = healthKit ?? HealthKitClient()
        self.healthKit = healthKit
        self.persistenceURL = Self.makePersistenceURL()
        self.settingsURL = Self.makeSettingsURL()
        self.workouts = []
        self.healthMetrics = HealthMetricsSnapshot()
        self.workoutHistoryFilter = .oneMonth
        self.workoutTemplates = WorkoutTemplate.defaults
        self.plannedWorkoutDays = [.monday, .wednesday, .friday]
        self.remindersEnabled = false
        self.selectedFocus = .all
        self.searchText = ""
        self.healthStatus = healthKit.isHealthDataAvailable ? .notRequested : .unavailable
        self.isSyncing = false
        self.weeklyGoalMinutes = 180
        self.energyUnit = .kilocalories
        self.distanceUnit = .kilometers
        self.hasSeenWelcome = false
        self.selectedGoals = []
        self.onboardingQuizProfile = nil
        self.hasSeenPlanPreview = false
        self.accessTier = nil
        self.isOnboarded = false
        self.hasSeenHealthPrompt = false
        self.userDisplayName = ""
        self.authProvider = nil
        self.emailAddress = ""
        self.genderIdentity = .other
        self.heightInches = 68
        self.weightPounds = 160
        self.dateOfBirth = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
        self.profilePhotoData = nil
        self.profilePhotoScale = 1
        self.profilePhotoOffsetX = 0
        self.profilePhotoOffsetY = 0
        self.selectedProPlan = .trial
        self.prefersDirectSignIn = false

        loadSettings()
        load()
    }

    var filteredWorkouts: [WorkoutEntry] {
        workouts
            .filter { workout in
                let isAppLogged = workout.source == .app
                let isInsideHistoryWindow = workoutHistoryFilter.startDate.map { workout.startDate >= $0 } ?? true
                let matchesFocus = selectedFocus == .all || workout.kind.focus == selectedFocus
                let matchesSearch = searchText.isEmpty
                    || workout.title.localizedCaseInsensitiveContains(searchText)
                    || workout.kind.rawValue.localizedCaseInsensitiveContains(searchText)
                    || workout.notes.localizedCaseInsensitiveContains(searchText)
                    || workout.exercises.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
                return isAppLogged && isInsideHistoryWindow && matchesFocus && matchesSearch
            }
            .sorted { $0.startDate > $1.startDate }
    }

    var recentWorkouts: [WorkoutEntry] {
        Array(workouts.filter { $0.source == .app }.sorted { $0.startDate > $1.startDate }.prefix(6))
    }

    var weeklyWorkouts: [WorkoutEntry] {
        let interval = currentWeekInterval
        return workouts.filter {
            $0.source == .app
                && $0.startDate >= interval.start
                && $0.startDate <= .now
        }
    }

    var generatedPlan: WorkoutPlanRecommendation? {
        guard let onboardingQuizProfile else { return nil }
        return makePlan(for: onboardingQuizProfile)
    }

    var weeklyMinutes: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }

    var weeklyEnergy: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.energyKilocalories }
    }

    var weeklyVolume: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.volumeLoad }
    }

    var trainedDaysThisWeek: Int {
        let calendar = Calendar.current
        let weekdays = Set(weeklyWorkouts.map { calendar.component(.weekday, from: $0.startDate) })
        return weekdays.count
    }

    var aetherScore: Int {
        min(aetherScoreBreakdown.reduce(0) { $0 + $1.value }, 100)
    }

    var aetherScoreGrade: String {
        switch aetherScore {
        case 90...: "A"
        case 80..<90: "B"
        case 70..<80: "C"
        case 60..<70: "D"
        default: "E"
        }
    }

    var aetherScoreLabel: String {
        switch aetherScore {
        case 90...: "Locked in"
        case 80..<90: "On pace"
        case 70..<80: "Building"
        case 60..<70: "Needs structure"
        default: "Reset week"
        }
    }

    var aetherScoreBreakdown: [ScoreBreakdownItem] {
        let consistencyPoints = Int((sessionGoalProgress * 35).rounded())
        let streakPoints = min(consistencyStreakDays * 4, 20)
        let volumePoints = min(Int((Double(weeklyVolume) / 4_000 * 20).rounded()), 20)
        let stepsPoints = min(Int((Double(healthMetrics.steps) / 70_000 * 15).rounded()), 15)
        let sessionPoints = min(weeklyWorkouts.count * 5, 10)

        return [
            ScoreBreakdownItem(title: "Consistency", value: max(consistencyPoints, 0), maxValue: 35),
            ScoreBreakdownItem(title: "Streak", value: max(streakPoints, 0), maxValue: 20),
            ScoreBreakdownItem(title: "Volume", value: max(volumePoints, 0), maxValue: 20),
            ScoreBreakdownItem(title: "Steps", value: max(stepsPoints, 0), maxValue: 15),
            ScoreBreakdownItem(title: "Sessions", value: max(sessionPoints, 0), maxValue: 10)
        ]
    }

    var weeklySessionGoal: Int {
        max(plannedWorkoutDays.count, 1)
    }

    var sessionGoalProgress: Double {
        min(Double(trainedDaysThisWeek) / Double(weeklySessionGoal), 1)
    }

    var consistencyStreakDays: Int {
        let calendar = Calendar.current
        let trainedDays = Set(workouts.filter { $0.source == .app }.map { calendar.startOfDay(for: $0.startDate) })
        guard !trainedDays.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: .now)
        if !trainedDays.contains(cursor), let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) {
            cursor = yesterday
        }

        var streak = 0
        while trainedDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    var totalDistanceKilometers: Double {
        let loggedDistance = workouts.filter { $0.source == .app }.compactMap(\.distanceKilometers).reduce(0, +)
        return loggedDistance + healthMetrics.walkingRunningDistanceKilometers
    }

    var bestWeightEntry: WorkoutEntry? {
        workouts
            .filter { $0.source == .app && ($0.weightPounds ?? 0) > 0 }
            .max { ($0.weightPounds ?? 0) < ($1.weightPounds ?? 0) }
    }

    var bestVolumeEntry: WorkoutEntry? {
        workouts
            .filter { $0.source == .app && $0.volumeLoad > 0 }
            .max { $0.volumeLoad < $1.volumeLoad }
    }

    var weeklyGoalTrend: [ProgressTrendPoint] {
        let calendar = Calendar.current
        let target = weeklySessionGoal

        return (0..<4).reversed().compactMap { offset in
            guard
                let weekDate = calendar.date(byAdding: .weekOfYear, value: -offset, to: .now),
                let interval = calendar.dateInterval(of: .weekOfYear, for: weekDate)
            else {
                return nil
            }

            let completed = Set(workouts.filter { workout in
                workout.source == .app
                    && workout.startDate >= interval.start
                    && workout.startDate < interval.end
            }.map { calendar.component(.weekday, from: $0.startDate) }).count

            let title = offset == 0 ? "This" : "\(offset)w"
            return ProgressTrendPoint(title: title, completed: completed, target: target)
        }
    }

    private var currentWeekInterval: DateInterval {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .weekOfYear, for: .now) ?? DateInterval(start: .now, end: .now)
    }

    var workoutsByWeek: [(weekStart: Date, workouts: [WorkoutEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredWorkouts) { workout in
            calendar.dateInterval(of: .weekOfYear, for: workout.startDate)?.start ?? calendar.startOfDay(for: workout.startDate)
        }

        return grouped
            .map { (weekStart: $0.key, workouts: $0.value.sorted { $0.startDate > $1.startDate }) }
            .sorted { $0.weekStart > $1.weekStart }
    }

    var loggedWorkoutCount: Int {
        workouts.filter { $0.source == .app }.count
    }

    var reportCardShareText: String {
        [
            "Aether Weekly Report",
            "Score: \(aetherScore)/100 (\(aetherScoreGrade))",
            "Workouts: \(weeklyWorkouts.count)",
            "Days Trained: \(trainedDaysThisWeek)",
            "Streak: \(consistencyStreakDays) days",
            "Volume: \(weeklyVolume.formatted(.number.grouping(.automatic))) lb x reps",
            "Distance: \(formattedDistance(forKilometers: totalDistanceKilometers))",
            "Heart Rate: \(healthMetrics.heartRateText) bpm"
        ].joined(separator: "\n")
    }

    var reportHeadline: String {
        if let plan = generatedPlan {
            return plan.insight
        }

        if sessionGoalProgress >= 1 {
            return "You hit your target. Stay on that pace."
        }

        return "A little more consistency will move the score fast."
    }

    var reminderStatusText: String {
        if remindersEnabled {
            let days = plannedWorkoutDays.map(\.shortTitle).joined(separator: " ")
            return "Reminders on for \(days)"
        }
        return "Reminders off"
    }

    var healthSyncTitle: String {
        switch healthStatus {
        case .notRequested:
            "Connect Apple Health"
        case .unavailable:
            "Health unavailable"
        case .authorized:
            "Health metrics synced"
        case .failed:
            "Try Health sync again"
        }
    }

    var healthSyncDetail: String {
        if let updatedAt = healthMetrics.updatedAt {
            return "Last updated \(updatedAt.formatted(date: .abbreviated, time: .shortened))."
        }

        return healthStatus.detail
    }

    var healthSyncButtonTitle: String {
        switch healthStatus {
        case .authorized: "Sync"
        case .unavailable: "Unavailable"
        case .notRequested, .failed: "Connect"
        }
    }

    var averageEffort: Double {
        guard !weeklyWorkouts.isEmpty else { return 0 }
        let total = weeklyWorkouts.reduce(0) { $0 + $1.perceivedEffort }
        return Double(total) / Double(weeklyWorkouts.count)
    }

    var greetingName: String {
        let trimmed = userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Athlete" : trimmed
    }

    var onboardingProviderText: String {
        guard let authProvider else { return "Not signed in" }
        if authProvider == .email, !emailAddress.isEmpty {
            return "Signed in with \(emailAddress)"
        }
        return "Signed in with \(authProvider.rawValue)"
    }

    var goalsSummaryText: String {
        guard !selectedGoals.isEmpty else { return "No goals selected" }
        return selectedGoals.map(\.rawValue).joined(separator: ", ")
    }

    var heightText: String {
        let feet = heightInches / 12
        let inches = heightInches % 12
        return "\(feet) ft \(inches) in"
    }

    var weightText: String {
        "\(weightPounds) lb"
    }

    var needsGoalSelection: Bool {
        !prefersDirectSignIn && selectedGoals.isEmpty
    }

    var needsOnboardingQuiz: Bool {
        !prefersDirectSignIn && !selectedGoals.isEmpty && onboardingQuizProfile == nil
    }

    var needsPlanPreview: Bool {
        !prefersDirectSignIn && onboardingQuizProfile != nil && !hasSeenPlanPreview
    }

    var needsPaywall: Bool {
        !prefersDirectSignIn && hasSeenPlanPreview && accessTier == nil
    }

    var isProTier: Bool {
        accessTier == .pro
    }

    var isFreeTier: Bool {
        accessTier == .free
    }

    var needsWelcome: Bool {
        !hasSeenWelcome
    }

    var needsAuthentication: Bool {
        !isOnboarded
    }

    var isDirectSignInFlow: Bool {
        prefersDirectSignIn && !isOnboarded
    }

    var needsHealthPrompt: Bool {
        isOnboarded && !hasSeenHealthPrompt
    }

    var onboardingStepIndex: Int? {
        if isDirectSignInFlow {
            return nil
        }
        return currentOnboardingStage?.rawValue
    }

    var onboardingStepCount: Int {
        OnboardingStage.totalCount
    }

    var onboardingProgress: Double {
        guard let onboardingStepIndex else { return 0 }
        return Double(onboardingStepIndex) / Double(onboardingStepCount)
    }

    var canMoveBackInOnboarding: Bool {
        if isDirectSignInFlow {
            return true
        }
        guard let stage = currentOnboardingStage else { return false }
        switch stage {
        case .welcome, .health:
            return false
        case .goals, .quiz, .result, .paywall, .login:
            return true
        }
    }

    var goalProgress: Double {
        guard weeklyGoalMinutes > 0 else { return 0 }
        return min(Double(weeklyMinutes) / Double(weeklyGoalMinutes), 1)
    }

    func energyValueText(forKilocalories kilocalories: Int) -> String {
        energyUnit.valueText(forKilocalories: kilocalories)
    }

    func formattedEnergy(forKilocalories kilocalories: Int) -> String {
        energyUnit.formattedEnergy(forKilocalories: kilocalories)
    }

    func formattedDistance(forKilometers kilometers: Double) -> String {
        distanceUnit.formattedDistance(forKilometers: kilometers)
    }

    func syncHealthWorkouts() async {
        guard healthKit.isHealthDataAvailable else {
            healthStatus = .unavailable
            return
        }

        if healthStatus == .authorized {
            await refreshFromHealth()
        } else {
            await requestHealthAccess()
        }
    }

    func toggleGoal(_ goal: FitnessGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else {
            selectedGoals.append(goal)
        }
    }

    func completeOnboarding(provider: AuthProvider, displayName: String = "") {
        applyDirectSignInDefaultsIfNeeded()
        authProvider = provider
        userDisplayName = displayName
        if provider != .email {
            emailAddress = ""
        }
        prefersDirectSignIn = false
        isOnboarded = true
    }

    func completeEmailOnboarding(displayName: String, email: String) {
        applyDirectSignInDefaultsIfNeeded()
        authProvider = .email
        userDisplayName = displayName
        emailAddress = email
        prefersDirectSignIn = false
        isOnboarded = true
    }

    func completeOnboardingQuiz(_ profile: OnboardingQuizProfile) {
        onboardingQuizProfile = profile
        genderIdentity = profile.genderIdentity
        dateOfBirth = profile.dateOfBirth

        if let plan = generatedPlan {
            weeklyGoalMinutes = plan.targetWorkoutMinutes
            plannedWorkoutDays = plan.recommendedDays

            var mergedTemplates = workoutTemplates
            for template in plan.templates.reversed() {
                mergedTemplates.removeAll { $0.name.localizedCaseInsensitiveCompare(template.name) == .orderedSame }
                mergedTemplates.insert(template, at: 0)
            }
            workoutTemplates = mergedTemplates
        }
    }

    func markPlanPreviewSeen() {
        hasSeenPlanPreview = true
    }

    func unlockProAccess() {
        accessTier = .pro
    }

    func continueWithFreeTier() {
        accessTier = .free
    }

    func markHealthPromptSeen() {
        hasSeenHealthPrompt = true
    }

    func markWelcomeSeen() {
        hasSeenWelcome = true
    }

    func startDirectSignIn() {
        hasSeenWelcome = true
        prefersDirectSignIn = true
    }

    func goBackInOnboarding() {
        if isDirectSignInFlow {
            prefersDirectSignIn = false
            hasSeenWelcome = false
            return
        }

        guard let stage = currentOnboardingStage else { return }

        switch stage {
        case .welcome:
            break
        case .goals:
            hasSeenWelcome = false
        case .quiz:
            selectedGoals = []
        case .result:
            onboardingQuizProfile = nil
        case .paywall:
            hasSeenPlanPreview = false
        case .login:
            accessTier = nil
        case .health:
            break
        }
    }

    func signOutForTesting() {
        hasSeenWelcome = false
        selectedGoals = []
        onboardingQuizProfile = nil
        hasSeenPlanPreview = false
        accessTier = nil
        isOnboarded = false
        hasSeenHealthPrompt = false
        prefersDirectSignIn = false
        authProvider = nil
        emailAddress = ""
        userDisplayName = ""
        genderIdentity = .other
        selectedProPlan = .trial
        healthMetrics = HealthMetricsSnapshot()
        healthStatus = healthKit.isHealthDataAvailable ? .notRequested : .unavailable
        workouts = []
        workoutTemplates = WorkoutTemplate.defaults
        plannedWorkoutDays = [.monday, .wednesday, .friday]
        remindersEnabled = false
        save()
    }

    func bootstrapHealthStatus() async {
        guard healthKit.isHealthDataAvailable else {
            healthStatus = .unavailable
            return
        }

        do {
            healthMetrics = try await healthKit.fetchCurrentWeekMetrics()
            healthStatus = .authorized
        } catch {
            if healthStatus != .authorized {
                healthStatus = .notRequested
            }
        }
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
            hasSeenHealthPrompt = true
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
            healthMetrics = try await healthKit.fetchCurrentWeekMetrics()
            healthStatus = .authorized
        } catch {
            if !silent {
                healthStatus = .failed(error.localizedDescription)
            }
        }
    }

    func deleteWorkouts(at offsets: IndexSet) {
        let visibleIDs = filteredWorkouts.map(\.id)
        let idsToDelete = offsets.compactMap { visibleIDs[safe: $0] }
        workouts.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    func saveTrackedWorkout(_ draft: WorkoutTrackingDraft) async {
        guard draft.isSubmittable else { return }

        let workout = WorkoutEntry(
            kind: draft.kind,
            title: draft.title,
            startDate: dateInCurrentWeek(for: draft.day),
            durationMinutes: 0,
            energyKilocalories: 0,
            distanceKilometers: draft.kind.tracksDistance ? draft.totalDistanceKilometers : nil,
            perceivedEffort: 6,
            source: .app,
            notes: draft.summaryNotes,
            splitName: draft.splitName,
            exercises: draft.filledExercises,
            weightPounds: draft.kind.tracksDistance ? nil : draft.primaryWeightPounds,
            reps: draft.kind.tracksDistance ? nil : draft.primaryReps
        )

        workouts.insert(workout, at: 0)
        workouts.sort { $0.startDate > $1.startDate }
        save()
    }

    func saveTemplate(from draft: WorkoutTrackingDraft) {
        guard draft.isSubmittable else { return }
        let template = WorkoutTemplate(draft: draft)
        workoutTemplates.removeAll { $0.name.localizedCaseInsensitiveCompare(template.name) == .orderedSame }
        workoutTemplates.insert(template, at: 0)
    }

    func deleteTemplate(_ template: WorkoutTemplate) {
        workoutTemplates.removeAll { $0.id == template.id }
    }

    func togglePlannedWorkoutDay(_ day: WorkoutDay) {
        if plannedWorkoutDays.contains(day) {
            plannedWorkoutDays.removeAll { $0 == day }
        } else {
            plannedWorkoutDays.append(day)
            plannedWorkoutDays.sort { lhs, rhs in
                (WorkoutDay.allCases.firstIndex(of: lhs) ?? 0) < (WorkoutDay.allCases.firstIndex(of: rhs) ?? 0)
            }
        }

        if remindersEnabled {
            Task { await scheduleWorkoutReminders() }
        }
    }

    func updateReminderPreference(_ enabled: Bool) async {
        if enabled {
            let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            remindersEnabled = granted == true
            if remindersEnabled {
                await scheduleWorkoutReminders()
            }
        } else {
            remindersEnabled = false
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: persistenceURL) else { return }
        guard let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) else { return }
        workouts = decoded.filter { $0.source == .app }
    }

    private func dateInCurrentWeek(for day: WorkoutDay) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        components.weekday = (WorkoutDay.allCases.firstIndex(of: day) ?? 0) + 1
        components.hour = calendar.component(.hour, from: .now)
        components.minute = calendar.component(.minute, from: .now)
        return calendar.date(from: components) ?? .now
    }

    private func loadSettings() {
        guard let data = try? Data(contentsOf: settingsURL) else { return }
        guard let decoded = try? JSONDecoder().decode(AetherSettings.self, from: data) else { return }
        weeklyGoalMinutes = decoded.weeklyGoalMinutes
        energyUnit = decoded.energyUnit
        distanceUnit = decoded.distanceUnit
        hasSeenWelcome = decoded.hasSeenWelcome
        selectedGoals = decoded.selectedGoals
        onboardingQuizProfile = decoded.onboardingQuizProfile
        hasSeenPlanPreview = decoded.hasSeenPlanPreview
        accessTier = decoded.accessTier
        isOnboarded = decoded.isOnboarded
        hasSeenHealthPrompt = decoded.hasSeenHealthPrompt
        userDisplayName = decoded.userDisplayName
        authProvider = decoded.authProvider
        emailAddress = decoded.emailAddress
        genderIdentity = decoded.genderIdentity
        heightInches = decoded.heightInches
        weightPounds = decoded.weightPounds
        dateOfBirth = decoded.dateOfBirth
        profilePhotoData = decoded.profilePhotoData
        profilePhotoScale = decoded.profilePhotoScale
        profilePhotoOffsetX = decoded.profilePhotoOffsetX
        profilePhotoOffsetY = decoded.profilePhotoOffsetY
        workoutTemplates = migratedTemplates(from: decoded.workoutTemplates)
        plannedWorkoutDays = decoded.plannedWorkoutDays
        remindersEnabled = decoded.remindersEnabled
        selectedProPlan = decoded.selectedProPlan
        prefersDirectSignIn = decoded.prefersDirectSignIn
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

    private func saveSettings() {
        let settings = AetherSettings(
            weeklyGoalMinutes: weeklyGoalMinutes,
            energyUnit: energyUnit,
            distanceUnit: distanceUnit,
            hasSeenWelcome: hasSeenWelcome,
            selectedGoals: selectedGoals,
            onboardingQuizProfile: onboardingQuizProfile,
            hasSeenPlanPreview: hasSeenPlanPreview,
            accessTier: accessTier,
            isOnboarded: isOnboarded,
            hasSeenHealthPrompt: hasSeenHealthPrompt,
            userDisplayName: userDisplayName,
            authProvider: authProvider,
            emailAddress: emailAddress,
            genderIdentity: genderIdentity,
            heightInches: heightInches,
            weightPounds: weightPounds,
            dateOfBirth: dateOfBirth,
            profilePhotoData: profilePhotoData,
            profilePhotoScale: profilePhotoScale,
            profilePhotoOffsetX: profilePhotoOffsetX,
            profilePhotoOffsetY: profilePhotoOffsetY,
            workoutTemplates: workoutTemplates,
            plannedWorkoutDays: plannedWorkoutDays,
            remindersEnabled: remindersEnabled,
            selectedProPlan: selectedProPlan,
            prefersDirectSignIn: prefersDirectSignIn
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(settings) else { return }

        try? FileManager.default.createDirectory(
            at: settingsURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try? data.write(to: settingsURL, options: [.atomic])
    }

    private func migratedTemplates(from templates: [WorkoutTemplate]) -> [WorkoutTemplate] {
        guard !templates.isEmpty else { return WorkoutTemplate.defaults }

        let upgradedDefaults = Dictionary(
            uniqueKeysWithValues: WorkoutTemplate.defaults.map { ($0.name, $0) }
        )

        return templates.map { template in
            guard
                template.exerciseCount <= 1,
                let upgraded = upgradedDefaults[template.name]
            else {
                return template
            }

            let isLegacySingleExercise = template.exercises.count == 1
                && template.exercises[0].name == template.workoutName

            return isLegacySingleExercise ? upgraded : template
        }
    }

    private static func makePersistenceURL() -> URL {
        makeSupportDirectory()
            .appendingPathComponent("workouts.json")
    }

    private static func makeSettingsURL() -> URL {
        makeSupportDirectory()
            .appendingPathComponent("settings.json")
    }

    private static func makeSupportDirectory() -> URL {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return supportDirectory
            .appendingPathComponent("Aether", isDirectory: true)
    }

    private var reminderIdentifiers: [String] {
        WorkoutDay.allCases.map { "aether.workout-reminder.\($0.rawValue)" }
    }

    private func scheduleWorkoutReminders() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)

        for day in plannedWorkoutDays {
            let content = UNMutableNotificationContent()
            content.title = "Aether"
            content.body = "Planned workout today."
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = (WorkoutDay.allCases.firstIndex(of: day) ?? 0) + 1
            dateComponents.hour = 8
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "aether.workout-reminder.\(day.rawValue)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    private var currentOnboardingStage: OnboardingStage? {
        if needsWelcome { return .welcome }
        if needsGoalSelection { return .goals }
        if needsOnboardingQuiz { return .quiz }
        if needsPlanPreview { return .result }
        if needsPaywall { return .paywall }
        if needsAuthentication { return .login }
        if needsHealthPrompt { return .health }
        return nil
    }

    private func makePlan(for profile: OnboardingQuizProfile) -> WorkoutPlanRecommendation {
        let hasStrengthGoal = selectedGoals.contains(.hypertrophy) || selectedGoals.contains(.strength)
        let hasCardioGoal = selectedGoals.contains(.endurance) || selectedGoals.contains(.weightLoss) || selectedGoals.contains(.fitnessTracking)
        let hasMobilityGoal = selectedGoals.contains(.mobility)
        let sessionCount = max(2, min(profile.trainingDaysPerWeek, 6))
        let recommendedDays = Array(WorkoutDay.allCases.dropFirst().prefix(sessionCount))

        let title: String
        let subtitle: String
        let scoreTarget: Int
        let targetWorkoutMinutes: Int
        let templates: [WorkoutTemplate]

        if hasStrengthGoal && !hasCardioGoal {
            title = "Lean Muscle Builder"
            subtitle = "A \(sessionCount)-day split built to drive volume without burning you out."
            scoreTarget = profile.experience == .advanced ? 90 : 84
            targetWorkoutMinutes = sessionCount * 55
            templates = strengthPlanTemplates(for: sessionCount)
        } else if hasCardioGoal && !hasStrengthGoal {
            title = "Conditioning Reset"
            subtitle = "Shorter sessions with enough output to improve recovery and consistency."
            scoreTarget = 80
            targetWorkoutMinutes = sessionCount * 40
            templates = cardioPlanTemplates(for: sessionCount)
        } else {
            title = "Hybrid Momentum Plan"
            subtitle = "Strength anchors plus cardio work so the week feels balanced and sustainable."
            scoreTarget = 86
            targetWorkoutMinutes = sessionCount * 48
            templates = hybridPlanTemplates(for: sessionCount, mobilityFocus: hasMobilityGoal)
        }

        let insight = switch profile.biggestChallenge {
        case .consistency:
            "Your plan leans shorter and repeatable so you can stack wins fast."
        case .motivation:
            "You need visible momentum, so this plan front-loads quick sessions and measurable targets."
        case .strengthPlateau:
            "Your next breakthrough comes from structure and progressive overload, not randomness."
        case .lowCardio:
            "A stronger aerobic base will make everything else feel easier."
        case .bodyComposition:
            "Weekly output and habit consistency will move the needle more than perfection."
        case .time:
            "You do not need longer workouts. You need less friction."
        }

        return WorkoutPlanRecommendation(
            title: title,
            subtitle: subtitle,
            insight: insight,
            scoreTarget: scoreTarget,
            targetWorkoutMinutes: targetWorkoutMinutes,
            recommendedDays: recommendedDays,
            templates: templates
        )
    }

    private func applyDirectSignInDefaultsIfNeeded() {
        guard prefersDirectSignIn else { return }

        if selectedGoals.isEmpty {
            selectedGoals = [.fitnessTracking]
        }

        if onboardingQuizProfile == nil {
            onboardingQuizProfile = OnboardingQuizProfile(
                experience: .intermediate,
                trainingDaysPerWeek: 3,
                biggestChallenge: .consistency,
                targetDate: Calendar.current.date(byAdding: .day, value: 56, to: .now) ?? .now,
                genderIdentity: genderIdentity,
                dateOfBirth: dateOfBirth
            )
        }

        if !hasSeenPlanPreview {
            hasSeenPlanPreview = true
        }

        if accessTier == nil {
            accessTier = .free
        }
    }

    private func strengthPlanTemplates(for count: Int) -> [WorkoutTemplate] {
        let all = [
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
                name: "Upper Volume",
                kind: .strength,
                muscleGroups: [.chest, .back, .shoulders],
                workoutName: "Upper Volume",
                splitName: "Upper",
                exercises: [
                    WorkoutExercise(name: "Incline Dumbbell Press", sets: 3, weightPounds: 70, reps: 12, distanceKilometers: 0),
                    WorkoutExercise(name: "Single Arm Row", sets: 3, weightPounds: 75, reps: 12, distanceKilometers: 0),
                    WorkoutExercise(name: "Machine Shoulder Press", sets: 2, weightPounds: 85, reps: 12, distanceKilometers: 0),
                    WorkoutExercise(name: "Cable Lateral Raise", sets: 2, weightPounds: 20, reps: 15, distanceKilometers: 0)
                ]
            ),
            WorkoutTemplate(
                name: "Lower Power",
                kind: .strength,
                muscleGroups: [.legs, .wholeBody],
                workoutName: "Lower Power",
                splitName: "Lower",
                exercises: [
                    WorkoutExercise(name: "Back Squat", sets: 4, weightPounds: 205, reps: 5, distanceKilometers: 0),
                    WorkoutExercise(name: "Deadlift", sets: 3, weightPounds: 225, reps: 5, distanceKilometers: 0),
                    WorkoutExercise(name: "Bulgarian Split Squat", sets: 2, weightPounds: 45, reps: 10, distanceKilometers: 0),
                    WorkoutExercise(name: "Hanging Knee Raise", sets: 3, weightPounds: 0, reps: 12, distanceKilometers: 0)
                ]
            )
        ]
        return Array(all.prefix(count))
    }

    private func cardioPlanTemplates(for count: Int) -> [WorkoutTemplate] {
        let all = [
            WorkoutTemplate(
                name: "5K Run",
                kind: .run,
                muscleGroups: [.wholeBody],
                workoutName: "5K Run",
                splitName: "Run",
                exercises: [
                    WorkoutExercise(name: "Warm Up Jog", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 1),
                    WorkoutExercise(name: "Main Run", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 5),
                    WorkoutExercise(name: "Cool Down Walk", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 0.8)
                ]
            ),
            WorkoutTemplate(
                name: "Zone 2 Walk",
                kind: .walk,
                muscleGroups: [.wholeBody],
                workoutName: "Zone 2 Walk",
                splitName: "Walk",
                exercises: [
                    WorkoutExercise(name: "Warm Up Walk", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 0.8),
                    WorkoutExercise(name: "Zone 2 Block", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 4),
                    WorkoutExercise(name: "Cool Down Walk", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 0.5)
                ]
            ),
            WorkoutTemplate(
                name: "Bike Intervals",
                kind: .cycling,
                muscleGroups: [.wholeBody],
                workoutName: "Bike Intervals",
                splitName: "Cycling",
                exercises: [
                    WorkoutExercise(name: "Easy Spin", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 2),
                    WorkoutExercise(name: "Interval Block", sets: 5, weightPounds: 0, reps: 1, distanceKilometers: 1.5),
                    WorkoutExercise(name: "Cool Down Ride", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 2)
                ]
            ),
            WorkoutTemplate(
                name: "HIIT Flush",
                kind: .hiit,
                muscleGroups: [.wholeBody],
                workoutName: "HIIT Flush",
                splitName: "Conditioning",
                exercises: [
                    WorkoutExercise(name: "Bike Sprint", sets: 6, weightPounds: 0, reps: 1, distanceKilometers: 0),
                    WorkoutExercise(name: "Burpee Block", sets: 4, weightPounds: 0, reps: 12, distanceKilometers: 0),
                    WorkoutExercise(name: "Row Finisher", sets: 4, weightPounds: 0, reps: 1, distanceKilometers: 0)
                ]
            )
        ]
        return Array(all.prefix(count))
    }

    private func hybridPlanTemplates(for count: Int, mobilityFocus: Bool) -> [WorkoutTemplate] {
        var all = [
            WorkoutTemplate(
                name: "Upper Build",
                kind: .strength,
                muscleGroups: [.chest, .back, .shoulders],
                workoutName: "Upper Build",
                splitName: "Upper",
                exercises: [
                    WorkoutExercise(name: "Incline Bench", sets: 3, weightPounds: 115, reps: 8, distanceKilometers: 0),
                    WorkoutExercise(name: "Lat Pulldown", sets: 3, weightPounds: 120, reps: 10, distanceKilometers: 0),
                    WorkoutExercise(name: "Machine Row", sets: 3, weightPounds: 100, reps: 10, distanceKilometers: 0),
                    WorkoutExercise(name: "Lateral Raise", sets: 2, weightPounds: 20, reps: 15, distanceKilometers: 0)
                ]
            ),
            WorkoutTemplate(
                name: "Lower Build",
                kind: .strength,
                muscleGroups: [.legs, .core],
                workoutName: "Lower Build",
                splitName: "Lower",
                exercises: [
                    WorkoutExercise(name: "Leg Press", sets: 3, weightPounds: 165, reps: 8, distanceKilometers: 0),
                    WorkoutExercise(name: "Romanian Deadlift", sets: 3, weightPounds: 145, reps: 8, distanceKilometers: 0),
                    WorkoutExercise(name: "Seated Leg Curl", sets: 2, weightPounds: 90, reps: 12, distanceKilometers: 0),
                    WorkoutExercise(name: "Cable Crunch", sets: 3, weightPounds: 70, reps: 12, distanceKilometers: 0)
                ]
            ),
            WorkoutTemplate(
                name: "5K Run",
                kind: .run,
                muscleGroups: [.wholeBody],
                workoutName: "5K Run",
                splitName: "Run",
                exercises: [
                    WorkoutExercise(name: "Warm Up Jog", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 1),
                    WorkoutExercise(name: "Main Run", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 5),
                    WorkoutExercise(name: "Cool Down Walk", sets: 1, weightPounds: 0, reps: 1, distanceKilometers: 0.8)
                ]
            ),
            WorkoutTemplate(
                name: "Full Body Reset",
                kind: .strength,
                muscleGroups: [.wholeBody],
                workoutName: "Full Body Reset",
                splitName: "Full Body",
                exercises: [
                    WorkoutExercise(name: "Goblet Squat", sets: 3, weightPounds: 95, reps: 10, distanceKilometers: 0),
                    WorkoutExercise(name: "Push Up", sets: 3, weightPounds: 0, reps: 12, distanceKilometers: 0),
                    WorkoutExercise(name: "Cable Row", sets: 3, weightPounds: 85, reps: 10, distanceKilometers: 0),
                    WorkoutExercise(name: "Walking Lunge", sets: 2, weightPounds: 30, reps: 12, distanceKilometers: 0)
                ]
            )
        ]

        if mobilityFocus {
            all.append(
                WorkoutTemplate(
                    name: "Mobility Flow",
                    kind: .yoga,
                    muscleGroups: [.core, .wholeBody],
                    workoutName: "Mobility Flow",
                    splitName: "Mobility",
                    exercises: [
                        WorkoutExercise(name: "Breathing Reset", sets: 1, weightPounds: 0, reps: 5, distanceKilometers: 0),
                        WorkoutExercise(name: "Hip Flow", sets: 2, weightPounds: 0, reps: 8, distanceKilometers: 0),
                        WorkoutExercise(name: "Thoracic Rotation", sets: 2, weightPounds: 0, reps: 8, distanceKilometers: 0)
                    ]
                )
            )
        }

        return Array(all.prefix(count))
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

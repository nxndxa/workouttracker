import Foundation

#if canImport(HealthKit)
@preconcurrency import HealthKit
#endif

enum HealthKitClientError: LocalizedError {
    case unavailable
    case missingType
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "HealthKit is not available on this device."
        case .missingType:
            "A required HealthKit data type is unavailable."
        case .saveFailed:
            "The workout could not be saved to Health."
        }
    }
}

#if canImport(HealthKit)
@MainActor
final class HealthKitClient {
    private let store = HKHealthStore()

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else { throw HealthKitClientError.unavailable }

        guard
            let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        else {
            throw HealthKitClientError.missingType
        }

        let workout = HKWorkoutType.workoutType()
        let shareTypes: Set<HKSampleType> = [workout, activeEnergy, distance]
        let readTypes: Set<HKObjectType> = [workout, activeEnergy, distance, heartRate]

        try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func fetchRecentWorkouts(limit: Int) async throws -> [WorkoutEntry] {
        guard isHealthDataAvailable else { throw HealthKitClientError.unavailable }

        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(
                key: HKSampleSortIdentifierEndDate,
                ascending: false
            )

            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: nil,
                limit: limit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = (samples as? [HKWorkout] ?? []).map(WorkoutEntry.init(healthWorkout:))
                continuation.resume(returning: workouts)
            }

            store.execute(query)
        }
    }

    func saveWorkout(_ workout: WorkoutEntry) async throws {
        guard isHealthDataAvailable else { throw HealthKitClientError.unavailable }

        guard
            let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else {
            throw HealthKitClientError.missingType
        }

        let energy = HKQuantity(unit: .kilocalorie(), doubleValue: Double(workout.energyKilocalories))
        let distance = workout.distanceKilometers.map {
            HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: $0)
        }

        let metadata: [String: Any] = [
            HKMetadataKeyWorkoutBrandName: "FitGlass",
            HKMetadataKeyIndoorWorkout: workout.kind == .strength || workout.kind == .yoga
        ]

        let healthWorkout = HKWorkout(
            activityType: workout.kind.healthKitActivityType,
            start: workout.startDate,
            end: workout.endDate,
            duration: TimeInterval(workout.durationMinutes * 60),
            totalEnergyBurned: energy,
            totalDistance: distance,
            metadata: metadata
        )

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(healthWorkout) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitClientError.saveFailed)
                }
            }
        }

        var samples: [HKSample] = [
            HKQuantitySample(
                type: activeEnergyType,
                quantity: energy,
                start: workout.startDate,
                end: workout.endDate
            )
        ]

        if let distance {
            samples.append(
                HKQuantitySample(
                    type: distanceType,
                    quantity: distance,
                    start: workout.startDate,
                    end: workout.endDate
                )
            )
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.add(samples, to: healthWorkout) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitClientError.saveFailed)
                }
            }
        }
    }
}

private extension WorkoutEntry {
    init(healthWorkout workout: HKWorkout) {
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)

        let energy = activeEnergyType.flatMap { type in
            workout.statistics(for: type)?
                .sumQuantity()?
                .doubleValue(for: .kilocalorie())
        } ?? workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0

        let distance = distanceType.flatMap { type in
            workout.statistics(for: type)?
                .sumQuantity()?
                .doubleValue(for: HKUnit.meterUnit(with: .kilo))
        } ?? workout.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: .kilo))

        let heartRate = heartRateType.flatMap { type in
            workout.statistics(for: type)?
                .averageQuantity()?
                .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        }

        self.init(
            id: workout.uuid,
            kind: WorkoutKind(activityType: workout.workoutActivityType),
            title: workout.workoutActivityType.displayName,
            startDate: workout.startDate,
            durationMinutes: max(Int(workout.duration / 60), 1),
            energyKilocalories: Int(energy.rounded()),
            distanceKilometers: distance,
            averageHeartRate: heartRate.map { Int($0.rounded()) },
            perceivedEffort: 6,
            source: .health,
            notes: "Synced from Apple Health"
        )
    }
}

private extension WorkoutKind {
    init(activityType: HKWorkoutActivityType) {
        switch activityType {
        case .running:
            self = .run
        case .walking:
            self = .walk
        case .cycling:
            self = .cycling
        case .traditionalStrengthTraining, .functionalStrengthTraining:
            self = .strength
        case .yoga, .pilates, .flexibility:
            self = .yoga
        case .highIntensityIntervalTraining:
            self = .hiit
        default:
            self = .hiit
        }
    }

    var healthKitActivityType: HKWorkoutActivityType {
        switch self {
        case .run: .running
        case .walk: .walking
        case .cycling: .cycling
        case .strength: .traditionalStrengthTraining
        case .yoga: .yoga
        case .hiit: .highIntensityIntervalTraining
        }
    }
}

private extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .running: "Run"
        case .walking: "Walk"
        case .cycling: "Cycling"
        case .traditionalStrengthTraining, .functionalStrengthTraining: "Strength"
        case .yoga: "Yoga"
        case .pilates: "Pilates"
        case .flexibility: "Mobility"
        case .highIntensityIntervalTraining: "HIIT"
        default: "Workout"
        }
    }
}
#else
@MainActor
final class HealthKitClient {
    var isHealthDataAvailable: Bool { false }

    func requestAuthorization() async throws {
        throw HealthKitClientError.unavailable
    }

    func fetchRecentWorkouts(limit: Int) async throws -> [WorkoutEntry] {
        throw HealthKitClientError.unavailable
    }

    func saveWorkout(_ workout: WorkoutEntry) async throws {
        throw HealthKitClientError.unavailable
    }
}
#endif

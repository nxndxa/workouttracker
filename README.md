# Aether

Aether is a basic SwiftUI workout tracker for iPhone. It starts with a welcome animation, goals, sign-in, and Apple Health connection, then opens into a Health-powered home screen in a black and red native iOS style.

## What is included

- `Aether.xcodeproj` for running on iPhone or iOS Simulator.
- Animated welcome screen with a **Let's Get Started** action.
- Goal selection before sign-in.
- Onboarding with Apple, Google, and SES-backed email verification entry points.
- Apple Health connection prompt before the main dashboard.
- Home dashboard focused on this week's Aether logs and Apple Health metrics.
- Workouts tab for Aether-logged workout history, organized by week.
- Workout Tracking tab for manually logging the workout performed, multiple muscle groups, split, weight, and reps.
- Workout templates for common sessions like **Push Day** and **5K Run**, with the option to save your current form as a reusable template.
- HealthKit authorization for metrics only: calories burned, heart rate, steps, and walking/running distance.
- Workout history filters for 1 week, 1 month, 3 months, 1 year, and all time.
- Progress analytics for weekly volume, days trained, streaks, PRs, total distance, average heart rate, and weekly goal completion.
- Planned workout days and local reminder scheduling.
- Black and red native-feeling UI with restrained Liquid Glass surfaces on iOS 26+.
- Settings opened from the profile button, with Preferences and Info.
- Info screen for profile photo alignment, goals, height, weight, and date of birth.
- No bundled sample workout data.

## Run on iPhone

1. Open `/Users/nandhasankar/Documents/New project/Aether.xcodeproj` in Xcode.
2. Select the `Aether` target, then open **Signing & Capabilities**.
3. Choose your Apple developer team and keep **Automatically manage signing** enabled.
4. Confirm **HealthKit** is present. The project already includes `Aether/Aether.entitlements`.
5. Pick your iPhone as the run destination and press **Run**.
6. On first launch, tap **Let's Get Started**, pick your goals, sign in, then connect Apple Health and grant active energy, steps, distance, and heart-rate read access.

## Using the new controls

- Pick one or more goals before sign-in.
- Use **Continue with Apple**, **Continue with Google**, or **Continue with Email** during onboarding.
- Connect Apple Health before entering the dashboard, or continue in Simulator for layout testing.
- Use **Home** for this week's Aether workout count plus Apple Health calories, steps, and heart rate.
- Use **Workout Tracking** to choose a template or day bubble, select multiple muscle groups, and manually enter the workout you performed.
- Use **Workouts** for workouts logged directly in Aether, grouped by week with history filters.
- Use **Progress** for volume, streaks, PRs, distance, average heart rate, completion trends, planned days, and reminders.
- Tap the profile icon to open settings.
- Use **Settings > Preferences** for energy and distance display.
- Use **Settings > Info** to add and align a profile photo, review goals, and edit height, weight, and date of birth inline.

## Notes

- Health data needs a physical iPhone for realistic testing. The simulator is useful for layout only.
- The bundle identifier is `com.nandhasankar.Aether`; change it before installing on your device if Xcode asks.
- `Package.swift` is still present so the shared Swift files can be compiled locally.
- Google login is a local prototype entry point until a real auth backend/client ID is added.
- Email login now expects an Amazon SES verification backend. Set `AetherAuthBaseURL` in the Xcode project after deploying `Backend/amazon-ses-email-verification`.

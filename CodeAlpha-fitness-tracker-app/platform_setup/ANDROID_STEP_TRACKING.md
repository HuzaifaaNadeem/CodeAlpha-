# Android live step tracking setup

PulseFit MAX uses `pedometer` plus `permission_handler` for live phone step deltas.

After installing Android Studio / Android SDK, create the Android host if it does not exist:

```powershell
flutter create .
```

Then add this permission **above** the `<application>` tag in:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

Android 10+ requires runtime activity-recognition permission. PulseFit requests it when the user taps **Connect live steps**.

The pedometer sensor reports a cumulative device count since boot. PulseFit intentionally applies only positive deltas received while connected to the current day's local step total. This avoids pretending the sensor can reconstruct steps from before the app was connected. For authoritative historical totals, a future Health Connect adapter can be plugged into the same data layer.

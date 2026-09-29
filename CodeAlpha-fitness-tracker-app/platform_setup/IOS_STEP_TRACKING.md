# iOS live step tracking setup

PulseFit MAX uses the phone pedometer on iOS.

After generating the iOS host with `flutter create .`, add the following to:

`ios/Runner/Info.plist`

```xml
<key>NSMotionUsageDescription</key>
<string>PulseFit uses motion activity to track live steps during your day.</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

Run on a physical iPhone for real motion data. Simulator/web builds cannot provide physical pedometer steps.

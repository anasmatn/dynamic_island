import UIKit
import Flutter
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UIApplication.shared.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)
      if FirebaseApp.app() == nil {
          FirebaseApp.configure()
//            let settings = Firestore.firestore().settings
//            settings.host = "http://127.0.0.1:8020"
//            settings.cacheSettings = MemoryCacheSettings()
//            settings.isSSLEnabled = false
//            Firestore.firestore().settings = settings
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
   override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken
        print("deviceTokenString => \(deviceTokenString)")
    }
}


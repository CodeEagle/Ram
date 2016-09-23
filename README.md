![Rem](./Ram.png)

Ram
---
iOS delicate framework that handle intro guide

Screenshot
---
![RemWork](./Ramwork.jpg)

Usage
---
```swift
  import Ram
// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let work = Ram.Work(...)// watch demo for detail
  Ram.handle(work: [work], skipButtonAtEnd: false) {  print("done") }
// return true
//}
```
install
---
###Carthage
```
github "CodeEagle/Ram"
```

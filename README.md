


<p align="center">
<img src="https://img.shields.io/badge/Swift-4.2-orange.svg" alt="Swift 4.2"/>
<img src="https://img.shields.io/badge/Xcode-10%2B-brightgreen.svg" alt="XCode 10+"/>
<img src="https://img.shields.io/badge/platform-iOS-green.svg" alt="iOS"/>
<img src="https://img.shields.io/badge/iOS-12%2B-brightgreen.svg" alt="iOS 12"/>
<img src="https://img.shields.io/badge/licence-MIT-lightgray.svg" alt="Licence MIT"/>
</p>


#  To Do with priority

### Features
- [x] Understandable action button placement.
- [x] Easy presentation.
- [x] Pure Swift 4.


## Create new task

<div align = "center">
<img src="/gif/1.gif" width="350">
</div>

## Create priority task 

<div align = "center">
<img src="/gif/2.gif" width="350" />
</div>

```swift
private func addToolbar(_ textView: UITextView) {
let keyboardToolBar = UIToolbar()
textView.inputAccessoryView = keyboardToolBar
keyboardToolBar.sizeToFit()
keyboardToolBar.autoresizingMask = .flexibleHeight
keyboardToolBar.barTintColor = UIColor.darkGray


let red = UIBarButtonItem(image: UIImage(named: "flickr"), style: .done, target: self, action: #selector(redButton))
let blue = UIBarButtonItem(image: UIImage(named: "flickr"), style: .done, target: self, action: #selector(blueButton))
let green = UIBarButtonItem(image: UIImage(named: "flickr"), style: .done, target: self, action: #selector(greenButton))

let clear = UIBarButtonItem(image: UIImage(named: "flickr"), style: .done, target: self, action: #selector(clearButton))
red.tintColor = UIColor(red: CGFloat(255) / 255, green: CGFloat(153) / 255, blue: CGFloat(153) / 255, alpha: 1)
blue.tintColor = UIColor(red: CGFloat(153) / 255, green: CGFloat(204) / 255, blue: CGFloat(255) / 255, alpha: 1)
green.tintColor = UIColor(red: CGFloat(153) / 255, green: CGFloat(255) / 255, blue: CGFloat(153) / 255, alpha: 1)
clear.tintColor = UIColor.white

let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
let test = UIBarButtonItem(image: UIImage(named: "ic_circle"), style: .plain, target: self, action: nil)
test.tintColor = UIColor.clear

keyboardToolBar.items = [red, test, blue, test, green, test, clear, flexBarButton]
}
```

## Delete task

<div align = "center">
<img src="/gif/3.gif" width="350" />
</div>

```swift
override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
let todo = self.resultsController.object(at: indexPath)
self.resultsController.managedObjectContext.delete(todo)
do {
try self.resultsController.managedObjectContext.save()
completion(true)
} catch {
print("error")
completion(false)
}
}
action.image = #imageLiteral(resourceName: "trash-2")
action.backgroundColor = .red

return UISwipeActionsConfiguration(actions: [action])
}
```

## Completed task

<div align = "center">
<img src="/gif/4.gif" width="350" />
</div>

```swift
override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
let action = UIContextualAction(style: .destructive, title: "Chech") { (action, view, completion) in
let todo = self.resultsController.object(at: indexPath)
self.resultsController.managedObjectContext.delete(todo)
do {
try self.resultsController.managedObjectContext.save()
completion(true)
} catch {
print("error")
completion(false)
}
}
action.image = #imageLiteral(resourceName: "check")
action.backgroundColor = .green

return UISwipeActionsConfiguration(actions: [action])
}'
```

## CoreData in action

<div align = "center">
<img src="/gif/5.gif" width="350" />
</div>



## Main functionality
* uses `CoreData`
* uses `UITableViewController`, `UITableViewDelegate` & `UITableViewDataSource`
* uses `NSFetchedResultsController`

## Requirements

* Swift 4.2
* iOS 12 or higher

## Authors

* **Alexandr Kustov** -  [ELEV0](https://github.com/ELEV0)

## Communication

* If you **found a bug**, open an issue.
* If you **have a feature request**, open an issue.
* If you **want to contribute**, submit a pull request.

## License

This project is licensed under the MIT License.

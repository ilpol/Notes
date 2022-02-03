import Foundation

class DataModel {
  var lists = [Checklist(name: "Первая тестовая заметка")]
  var isFirstLoad:Bool  = true

  var indexOfSelectedChecklist: Int {
    get {
      return UserDefaults.standard.integer(
        forKey: "ChecklistIndex")
    }
    set {
      UserDefaults.standard.set(
        newValue,
        forKey: "ChecklistIndex")
    }
  }
  
  init() {
    loadChecklists()
    registerDefaults()
  }

  // MARK: - Data Saving
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(
      for: .documentDirectory,
         in: .userDomainMask)
    return paths[0]
  }

  func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Checklists.plist")
  }

  func saveChecklists() {
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(lists)
      try data.write(
        to: dataFilePath(),
        options: Data.WritingOptions.atomic)
    } catch {
      print("Error encoding list array: \(error.localizedDescription)")
    }
  }

  func loadChecklists() {
    let path = dataFilePath()
    
    if let data = try? Data(contentsOf: path) {
      let decoder = PropertyListDecoder()
      do {
        lists = try decoder.decode(
          [Checklist].self,
          from: data)
      } catch {
        print("Error decoding list array: \(error.localizedDescription)")
      }
    }
  }

  // MARK: - Defaults
  func registerDefaults() {
    let dictionary = [
      "ChecklistIndex": -1,
      "FirstTime": true
    ] as [String: Any]
    UserDefaults.standard.register(defaults: dictionary)
  }

  class func nextChecklistItemID() -> Int {
    let userDefaults = UserDefaults.standard
    let itemID = userDefaults.integer(forKey: "ChecklistItemID")
    userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
    return itemID
  }
}

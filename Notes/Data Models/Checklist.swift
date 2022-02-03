import UIKit

class Checklist: NSObject, Codable {
  var name: String
  var iconName: String
  var isBold: Bool
  var isItalic: Bool
  var fontSize: Int
  var fontFamily: String
  
  // не для всех шрифтов есть жирный и курсивный вариант, поэтому
  // если последним был выбран шрифт, то он будет приоритетнее над
  // жирностью и курсивом
  var lastFontModified = false
  

  init(name: String = "", iconName: String = "Birthdays", isBold: Bool = false , isItalic: Bool = false, fontSize: Int = 18, fontFamily: String = "Arial", lastFontModified: Bool = false) {
    self.name = name
    self.iconName = iconName
    self.isBold = isBold
    self.isItalic = isItalic
    self.fontSize = fontSize
    self.fontFamily = fontFamily
    self.lastFontModified = lastFontModified

    super.init()
  }
}

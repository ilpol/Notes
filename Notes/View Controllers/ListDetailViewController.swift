import UIKit

protocol ListDetailViewControllerDelegate: AnyObject {
  func listDetailViewControllerDidCancel(
    _ controller: ListDetailViewController)

  func listDetailViewController(
    _ controller: ListDetailViewController,
    didFinishAdding checklist: Checklist
  )

  func listDetailViewController(
    _ controller: ListDetailViewController,
    didFinishEditing checklist: Checklist
  )
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  @IBOutlet weak var iconImage: UIImageView!
  @IBOutlet weak var switchBold: UISwitch!
  @IBOutlet weak var switchItalic: UISwitch!
  @IBOutlet weak var pickerTextSize: UIPickerView!
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 2
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      if component == 0 {
        return fontSizesToChoose.count
      } else {
        return fontFamiliesToChoose.count
      }
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      if component == 0 {
        return String(fontSizesToChoose[row])
      } else {
          return String(fontFamiliesToChoose[row])
      }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // font size
    if (component == 0) {
      fontSize = fontSizesToChoose[row]
      
      updateUIFields()
    } else if (component == 1) {
      // font family
      fontFamily = fontFamiliesToChoose[row]
      lastFontModified = true
      textField.font = UIFont(name: fontFamily, size: CGFloat(fontSize))
    }
  }
 
  weak var delegate: ListDetailViewControllerDelegate?

  var checklistToEdit: Checklist?
  var iconName = "Folder"
  var fontSize = 16
  var fontFamily = "Times New Roman"
  
  // не для всех шрифтов есть жирный и курсивный вариант, поэтому
  // если последним был выбран шрифт, то он будет приоритетнее над
  // жирностью и курсивом
  var lastFontModified = false
  
  var fontSizesToChoose = [14, 16, 18, 20, 22, 24]
  var fontFamiliesToChoose = ["Copperplate", "Arial", "SnellRoundhand", "Times New Roman", "Zapfino", "Papyrus"]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    pickerTextSize.dataSource = self
    pickerTextSize.delegate = self

    if let checklist = checklistToEdit {
      title = "Добавление заметки"
      textField.text = checklist.name
      doneBarButton.isEnabled = true
      iconName = checklist.iconName
      switchBold.isOn = checklist.isBold
      switchItalic.isOn = checklist.isItalic
      fontSize = checklist.fontSize
      fontFamily = checklist.fontFamily
      
      pickerTextSize.selectRow(fontSizesToChoose.indices.filter {fontSizesToChoose[$0] == checklist.fontSize}[0], inComponent: 0, animated: true)
      
      pickerTextSize.selectRow(fontFamiliesToChoose.indices.filter {fontFamiliesToChoose[$0] == checklist.fontFamily}[0], inComponent: 1, animated: true)
      
      
      if (checklist.isItalic) {
        textField.font = UIFont.italicSystemFont(ofSize: CGFloat(checklist.fontSize))
      } else if (checklist.isBold) {
        textField.font = UIFont.boldSystemFont(ofSize: CGFloat(checklist.fontSize))
      } else {
        textField.font = UIFont(name: checklist.fontFamily, size: CGFloat(checklist.fontSize))
      }
    }
    iconImage.image = UIImage(named: iconName)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }
  
  func updateUIFields() {
    if (switchItalic.isOn) {
      textField.font = UIFont.italicSystemFont(ofSize: CGFloat(fontSize))
    } else if (switchBold.isOn) {
      textField.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
    } else {
      textField.font = UIFont(name: fontFamily, size: CGFloat(fontSize))
    }
  }
  
  @IBAction func boldToggle() {
    textField.font = switchBold.isOn ? UIFont.boldSystemFont(ofSize: CGFloat(fontSize)) : UIFont.systemFont(ofSize: CGFloat(fontSize))
    lastFontModified = false
    updateUIFields()
    
  }
  
  @IBAction func italicToggle() {
    textField.font = switchBold.isOn ? UIFont.boldSystemFont(ofSize: CGFloat(fontSize)) : UIFont.systemFont(ofSize: CGFloat(fontSize))
    
    lastFontModified = false
    updateUIFields()
  }

  // MARK: - Actions
  @IBAction func cancel() {
    delegate?.listDetailViewControllerDidCancel(self)
  }

  @IBAction func done() {
    if let checklist = checklistToEdit {
      checklist.name = textField.text!
      checklist.iconName = iconName
      checklist.isBold = switchBold.isOn
      checklist.isItalic = switchItalic.isOn
      checklist.fontSize = fontSize
      checklist.fontFamily = fontFamily
      checklist.lastFontModified = lastFontModified
      delegate?.listDetailViewController(
        self,
        didFinishEditing: checklist)
    } else {
      let checklist = Checklist(name: textField.text ?? "",
                                iconName: iconName,
                                isBold: switchBold.isOn,
                                isItalic: switchItalic.isOn,
                                fontSize: fontSize,
                                fontFamily: fontFamily,
                                lastFontModified: lastFontModified)
      delegate?.listDetailViewController(
        self,
        didFinishAdding: checklist)
    }
  }
  

  // MARK: - Table View Delegates
  override func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath
  ) -> IndexPath? {
    return indexPath.section == 1 ? indexPath : nil
  }

  // MARK: - Text Field Delegates
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    let oldText = textField.text!
    let stringRange = Range(range, in: oldText)!
    let newText = oldText.replacingCharacters(
      in: stringRange,
      with: string)
    doneBarButton.isEnabled = !newText.isEmpty
    return true
  }

  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    doneBarButton.isEnabled = false
    return true
  }

  // MARK: - Icon Picker View Controller Delegate
  func iconPicker(
    _ picker: IconPickerViewController,
    didPick iconName: String
  ) {
    self.iconName = iconName
    iconImage.image = UIImage(named: iconName)
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Navigation
  override func prepare(
    for segue: UIStoryboardSegue,
    sender: Any?
  ) {
    if segue.identifier == "PickIcon" {
      let controller = segue.destination as! IconPickerViewController
      controller.delegate = self
    }
  }
}

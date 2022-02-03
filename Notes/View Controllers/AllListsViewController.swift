import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
  let cellIdentifier = "NoteCell"
  var dataModel: DataModel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Заметки"
    navigationController?.navigationBar.prefersLargeTitles = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    navigationController?.delegate = self
  }
  
  // MARK: - Navigation
  override func prepare(
    for segue: UIStoryboardSegue,
    sender: Any?
  ) {
    if segue.identifier == "AddChecklist" {
      let controller = segue.destination as! ListDetailViewController
      controller.delegate = self
    }
  }
  
  // MARK: - Table view data source
  override func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return dataModel.lists.count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell: UITableViewCell!
    if let tmp = tableView.dequeueReusableCell(
      withIdentifier: cellIdentifier) {
      cell = tmp
    } else {
      cell = UITableViewCell(
        style: .default,
        reuseIdentifier: cellIdentifier)
    }

    let checklist = dataModel.lists[indexPath.row]
    cell.textLabel!.text = checklist.name

    
    if (checklist.lastFontModified) {
      cell.textLabel!.font = UIFont(name: checklist.fontFamily, size: CGFloat(checklist.fontSize))
    } else if (checklist.isItalic) {
      cell.textLabel!.font = UIFont.italicSystemFont(ofSize: CGFloat(checklist.fontSize))
    } else if (checklist.isBold) {
      cell.textLabel!.font = UIFont.boldSystemFont(ofSize: CGFloat(checklist.fontSize))
    } else {
      cell.textLabel!.font = UIFont(name: checklist.fontFamily, size: CGFloat(checklist.fontSize))
    }
    
    cell.imageView!.image = UIImage(named: checklist.iconName)
    
    return cell
  }

  override func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    
    let controller = storyboard!.instantiateViewController(
      withIdentifier: "ListDetailViewController") as! ListDetailViewController
    controller.delegate = self

    let checklist = dataModel.lists[indexPath.row]
    controller.checklistToEdit = checklist

    navigationController?.pushViewController(
      controller,
      animated: true)
  }

  override func tableView(
    _ tableView: UITableView,
    commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {
    dataModel.lists.remove(at: indexPath.row)

    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }

  // MARK: - List Detail View Controller Delegates
  func listDetailViewControllerDidCancel(
    _ controller: ListDetailViewController
  ) {
    navigationController?.popViewController(animated: true)
  }

  func listDetailViewController(
    _ controller: ListDetailViewController,
    didFinishAdding checklist: Checklist
  ) {
    dataModel.lists.append(checklist)
    tableView.reloadData()
    navigationController?.popViewController(animated: true)
  }

  func listDetailViewController(
    _ controller: ListDetailViewController,
    didFinishEditing checklist: Checklist
  ) {
    tableView.reloadData()
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Navigation Controller Delegates
  func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
    // Была нажата кнопка?
    if viewController === self {
      dataModel.indexOfSelectedChecklist = -1
    }
  }
}

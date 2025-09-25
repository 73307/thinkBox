//
//  BoxItemViewController.swift
//  ThinkBox
//
//  Created by sudhanshu kumar on 07/09/25.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

class BoxItemViewController: UIViewController {
    
    var selectedFolder: BoxFolder?
    var index: IndexPath?
    
    var itemCount : ( (Int) -> Void)?
    
    var items: [BoxItem] = [] {
        didSet {
            tableView.reloadData()
            itemCount?(items.count)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBoxItem()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // ✅ Navigation bar button
        let createButton = UIBarButtonItem(title: "Create File",
                                           style: .plain,
                                           target: self,
                                           action: #selector(createFileTapped))
        navigationItem.rightBarButtonItem = createButton
        navigationItem.title =  ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.deselectRow(at: index ?? IndexPath(), animated: true)
    }
    
    // MARK: - Actions
    @objc func createFileTapped() {
        showCreateFileAlert()
    }
    
    // MARK: - Fetch Items
    private func fetchBoxItem() {
        guard let folder = selectedFolder else { return }
        items = DataManager.shared.fetchItems(for: folder)
    }
    
    // MARK: - Create Item
    private func showCreateFileAlert() {
        let alert = UIAlertController(title: "New Item",
                                      message: "Enter a name for your item",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Item name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            if let itemName = alert.textFields?.first?.text, !itemName.isEmpty,
               let folder = self.selectedFolder {
                
                let item = DataManager.shared.createItem(name: itemName, in: folder)
                self.items.insert(item, at: 0) // ऊपर add करो
            }
        }
        
        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension BoxItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoxItemTableViewCell",
                                                 for: indexPath) as! BoxItemTableViewCell
        let item = items[indexPath.row]
        cell.titleLabel.text = item.name
        cell.dateLabel.text = item.createdAt?.formatted(date: .abbreviated, time: .shortened)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        index = indexPath
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        vc.noteItem = items[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let itemToDelete = items[indexPath.row]
            
            // पहले Core Data से delete करो
            DataManager.shared.deleteItem(itemToDelete)
            items.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .automatic)
            
            print("delete")
        }
    }

}

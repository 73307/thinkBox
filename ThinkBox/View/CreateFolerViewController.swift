//
//  CreateFolerViewController.swift
//  ThinkBox
//
//  Created by sudhanshu kumar on 07/09/25.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import UserNotifications

class CreateFolerViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var createFolderButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var index: IndexPath?
    
    private let label = UILabel()
    private var numberOfItem: Int?
    
    // ✅ Encapsulation → CoreData operations सिर्फ DataManager से होंगे
    var folders: [BoxFolder] = [] {
        didSet {
            tableView.reloadData()
            label.isHidden = !folders.isEmpty
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupEmptyLabel()
        fetchFolders()
        setupNotifications()
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
        if isMovingFromParent {
            index = nil
        } else if let index = index {
            tableView.deselectRow(at: index, animated: true)
        }
    }
    
    deinit {
        print("✅ CreateFolerViewController deallocated")
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupEmptyLabel() {
        label.text = "NO Any folders!"
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        label.isHidden = !folders.isEmpty
    }
    
    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission: \(granted)")
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // MARK: - Data
    
    private func fetchFolders() {
        folders = DataManager.shared.fetchFolders()
    }
    
    /// ✅ Helper function → किसी folder के अंदर कितनी files हैं
    private func printFolderFileCount(folder: BoxFolder) {
        let items = DataManager.shared.fetchItems(for: folder)
        print("Folder: \(folder.name ?? "Unnamed") has \(items.count) files")
    }
    
    // MARK: - Actions
    
    @IBAction func createFolderTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Folder",
                                      message: "Enter a name for your folder",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Folder name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
                let folder = DataManager.shared.createFolder(name: folderName)
                self.folders.append(folder)
                self.printFolderFileCount(folder: folder)
            }
        }
        
        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CreateFolerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! CreateNoteTableViewCell
        let folder = folders[indexPath.row]
        
        cell.titleLabel.text = folder.name
        cell.countDataLabel.text = "\(DataManager.shared.fetchItems(for: folder).count)"
        cell.dateLabel.text = folder.createdAt?.formatted(date: .abbreviated, time: .shortened)
        
        return cell
    }
    
    // ✅ Swipe to Delete with Cascade check
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let folderToDelete = folders[indexPath.row]
            let folderName = folderToDelete.name ?? "Unnamed"
            
            // Delete से पहले count
            let countBefore = DataManager.shared.fetchItems(for: folderToDelete).count
            print("Folder: \(folderName) has \(countBefore) files before delete")
            
            // Delete Folder
            DataManager.shared.deleteFolder(folderToDelete)
            folders.remove(at: indexPath.row)
            
            // Delete के बाद Cascade check
            let countAfter = DataManager.shared.fetchItems(for: folderToDelete).count
            print("After delete check 👇")
            print("Folder: \(folderName) now has \(countAfter) files")
            
            // Inside commit editingStyle after deleting folder
            let content = UNMutableNotificationContent()
            content.title = "Folder Deleted"
            content.body = "\(folderName) was deleted successfully."
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath
        let folder = folders[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "BoxItemViewController") as! BoxItemViewController
        vc.selectedFolder = folder
        
        // ✅ Closure with weak self + avoid capturing indexPath directly
        vc.itemCount = { [weak self] count in
            guard let self = self else { return }
            if let row = self.folders.firstIndex(of: folder),
               let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? CreateNoteTableViewCell {
                cell.countDataLabel.text = "\(count)"
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

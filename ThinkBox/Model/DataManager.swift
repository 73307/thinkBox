//
//  DataManager.swift
//  ThinkBox
//
//  Created by sudhanshu kumar on 09/09/25.
//

import CoreData
import UIKit

// ✅ SINGLETON Class (Encapsulation + Abstraction)
// Encapsulation → सारे CoreData logic को DataManager के अंदर छुपाया गया है
// Abstraction → बाकी controllers को पता ही नहीं CoreData अंदर कैसे काम कर रहा है
final class DataManager {
    // ✅ Singleton pattern → सिर्फ एक instance (Encapsulation)
    static let shared = DataManager()
    private init() {}
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Folder CRUD
    func createFolder(name: String) -> BoxFolder {
        let folder = BoxFolder(context: context)
        folder.name = name
        folder.createdAt = Date()
        saveContext()
        return folder
    }
    
    func fetchFolders() -> [BoxFolder] {
        let request: NSFetchRequest<BoxFolder> = BoxFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func deleteFolder(_ folder: BoxFolder) {
        context.delete(folder)
        saveContext()
    }
    
    // MARK: - Item CRUD
    func createItem(name: String, in folder: BoxFolder) -> BoxItem {
        let item = BoxItem(context: context)
        item.name = name
        item.createdAt = Date()
        item.folder = folder
        saveContext()
        return item
    }
    
    func fetchItems(for folder: BoxFolder) -> [BoxItem] {
        let request: NSFetchRequest<BoxItem> = BoxItem.fetchRequest()
        request.predicate = NSPredicate(format: "folder == %@", folder)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func updateItem(_ item: BoxItem, note: String) {
        item.note = note
        item.createdAt = Date()
        saveContext()
    }
    
    func deleteItem(_ item: BoxItem) {
        context.delete(item)
        saveContext()
    }
    
    // ✅ Encapsulation → saveContext private रखा गया है (बाहर कोई direct access नहीं कर सकता)
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}


extension DataManager {
    func updateNote(for item: BoxItem, text: String) {
        item.note = text
        item.createdAt = Date()
        
        do {
            try context.save()
            print("Note updated successfully ✅")
        } catch {
            print("Error saving note: \(error)")
        }
    }
}

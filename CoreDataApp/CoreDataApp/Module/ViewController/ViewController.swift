//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Gabriel Paschoal on 03/07/23.
//

import UIKit

class ViewController: UIViewController {
    

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var models = [ToDoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "CoreData To Do List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        getAllItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }

    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item",
                                      message: "Enter new item",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Submit",
                                      style: .cancel,
                                      handler: { [weak self] _ in
            
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.isEmpty else { return }
            
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    func getAllItems() {
        do {
            models = try context.fetch(ToDoList.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // error
        }
        
    }
    
    func createItem(name: String) {
        let newItem = ToDoList(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            //error
        }
    }
    
    func deleteItem(item: ToDoList) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            //error
        }
    }
    
    func updateItem(item: ToDoList, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch {
            //error
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { [weak self] _ in
            
        }))
        
        sheet.addAction(UIAlertAction(title: "Edit",
                                      style: .default,
                                      handler: { [weak self] _ in
            
            let alert = UIAlertController(title: "Edit item",
                                          message: "Edit your item",
                                          preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            
            alert.textFields?.first?.text = item.name
            
            alert.addAction(UIAlertAction(title: "Save",
                                          style: .cancel,
                                          handler: { [weak self] _ in
                
                guard let field = alert.textFields?.first,
                      let text = field.text,
                      !text.isEmpty else { return }
                
                self?.updateItem(item: item, newName: text)
            }))
            
            self?.present(alert, animated: true)
           
        } ))
        
        sheet.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive,
                                      handler: { [weak self] _ in
            self?.deleteItem(item: item)
        } ))
        
        present(sheet, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
}

//
//  TableViewController.swift
//  prostoApp
//
//  Created by Admin on 19.10.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // FRC - умеет преобразовывать извлечённые объекты в элементы таблицы — секции и объекты этих секций
    var resultsController: NSFetchedResultsController<ToDo>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // сортируем по дате наши заметки, чтобы новые заметки были наверху
        let sortDescription = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription] // добавили сортировку
        
        // инициализируем
        resultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                       managedObjectContext: context,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)
        resultsController.delegate = self
        do {
            try resultsController.performFetch()
            // performFetch() - для того, чтобы сделать извлечение выборки из базы данных.
        } catch {
            print("error")
        }
        
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = resultsController.sections else { return 0 }
        
        /*
        name — имя секции.
        indexTitle — заголовок секции.
        numbersOfObjects — количество объектов в секции.
        objects — сам массив объектов, находящихся в секции.
        */
        return sections[section].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        let todo = resultsController.object(at: indexPath)
        cell.textOutlet.text = todo.task

        // у нас есть полосчка слева и мы присваиваем ей цвет из нашей БД и кастим его до UIcolor. если у нас нет в бд цвета никакого, то мы красим эту полосочку в белый цвет
        cell.viewOutlet.backgroundColor = todo.tintColor as? UIColor ?? UIColor.white
        
        // если айфон 5 мы в ячейке уменьшаем размер буковок и делаем ее heigh не 65, а 38
        if AppDelegate.isIPhone5() {
            cell.textOutlet.font = UIFont(name: "AvenirNext-Medium", size: 18)
            cell.constraint65.constant = 38
        } else if AppDelegate.isIPhone6() {
            cell.textOutlet.font = UIFont(name: "AvenirNext-Medium", size: 23)
            cell.constraint65.constant = 44
        }
        
        return cell
    }
    
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
    }
    
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
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // когда мы тыкнули на ячейку то performSegue нас перебрасывает на DetailViewController
        performSegue(withIdentifier: "Show", sender: tableView.cellForRow(at: indexPath))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // если у нас нажата кнопка в BarButtonItem то мы передаем ПУТЬ к базе в переменную в том viewController для быстрого доступа
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? DetailViewController {
            vc.managedContext = resultsController.managedObjectContext
            // мы меняем Bool перменную в том контроллере (там найдешь ее и там будет описание что она значит)
            vc.boolText = false
        }
        // если мы нажали на ячейку то мы передаем ПУТЬ к базе в переменную в том viewController для быстрого доступа
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? DetailViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                // извлекаем из базы данные по byltrce и присваиваем эти данные в константу todo
                let todo = resultsController.object(at: indexPath)
                // передаем эти выбранные данные
                vc.data = todo
                // мы тыкнули на ячейку и если у нее была полосочка левая то мы записываем данные о цвете в свойство того контроллера, а если не было данных, то мы записываем туда прозрачный цвет
                vc.colorNotes = todo.tintColor as? UIColor ?? .clear
            }
        }
    
    }
 
    
    @IBAction func addTaskAction(_ sender: Any) {
    }
    

}


extension TableViewController: NSFetchedResultsControllerDelegate {

    // controllerWillChangeContent — метод оповещает делегат о начале изменения объектов по запросу, с которым работает наш контроллер. Вызовем в нём метод UITableView таблицы — beginUpdates.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    // controllerDidChangeContent — метод оповещает делегат о конце изменений. В нём вызываем метод таблицы endUpdates.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // didChangeObject — данный метод работает по аналогии с предыдущим, только вместо аргумента, описывающего секцию sectionInfo, приходит аргумент anObject, который является модифицируемым объектом, а также вместо sectionIndex — старый индекс, который был у объекта до изменений `indexPath и новый newIndexPath, который он получил после изменений. Используя методы UITableView, обработаем добавление, удаление, перемещение, и обновление объектов с использованием анимаций.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            // добавляем новую заметку в таблицу
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            // удаляем из TableView нашу ячейку по идексу
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            // берем идекс выбранной ячейки и ее данные
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
                // ищем в базе данных по индексу новые данные
                let todo = resultsController.object(at: indexPath)
                // мы нашли данные которые мы обновили и теперь мы их отображаем
                cell.textOutlet.text = todo.task
                cell.viewOutlet.backgroundColor = todo.tintColor as? UIColor
                tableView.reloadData()
            }
        default:
            break
        }
    }



    /*
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
     
     switch type {
     case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
     case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
     case .update: tableView.reloadRows(at: [indexPath!], with: .automatic)
     case .move: tableView.moveRow(at: indexPath!, to: newIndexPath!)
     }
     }
 */
}

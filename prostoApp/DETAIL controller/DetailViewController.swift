//
//  DetailViewController.swift
//  prostoApp
//
//  Created by Admin on 19.10.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    public var data: ToDo?
    public var managedContext: NSManagedObjectContext!
    
    
    @IBOutlet weak var leftViewLine: UIView!
    @IBOutlet weak var textViewOutlet: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        
        // добавляем нашим кнопочкам красивую тень ( смотри Extension )
        doneButton.dropShadow()
        cancelButton.dropShadow()
    }
  
    // тут мы храним цвет нашей полосочки
    public var colorNotes: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textViewOutlet.delegate = self
        
        // наблюдатели которые нам помогают понять когда клава открывается и скрывается
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBottomConstraint(param:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBottomConstraint(param:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        if let data = data {
            // если у нас уже есть заметк то в textView передаем ее
            textViewOutlet.text = data.task
            textViewOutlet.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            // красим полосчку по нашему нужному цвету и даем ей тень для красоты
            leftViewLine.backgroundColor = colorNotes
            leftViewLine.layer.shadowOffset = CGSize(width: -1, height: 1)
            leftViewLine.layer.shadowRadius = 1
            leftViewLine.layer.shadowOpacity = 0.3
        }
        
        swipes() // это у нас жест сверху вниз
        addToolbar(textViewOutlet) // добавляем нашему TextView Toolbar
        
        // для айфона 5 мы даем маленький размер шрифта
        if AppDelegate.isIPhone5() {
            textViewOutlet.font = UIFont(name: "AvenirNext-Bold", size: 19)
        }
        
    }
    // по свайпу сверху вниз откатываемся к TableView
    private func swipes() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    @objc private func swipe(gester: UISwipeGestureRecognizer) {
        dismissAndResign()
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        // если чурка не ввел ничего то не даем ему сохранить заметку т.к. там наш "placeholder"
        if textViewOutlet.text == "Say something..." {
            let ac = UIAlertController(title: "enter your note", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            ac.addAction(ok)
            present(ac, animated: true)
            return
        }
        
        // если заметка пустая то кнопка не сработает, а если не пустая то мы пройдем эту проверку
        guard let title = textViewOutlet.text, title.isEmpty == false else { return }
        
        
        // если у нас есть уже старая заметка то мы берем наш title который мы проверили на nil выше строкой! и записываем в базу данных и берем colorNotes (смотри Extension) чтобы понять откуда он у нас берется
        if let todo = data {
            todo.task = title
            todo.tintColor = colorNotes
        } else {
            // если данных нет то мы стучимся к нашей БД и записываем в нее новые значения
            let data = ToDo(context: managedContext)
            data.task = title
            data.date = Date()
            data.tintColor = colorNotes
        }
        
        do {
            // сохраняем данные и ( смотри метод dismissAndResign() )
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("error")
        }
        
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismissAndResign()
    }
    
    // метод который откатывает нас на TableView и скрывает клавиатуру
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textViewOutlet.resignFirstResponder()
    }
    
    // мы меняем высоту нижнего constraint который у нас держит кнопки (Cancel и Done), когда клавиатура разварачивается
    @objc func updateBottomConstraint(param: Notification) {
        
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let getKeyboardFrame = param.userInfo![key] as? NSValue else { return }
        
        let keyboardHeigh = getKeyboardFrame.cgRectValue.height + 15
        
        
        if param.name == UIResponder.keyboardWillShowNotification {
            bottomConstraint.constant = keyboardHeigh
        } else {
            bottomConstraint.constant = 10
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    // мы разрешаем клавиатуре свернуться когда тапаем в не TextView
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textViewOutlet.resignFirstResponder()
    }


    // наше свойство которое мы меняем в prepare в TableView (оно нужно для того чтобы понять новая заметка у нас или мы редактируем старую)
    public var boolText = true
}

// Отслеживаем когда пользователь нажал на TextView
extension DetailViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        // меняем цвет текста в TextView после того как на него тапнули
        textView.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        if boolText == false {
            // удаляем наш "placeholder"
            textViewOutlet.text.removeAll()
            
            boolText = true
            // окрашиваем кнопку cancel в красный цвет с задержкой 0,7 чтобы красивее было
            UIView.animate(withDuration: 0.7) {
                self.cancelButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                self.cancelButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                self.view.layoutIfNeeded()
            }
        } else {
            // если у нас редактирование заметки (а не новая заметка) то мы проваливаемся в else когда тапают на TextView и также красим кнопку
            UIView.animate(withDuration: 0.7) {
                self.cancelButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                self.cancelButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                self.view.layoutIfNeeded()
            }
        }
    }
    

}

// расширение в котором добавление нашему TextView TollBar
extension DetailViewController {
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
    
    @objc private func redButton() {
        colorNotes = UIColor(red: CGFloat(255) / 255, green: CGFloat(153) / 255, blue: CGFloat(153) / 255, alpha: 1)
        leftViewLine.backgroundColor = colorNotes
    }
    
    @objc private func blueButton() {
        colorNotes = UIColor(red: CGFloat(153) / 255, green: CGFloat(204) / 255, blue: CGFloat(255) / 255, alpha: 1)
        leftViewLine.backgroundColor = colorNotes
    }
    
    @objc private func greenButton() {
        colorNotes = UIColor(red: CGFloat(153) / 255, green: CGFloat(255) / 255, blue: CGFloat(153) / 255, alpha: 1)
        leftViewLine.backgroundColor = colorNotes
    }
    
    @objc private func clearButton() {
        colorNotes = UIColor.clear
        leftViewLine.backgroundColor = colorNotes
    }
}



// Расширение для кнопок Cancel и Done. Добавлет тень кнопкап
extension UIView {
    func dropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
    }
}

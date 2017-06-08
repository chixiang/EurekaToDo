/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//import UIKit
//
//class EditToDoItemViewController: UIViewController {
import Eureka
import ImageRow
import UIKit

class EditToDoItemViewController: FormViewController {
    
    var viewModel: ViewModel!
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy, h:mm a"
        return formatter
    }()
    
    let categorySectionTag: String = "add category section"
    let categoryRowTag: String = "add category row"
    
    lazy var footerTapped: EditToDoTableFooter.TappedClosure = { [weak self] footer in //1
        
        //2
        guard let form = self?.form,
            let tag = self?.categorySectionTag,
            let section = form.sectionBy(tag: tag) else {
                return
        }
        
        //3
        footer.removeFromSuperview()
        
        //4
        section.hidden = false
        section.evaluateHidden()
        
        //5
        if let rowTag = self?.categoryRowTag,
            let row = form.rowBy(tag: rowTag) as? ToDoCategoryRow {
            //6
            let category = self?.viewModel.categoryOptions[0]
            self?.viewModel.category = category
            row.value = category
            row.cell.update()
        }
    }
    /*******************
     1.To avoid retain cycles, pass [weak self] to the closure.
     2.Safely unwrap references to the view controller and its form and categorySectionTag properties. You obtain a reference to the Section instance you defined with the categorySectionTag.
     3.When the footer is tapped, remove it from the view since the user shouldn't be allowed to tap it again.
     4.Unhide the section by setting hidden to false then calling evaluateHidden(). evaluateHidden() updates the form based on the hidden flag.
     5.Safely unwrap the reference to the ToDoCategoryRow we added to the form.
     6.Ensure the view model's category property and the cell's row value property are defaulted to the first item in the array of options. Call the cell's update() method so its label is refreshed to show the row's value.
     *******************/
    
    // MARK: - Life Cycle
    convenience init(viewModel: ViewModel) {
        self.init()
        self.viewModel = viewModel
        initialize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form
            +++ Section()	//2
            <<< TextRow() { // 3
                $0.title = "Description" //4
                $0.placeholder = "e.g. Pick up my laundry"
                $0.value = viewModel.title //5
                $0.onChange { [unowned self] row in //6
                    self.viewModel.title = row.value
                }
                /*******************
                 1.Acts on the form object provided by FormViewControler.
                 2.Instantiates and adds a Section to the form using Eureka's +++ operator.
                 3.Adds a TextRow to the section. As you'd expect, this is a row that will contain some text. The initializer accepts a closure used to customize the row's appearance and events.
                 4.Adds a title and placeholder text to the textfield. The title is a left-justified label and the placeholder appears on the right until a value is added.
                 5.This sets the initial value of the row to show the to-do item's title.
                 6.Eureka's Row superclass comes with a host of callbacks that correspond to various interaction and view lifecycle events. The onChange(_ :) closure is triggered when the row's value property changes. When a change happens, this updates the viewModel's title property to the row's current value.
                 **********************/
                $0.add(rule: RuleRequired()) //1
                $0.validationOptions = .validatesOnChange //2
                $0.cellUpdate { (cell, row) in //3
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
                /*******************
                 1.Initialize and add a RuleRequired to the TextRow object. This is one of the validation rules provided with Eureka to handle required input in a form. It indicates that a value must be provided in the field to pass validation.
                 2.Set the row's validationOptions to .validatesOnChange, meaning the validation rule will be evaluated as the row's value changes.
                 3.If the value of the row is not valid, set the row's title color to red to red to alert the user.
                 **********************/
            }
            
            
            +++ Section()
            <<< DateTimeRow() {
                $0.dateFormatter = type(of: self).dateFormatter //1
                $0.title = "Due date" //2
                $0.value = viewModel.dueDate //3
                $0.minimumDate = Date() //4
                $0.onChange { [unowned self] row in //5
                    if let date = row.value {
                        self.viewModel.dueDate = date
                    }
                }
            }
            /********************
             1.To format the presentation of the date, set the row's dateFormatter to the static dateFormatter provided in the starter project.
             2.Most Eureka Row subclasses allow you to set their title property to make the purpose of the row clear to the user.
             3.When the row is initially configured, set its value to the view model's due date.
             4.Use today's date as the minimum date that can be accepted as user input.
             5.Set the newly-selected date to the view model when onChange is triggered.
             **********************/
            
            <<< PushRow<String>() { //1
                $0.title = "Repeats" //2
                $0.value = viewModel.repeatFrequency //3
                $0.options = viewModel.repeatOptions //4
                $0.onChange { [unowned self] row in //5
                    if let value = row.value {
                        self.viewModel.repeatFrequency = value
                    }
                }
            }
            /**********************
             1.Add a new PushRow to the most-recently instantiated section. PushRow is a generic class, so you need to specify that you're using it with type String in angle brackets.
             2.Again, to make the purpose of this selector clear to the user, set its title to "Repeats".
             3.Initialize the row's value with the view model's repeatFrequency property to show the current selection.
             4.As you might have guessed, the options of a PushRow represent the list of possible values the user can select. Set this to viewModel.repeatOptions, an array of strings that have been declared in the starter project. If you Command+Click repeatOptions, you'll see the repeat options are: never, daily, weekly, monthly and annually.
             5.Whenever the row's value changes, update viewModel with the newly-selected value.
             ********************/
            
            +++ Section()
            <<< SegmentedRow<String>() {
                $0.title = "Priority"
                $0.value = viewModel.priority
                $0.options = viewModel.priorityOptions
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.viewModel.priority = value
                    }
                }
            }
            
            <<< AlertRow<String>() {
                $0.title = "Reminder"
                $0.selectorTitle = "Remind me"
                $0.value = viewModel.reminder
                $0.options = viewModel.reminderOptions
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.viewModel.reminder = value
                    }
                }
            }
            
            +++ Section("Picture Attachment")
            <<< ImageRow() {
                $0.title = "Attachment"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera] //1
                $0.value = viewModel.image //2
                $0.clearAction = .yes(style: .destructive) //3
                $0.onChange { [unowned self] row in //4
                    self.viewModel.image = row.value
                }
            }
            /********************
             1.In the initialization closure, allow the user to select images from their Photo Library, Saved Photos album, or camera if available.
             2.If an image is already attached to this to-do item, use it to initialize the row's value.
             3.Present the "Clear Photo" option with the "destructive" style to indicate that image data may be permanently destroyed when a photo attachment is cleared (when using the camera roll, for example).
             4.As with the previous examples, update the viewModel.image when a new value is set.
             *******************/
            
            //1
            +++ Section("Category") {
                $0.tag = categorySectionTag
                //2
                $0.hidden = (self.viewModel.category != nil) ? false : true
            }
            //3
            <<< ToDoCategoryRow() { [unowned self] row in
                row.tag = self.categoryRowTag
                //4
                row.value = self.viewModel.category
                //5
                row.options = self.viewModel.categoryOptions
                //6
                row.onChange { [unowned self] row in
                    self.viewModel.category = row.value
                }
        }
        /**********************
         1.Add a section to the form, assigning the categorySectionTag constant.
         2.Set the section's hidden property to true if the category property on the view model is nil. The plain nil-coalescing operator cannot be used here as the hidden property requires a Boolean literal value instead.
         3.Add an instance of ToDoCategoryRow to the section tagged with categoryRowTag.
         4.Set the row's value to viewModel.category.
         5.Because this row inherits from PushRow, you must set the row's options property to the options you want displayed.
         6.As you've seen in prior examples, use the row's onChange(_:) callback to update the view model's category property whenever the row's value changes.
         *********************/
        
        //1
        let footer = EditToDoTableFooter(frame: .zero)
        //2
        footer.action = footerTapped
        //3
        if let tableView = tableView, viewModel.category == nil {
            tableView.tableFooterView = footer
            tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50.0)
        }
        /******************
         1.Declare an instance of EditToDoTableFooter. You pass a zero frame, because the size will be handled by constraints tied to the cell layout.
         2.footer.action is triggered when the footer button is pressed, and this ensures it fires the code you defined in the footerTapped closure.
         3.If the view model's category is nil, set the table view's tableFooterView property to our newly-instantiated footer. Next, set the footer's frame to the desired dimensions.
         *******************/
    }
    
    private func initialize() {
//        let deleteButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: .deleteButtonPressed)
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: .deleteButtonPressed)
        navigationItem.leftBarButtonItem = deleteButton
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: .saveButtonPressed)
        navigationItem.rightBarButtonItem = saveButton
        
        view.backgroundColor = .white
    }
    
    // MARK: - Actions
    @objc fileprivate func saveButtonPressed(_ sender: UIBarButtonItem) {
        if form.validate().isEmpty {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        // Uncomment these lines
        //1
        let alert = UIAlertController(title: "Delete this item?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            //2
            self?.viewModel.delete()
            _ = self?.navigationController?.popViewController(animated: true)
        }
        //3
        alert.addAction(delete)
        alert.addAction(cancel)
        
        navigationController?.present(alert, animated: true, completion: nil)
        
        /*********************
         1.Create a UIAlertController with a title, cancel and delete actions.
         2.In the completion handler of the delete action, tell the view model to delete the to-do item currently being edited. Then pop the current view controller off the navigation stack.
         3.Add the cancel and delete actions to the alert controller, and present the alert controller on the navigation stack.
         **********************/
        
        // Delete this line
        //_ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - Selectors
extension Selector {
    fileprivate static let saveButtonPressed = #selector(EditToDoItemViewController.saveButtonPressed(_:))
    fileprivate static let deleteButtonPressed = #selector(EditToDoItemViewController.deleteButtonPressed(_:))
}

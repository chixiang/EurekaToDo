//
//  ToDoCategoryRow.swift
//  EurekaToDo
//
//  Created by 池翔 on 2017/6/8.
//  Copyright © 2017年 Ray Wenderlich. All rights reserved.
//
//1.You'll be displaying string values in this cell, so you provide String as the optional type.
//2.Instantiate the UILabel that will be added to the cell.
//3.setup() is called when the cell is initialized. You'll use it to lay out the cell - starting with setting the height (provided by a closure), title and selectionStyle.
//4.Add the categoryLabel and the constraints necessary to center it within the cell's contentView.
//5.Override the cell's update() method, which is called every time the cell is reloaded. This is where you tell the cell how to present the Row's value. Note that you're not calling the super implementation here, because you don't want to configure the textLabel included with the base class.

import Eureka

//1
class ToDoCategoryCell: PushSelectorCell<String> {
    
    //2
    lazy var categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        return lbl
    }()
    
    //3
    override func setup() {
        height = { 60 }
        row.title = nil
        super.setup()
        selectionStyle = .none
        
        //4
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        let margin: CGFloat = 10.0
        categoryLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -(margin * 2)).isActive = true
        categoryLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -(margin * 2)).isActive = true
        categoryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    //5
    override func update() {
        row.title = nil
        accessoryType = .disclosureIndicator
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .none : .default
        categoryLabel.text = row.value
    }
}

final class ToDoCategoryRow: _PushRow<ToDoCategoryCell>, RowType { }

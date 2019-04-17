//
//  PowerRadioButtonGroup.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/26.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation

@objc protocol PowerRadioButtonGroupDelegate {
    @objc func didSelectButton(selectedButton: UIButton?)
}

class PowerRadioButtonGroup: NSObject {

    var buttonsArray = [PowerRadioButton]()
    
    var shouldLetDeSelect = false
    
    weak var delegate : PowerRadioButtonGroupDelegate? = nil
    
    init(buttons: PowerRadioButton..., defaultIndex: Int) {
        super.init()
        buttons[defaultIndex].isSelected = true
        for aButton in buttons {
            aButton.addTarget(self, action: #selector(press(_:)), for: .touchUpInside)
        }
        self.buttonsArray = buttons
    }
    
    // 添加一个button到ButtonGroup
    func addButton(_ aButton: PowerRadioButton) {
        buttonsArray.append(aButton)
        aButton.addTarget(self, action: #selector(press(_:)), for: .touchUpInside)
    }
    
    // 从ButtonGroup中移除一个Button
    func removeButton(_ aButton: PowerRadioButton) {
        var iteratingButton: PowerRadioButton? = nil
        if buttonsArray.contains(aButton) {
            iteratingButton = aButton
        }
        if iteratingButton != nil {
            buttonsArray.remove(at: buttonsArray.index(of: iteratingButton!)!)
            iteratingButton!.removeTarget(self, action: #selector(press(_:)), for: .touchUpInside)
            iteratingButton!.isSelected = false
        }
    }
    
    // 向ButtonGroup添加一组Button
    func setButtonsArray(_ aButtonArray: [PowerRadioButton]) {
        for aButton in aButtonArray {
            aButton.addTarget(self, action: #selector(press(_:)), for: .touchUpInside)
        }
        buttonsArray = aButtonArray
    }
    
    @objc func press(_ sender: PowerRadioButton) {
        var currentSelectedButton: UIButton? = nil
        if sender.isSelected {
            if shouldLetDeSelect {
                sender.isSelected = false
                currentSelectedButton = nil
            }
        } else {
            for aButton in buttonsArray {
                aButton.isSelected = false
            }
            sender.isSelected = true
            currentSelectedButton = sender
        }
        delegate?.didSelectButton(selectedButton: currentSelectedButton)
    }
    
    // 获取当前选中的Button
    func selectedButton() -> UIButton? {
        guard let index = buttonsArray.index(where: { button in button.isSelected }) else {
            return nil
        }
        
        return buttonsArray[index]
    }
    
    func setSelectButton(index: Int) {
        if !buttonsArray[index].isSelected {
            press(buttonsArray[index])
            delegate?.didSelectButton(selectedButton: buttonsArray[index])
        }
    }
}

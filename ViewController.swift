//
//  ViewController.swift
//  Calculator
//
//  Created by EIE3109 on 17/10/2017.
//  Copyright © 2017 EIE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var userIsInTheMiddleOfTyping = false
    
    
    @IBOutlet weak var display: UILabel!
    
    @IBAction func digitPressed(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let originalText = display.text!
        if userIsInTheMiddleOfTyping{
            display.text = originalText + digit
        }
        else{
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        print("\(digit) pressed")
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func operationPressed(_ sender: UIButton) {
//        userIsInTheMiddleOfTyping = false
//        if let symbol = sender.currentTitle {
//            switch symbol {
//                case "π": displayValue = Double.pi
//                case "e": displayValue = M_E
//            default:
//                break
//            }
//        }
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        if let result = brain.result {
            if result.truncatingRemainder(dividingBy: 1) < pow(10,-7) && result.truncatingRemainder(dividingBy: 1) > -pow(10,-7) {
                display.text = String(Int(result))
            }
            else {
                displayValue = result
            }
        }
    }
  
}


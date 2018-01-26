//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by EIE3109 on 19/10/2017.
//  Copyright © 2017 EIE. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumlator: Double?
    private var lastOperator: String?
    private var lastOperand: Double?  // feature that pressing "=" button consecutively will execute the last command with last operand
    private var opQueue: OpQueue? = OpQueue()
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "*": Operation.binaryOperation({$0 * $1}),
        "/": Operation.binaryOperation({$0 / $1}),
        "=": Operation.equals,
        ".": Operation.binaryOperation({$0 + $1/10}),
        "sin": Operation.unaryOperation({sin(($0 * Double.pi)/180)}),
        "cos": Operation.unaryOperation({cos(($0 * Double.pi)/180)}),
        "tan": Operation.unaryOperation({tan(($0 * Double.pi)/180)}),
        "√": Operation.unaryOperation({pow($0,0.5)}),
        "AC": Operation.ac, //clear the screen
    ]
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double)->Double)
        case equals
        case ac
    }
    
    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumlator = value
                
            case .unaryOperation(let function):
                if accumlator != nil {
                    unaryOperation = UnaryOperation(function:function, operand:accumlator!)
                    accumlator = unaryOperation!.perform()
                    lastOperand = accumlator
                    unaryOperation = nil
                }
                else {
                    unaryOperation = UnaryOperation(function:function, operand:lastOperand!)
                    accumlator = nil
                }
                lastOperator = symbol
                
                
            case .binaryOperation(let function):
                if accumlator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function:function, firstOperand:accumlator!, operatorName: symbol)
                    opQueue?.enqueue(pendingBinaryOperation!)
                    accumlator = nil
                }
                else {
                    accumlator = opQueue?.peek(0).perform(with: lastOperand!)
                    opQueue?.dequeue(0)
                }
                lastOperator = symbol
                
            case .equals:
                performPendingOperation()
                
            case .ac:
                self.result = 0
                accumlator = 0
                lastOperand = 0
                lastOperator = nil
                unaryOperation = nil
                pendingBinaryOperation = nil
            }
            
        }
        
    }
    
    mutating func setOperand(_ operand: Double) {
        accumlator = operand
    }
    
    var result: Double? {
        get {
            return accumlator
        }
        set {
            
        }
    }
    
    private var unaryOperation: UnaryOperation?
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct UnaryOperation {
        let function: (Double) -> Double
        let operand: Double
        
        func perform() -> Double {
            return function(operand)
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        var firstOperand: Double
        let operatorName: String
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private mutating func performPendingOperation() {
        
        if unaryOperation != nil && accumlator == nil {
            accumlator = unaryOperation!.perform()
            lastOperand = accumlator
            unaryOperation = nil
        }
            
        else if opQueue?.items.count != 0 && accumlator != nil {
            lastOperand = accumlator
            var i: Int = 0
            var temp: Double
            var current = opQueue?.peek(0)
            if (opQueue!.items.count == 1) {
                accumlator = opQueue?.peek(0).perform(with: accumlator!)
                opQueue!.dequeue(0)
            }
            else {
                while (i < opQueue!.items.count) {
                    current = opQueue?.peek(i)
                    if current!.operatorName == "*" || current!.operatorName == "/" {
                        if (i == opQueue!.items.count - 1) {
                            accumlator = opQueue?.peek(i).perform(with: accumlator!)
                        }
                        else {
                            temp = current!.perform(with: opQueue!.peek(i+1).firstOperand)
                            opQueue!.items[i+1].firstOperand = temp
                        }
                        opQueue!.dequeue(i)
                    }
                    i = i+1
                }
            }
            i = 0
            if (opQueue!.items.count == 1) {
                accumlator = opQueue?.peek(0).perform(with: accumlator!)
                opQueue!.dequeue(0)
            }
            else if (opQueue!.items.count != 0) {
                while (i < opQueue!.items.count - 1) {
                    current = opQueue!.peek(i)
                    temp = current!.perform(with: opQueue!.peek(i+1).firstOperand)
                    opQueue!.items[i+1].firstOperand = temp
                    opQueue!.dequeue(i)
                }
                accumlator = opQueue?.peek(0).perform(with: accumlator!)
                opQueue!.dequeue(0)
            }
            //            accumlator = pendingBinaryOperation!.perform(with: accumlator!)
            //            pendingBinaryOperation = nil
        }
            
            
            //when the user press "=" button consecutively
        else if unaryOperation == nil && lastOperator != nil{
            performOperation(lastOperator!)
            if (lastOperator == "+" || lastOperator == "-" || lastOperator == "*" || lastOperator == "/" ) {
                performOperation(lastOperator!)
            }
        }
    }
    
    private class OpQueue {
        var items = [PendingBinaryOperation]()
        func isEmpty() -> Bool {
            if items.count==0 {
                return true;
            }
            return false;
        }
        func enqueue(_ item: PendingBinaryOperation) {
            items.append(item)
        }
        func dequeue(_ number: Int) {
            items.remove(at:number)
        }
        func peek(_ number: Int) -> PendingBinaryOperation {
            return items[number]
        }
    }
    
    
}






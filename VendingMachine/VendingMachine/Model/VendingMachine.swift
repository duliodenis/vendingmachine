//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Dulio Denis on 4/29/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import Foundation

// MARK: - Vending Machine Protocol
// Protocol defining requirements for what a Vending Machine could be
// A concrete vending machine would implement these to vend different
// items

protocol VendingMachineType {
    // the selection of items to vend
    var selection: [VendingSelection] { get }
    // a selection inventory that the machine contains that conform to the ItemType protocol
    var inventory: [VendingSelection: ItemType] { get set }
    // the machine needs to keep track of how much money the user can use to buy things
    var amountDeposited: Double { get set }
    
    // machine needs to set itself up from a fully constructed inventory source
    init(inventory: [VendingSelection: ItemType])
    // when vending there are many error conditions where things can go wrong 
    // so we'll need to create a throwing function
    func vend(selection: VendingSelection, quantity: Double) throws
    // add cash to the vending machine
    func deposit()
}

// MARK: - Item Type Protocol
// Protocol representing what a Vending Item could be

protocol ItemType {
    // price of the item which can not change
    var price: Double { get }
    // quantity of items which can change
    var quantity: Double { get set }
}


// MARK: - Vending Selection Enum
// The enum encapsulating the various selection options in a vending machine

enum VendingSelection {
    case Soda
    case DietSoda
    case Chips
    case Cookie
    case Sandwich
    case Wrap
    case CandyBar
    case PopTart
    case Water
    case FruitJuice
    case SportsDrink
    case Gum
}
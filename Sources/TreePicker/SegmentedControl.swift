//
//  File.swift
//  
//
//  Created by Alessio Moiso on 27.01.24.
//

import AppKit
import SwiftUI

struct SegmentedControl<Item: TreePickerItem>: NSViewRepresentable {
	typealias NSViewType = NSSegmentedControl
	
	@Binding var items: [Item]
	@Binding var selectedItem: Item.ID?
	
	let createNewItemHandler: ((Item.ID) -> ())?
	
	fileprivate let segmentedControl = NSSegmentedControl()
	
	func makeNSView(context: Context) -> NSViewType {
		let observableCell = SmartSegmentedCell()
		observableCell.changeAction = context.coordinator.didChangeSelectedSegment(_:)
		segmentedControl.cell = observableCell
		
		return segmentedControl
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context) {
		nsView.segmentCount = items.count
		
		items.enumerated()
			.forEach { (index, item) in
				nsView.setLabel(item.label, forSegment: index)
				nsView.setImage(item.image, forSegment: index)
				
				let menu = makeMenu(for: item, context: context)
				
				nsView.setShowsMenuIndicator(menu != nil, forSegment: index)
				nsView.setMenu(menu, forSegment: index)
				
				if
					let selectedItem,
					selectedItem == item.id ||
						item.children.map({ $0.id as! Item.ID }).contains(selectedItem) ||
						item.children.flatMap({ $0.children }).map({ $0.id as! Item.ID }).contains(selectedItem)
				{
					nsView.selectedSegment = index
				}
			}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}
	
	private func makeMenu(for item: any TreePickerItem, context: Context) -> NSMenu? {
		let menu = NSMenu()
		
		item.children
			.forEach { item in
				let menuItem = NSMenuItem(title: item.label, action: nil, keyEquivalent: "")
				if let image = item.image {
					menuItem.image = image
				}
				menuItem.target = context.coordinator
				menuItem.representedObject = item.id
				
				if !item.children.isEmpty || item.supportsAdding {
					menuItem.submenu = makeMenu(for: item, context: context)
				} else {
					menuItem.action = #selector(Coordinator.didSelectMenuItem(_:))
				}
				
				if
					let selectedItem,
					selectedItem == item.id as! Item.ID ||
						item.children.map({ $0.id as! Item.ID }).contains(selectedItem) ||
						item.children.flatMap({ $0.children }).map({ $0.id as! Item.ID }).contains(selectedItem)
				{
					menuItem.state = .on
				}

				menu.addItem(menuItem)
			}
		
		if
			item.supportsAdding,
			let addItemLabel = item.addItemLabel
		{
			let divider = NSMenuItem.separator()
			
			let menuItem = NSMenuItem(title: addItemLabel, action: #selector(Coordinator.didSelectCreateItem(_:)), keyEquivalent: "")
			menuItem.target = context.coordinator
			menuItem.representedObject = item.id
			
			menu.addItem(divider)
			menu.addItem(menuItem)
		}
		
		guard !menu.items.isEmpty else { return nil }
		
		return menu
	}
}

extension SegmentedControl {
	final class Coordinator {
		var parent: SegmentedControl
		
		init(parent: SegmentedControl) {
			self.parent = parent
		}
		
		func didChangeSelectedSegment(_ index: Int) {
			guard
				parent.segmentedControl.menu(forSegment: index) == nil
			else
			{
				return
			}
			
			parent.selectedItem = parent.items[index].id
		}
		
		@objc func didSelectMenuItem(_ menuItem: NSMenuItem) {
			guard
				let representedObject = menuItem.representedObject as? Item.ID
			else { return }
			
			parent.selectedItem = representedObject
		}
		
		@objc func didSelectCreateItem(_ menuItem: NSMenuItem) {
			guard
				let representedObject = menuItem.representedObject as? Item.ID
			else { return }
			
			parent.createNewItemHandler?(representedObject)
		}
	}
}

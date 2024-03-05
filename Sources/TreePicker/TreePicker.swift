#if canImport(AppKit)
import SwiftUI

/// A view that displays a segmented control with menus to support
/// hierarchal navigation of items.
///
/// # Overview
///	You can use a tree picker to display a list of items that can be
///	navigated hierarchically. The tree picker displays a segmented control
///	with menus for items that define children.
///
///	To represent the selection, all involved items are highlighted: the parent
///	item in the segmented control, plus all the parent items in the menus.
///	The appearance of the selected item in the segmented control is controlled
///	by the system, just like all menu items.
///
///	You can also define a handler that is called when the user selects the
///	"Create New" menu for items that allow this.
///
///	# Content
/// To populate the picker, you provide a binding to an array of items
/// that conform to ``TreePickerItem``.
///
/// A simple example of a struct conforming to the protocol looks like this:
///
/// ```swift
/// struct Item: TreePickerItem {
/// 	let id: String
/// 	let label: String
/// 	let children: [Item]
///
///		// Optional, defaults to nil
///		let image: NSImage?
/// 	// Optional, defaults to false
/// 	let supportsAdding: Bool
/// 	// Optional, defaults to nil
/// 	let addItemLabel: String?
/// }
/// ```
///
/// Items define the hierarchy using their `children` property.
/// 
/// The picker will display a segmented control with the top-level items:
/// for each item that has a non-empty array of `children`, a menu will
/// be added with the list of children; each child that has a non-empty array of
/// `children` will create a submenu, and so on.
///
/// # Selection
/// Changing selection in the picker or in one of the menus updates the `selectedItem` picker.
/// The same can be achieved programmatically by updating the value of the same binding.
///
/// Setting the selection to `nil` will cause the picker to deselect all items.
///
/// # Custom Views
/// `NSMenuItem`s have a `view` property that allows you to completely replace the
/// content of the menu item with a custom view. You can provide a closure that returns any SwiftUI
/// view to take advantage of this feature.
///
/// To do that, use the ``view(for:)`` method.
///
/// - warning: Providing custom views in menu items is not supported for top-level elements. The
/// closure will only be invoked for children.
/// - note: This functionality is not well implemented in the AppKit: while you can provide a custom view,
/// you will immediately lose access to all the behaviors that are normally implemented by menus, such as
/// highlighting, flashing on click, and more. You can provide a custom wrapping view using ``nativeWrappingView(for:)``,
/// if you wish to reimplement these features (or use [MenuItemView](https://github.com/MrAsterisco/MenuItemView)).
public struct TreePicker<Item: TreePickerItem>: View where Item.Children == Item {
	@Binding var items: [Item]
	@Binding var selectedItem: Item.ID?
	
	var createNewItemHandler: ((Item.ID) -> ())?
	var itemViewHandler: ((Item) -> AnyView?)?
	var wrappingItemNativeView: ((Item) -> NSView?)?
	var segmentWidthHandler: ((Item) -> CGFloat?)?
	
	/// Create a new picker with the given items and selection.
	///
	/// - parameters:
	/// 	- items: The items to display.
	/// 	- selectedItem: The currently selected item.
	public init(items: Binding<[Item]>, selectedItem: Binding<Item.ID?>) {
		self._items = items
		self._selectedItem = selectedItem
	}
	
	public var body: some View {
		SegmentedControl(
			items: $items,
			selectedItem: $selectedItem,
			createNewItemHandler: createNewItemHandler,
			itemViewHandler: itemViewHandler,
			wrappingItemView: wrappingItemNativeView,
			segmentWidthHandler: segmentWidthHandler
		)
	}
}

public extension TreePicker {
	/// Set the closure to be invoked when the create new menu item is selected.
	///
	/// - note: This closure is applicable only for items that return `true` to `allowsAdding`.
	func onCreateNewItem(_ handler: @escaping (Item.ID) -> ()) -> Self {
		var newSelf = self
		newSelf.createNewItemHandler = handler
		return newSelf
	}
	
	/// Set the closure to be invoked when a view for an item needs to be created.
	///
	/// - note: If you return a non `nil` value for the item, it will be used as view for the
	/// corresponding menu item.
	/// - warning: Top-level items that are represented in the segmented control do not support
	/// this option; the handler will not be invoked for those items, it will only be invoked for children.
	func view<Content: View>(for viewHandler: @escaping (Item) -> Content?) -> Self {
		var newSelf = self
		newSelf.itemViewHandler = {
			guard let view = viewHandler($0) else { return nil }
			return AnyView(view)
		}
		return newSelf
	}
	
	/// Set the closure to be invoked when wrapping items inside a menu item.
	///
	/// The resulting view, if not `nil`, will be used to wrap items that return a non-`nil` value to ``view(for:)``.
	/// This is particularly useful to provide native menu-like functionalities in the TreePicker, as the `NSMenuItem` stops
	/// providing basic features such as highlighting when a view is assigned.
	///
	/// - note: This function expects an `NSView` to be returned, hence it can only be used in code that can import `AppKit`.
	///
	/// - seealso: Checkout [MenuItemView](https://github.com/MrAsterisco/MenuItemView) for an already built implementation
	/// that simulates a normal menu item.
	func nativeWrappingView(for wrappingViewHandler: @escaping (Item) -> NSView?) -> Self {
		var newSelf = self
		newSelf.wrappingItemNativeView = wrappingViewHandler
		return newSelf
	}
	
	/// Set the closure to be invoked when calculating the width of top-level items.
	///
	/// If this is not set or when invoked returns `nil`, the system will calculate the width
	/// automatically.
	///
	/// - warning: This option is only invoked for top-level items, as they are represented
	/// in a segmented control which supports this option. Children are not affected.
	func widthOfSegment(_ handler: @escaping (Item) -> CGFloat?) -> Self {
		var newSelf = self
		newSelf.segmentWidthHandler = handler
		return newSelf
	}
}
#endif

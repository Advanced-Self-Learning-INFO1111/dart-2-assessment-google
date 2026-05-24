import "dart:io";
import 'package:simple_api_call/simple_api_call.dart';
import "dart:convert";

/// This is the item class, it takes in
/// name and price of the item. 
class Item {
	String? name;
	double? price;

	Item(this.name, this.price);
}

dynamic getWeather() async {
  var res = await apiCall("https://api.open-meteo.com/v1/forecast?latitude=-33.77&longitude=150.84&current=temperature_2m&temperature_unit=celsius&forecast_days=1");
  var decodedRes = res.body as Map<String, dynamic>;

  return decodedRes['current']['temperature_2m'];
}

/// Creates the store inventory based on the itemsToCreate map.
/// Returns a map of item ID and the Item object. 
Map<int, Item> createStoreInventory() {
	// Items to put into the map.
	Map<String, double> itemsToCreate = {
		"Apple": 1.50,
		"Banana": 1.00,
		"Meat Pie": 4.50
	};

	Map<int, Item> returnableMap = {};

	// Loop over every item, create an item object,
	// and then add it to returnableMap as an item.
	int i = 0;
	for (var entry in itemsToCreate.entries) {
		i++;
		Item item_to_add = Item(entry.key, entry.value);
		returnableMap[i] = item_to_add;
	}

	return returnableMap;
}

/// Tries to obtain what exact item the user wants
int getUserInput(int amountOfItems) {
	// Gets user input and puts it in a nullable variable
	
	// Add 1 to amountOfItems because we add 1 extra option to the list
	// of items which is "Checkout & Exit"
	amountOfItems++;

	while (true) {
		print('');
		stdout.write("Enter the number of the item you want to buy: ");
		String userInput = stdin.readLineSync() ?? "";
		
		// When Dart tries to convert an input that is null or a string,
		// throw an error and say that is invalid input.
		try {
			int selection = int.parse(userInput);

			if (selection > amountOfItems || selection < 1) {
				throw RangeError("Selection is outside of range.");
			}
			return selection;
		} on RangeError { 
			print("Please select a number between 1 to $amountOfItems");
		} on FormatException {
			print("Invalid selection.\nPlease select a number between 1 to $amountOfItems");
		} catch (e) {
			print("An error occurred: $e");
		}
	}
	
}

/// Tries to obtain how many of that item the user wants.
int getAmount() {
	while (true) {
		stdout.write("How many would you like? ");
		
		// Step 1: Read input      ->  stdin.readLineSync()  ->  Could be "42", "banana", or null
		// Step 2: Handle null     ->  ?? ''                 ->  Ensures we have a String ("42", "banana", or "")
		// Step 3: Attempt parse   ->  int.tryParse(...)     ->  Returns 42 (for "42") or null (for "banana"/"")
		// Step 4: Final fallback  ->  ?? 0                  ->  If Step 3 returned null, it becomes 0
		int suggestedAmount = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

		if (suggestedAmount < 1) {
			print("Please enter an amount of 1 or above.");
		} else {
			return suggestedAmount;
		}
	}
}

/// Prints the receipt of the user's purchases.
void printReceipt(List<Item> purchasedItems) {
	print("=== Your Receipt ===");
	
	double totalPrice = 0;
	for (var item in purchasedItems) {
		print("* ${item.name} (\$${item.price?.toStringAsFixed(2)})");
		totalPrice += item.price ?? 0.0;
	}
	double afterDiscount = totalPrice * 0.90;

	print("----------------");
	print("Subtotal: \$${totalPrice.toStringAsFixed(2)}");
	print("Total after 10% discount: \$${afterDiscount.toStringAsFixed(2)}");
	print("Thank you for shopping with us!");
}

/// Prints the entire catalogue of items
void printCatalogue(Map<int, Item> storeInventory) {
	int i = 0;
	for (var item in storeInventory.values) {
		i++;

		// Prints the name, and then the price with 2d.p.
		// because price is nullable, use conditional operator ?.
		print("$i. ${item.name} \$${item.price?.toStringAsFixed(2)}");
	}
	i++;
	print("${i}. Checkout & Exit");
}

/// Runs the main loop where users can add items to their list of items to purchase.
List<Item> addItems(int amountOfItems, Map<int, Item> storeInventory, List<Item> purchasedItems) {
	bool userIsShopping = true;
	while (userIsShopping) {
	
		// Get the amount of items.
		int userSelection = getUserInput(amountOfItems);
	
		// Force end when user wants to exit program.
		if (userSelection == amountOfItems + 1) {
			userIsShopping = false;
			continue;
		}
	
		// Get the user selected item
		Item? userSelectedItem = storeInventory[userSelection];
		if (userSelectedItem == null) {
			print("Selection does not exist in inventory.");
			continue;
		}

		// Add the item to the list of purchasedItems
		int amountOfThisItem = getAmount();
		for (int i=0; i < amountOfThisItem; i++) {
			purchasedItems.add(userSelectedItem);
		}

		// Print the addition statement.
		print("Added ${amountOfThisItem}x ${userSelectedItem.name} to your cart.");
	}

	return purchasedItems;
}

void main() async {
	print("=== Welcome to the Dart Truckshop ===");

  try {
    dynamic weather = await getWeather();
    print("It is currently ${weather}degC outside.");
  } catch (e) {
    print("Couldn't get the weather, unfortunately.");
  }
  

	// Create store inventory, the list of purchased items, 
	// and the amount of purchasable items.
	Map<int, Item> storeInventory = createStoreInventory();
	List<Item> purchasedItems = [];
	int amountOfItems = storeInventory.length;
	
	// Print the catalogue, get the items added, and then print the receipt. 
	printCatalogue(storeInventory);
	purchasedItems = addItems(amountOfItems, storeInventory, purchasedItems);
	printReceipt(purchasedItems);
}
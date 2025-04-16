# Fake Store App

A simple iOS app that displays a list of products fetched from the Fake Store API.

## Features

- Grid view of products with images, titles, prices, and ratings
- Product detail view showing full product information
- Add/remove products to/from cart with heart icon
- Cart functionality with badge showing number of items
- Cart view to display selected items
- Checkout functionality with "Thank You" popup
- Pull-to-refresh to update product list
- Error handling for network requests

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## How to Run the App

1. **Clone or download the project**

2. **Open the project in Xcode**
   - Double-click on the `Task.xcodeproj` file to open the project in Xcode

3. **Select a simulator or device**
   - Choose an iOS simulator or connect your iOS device
   - Make sure the device runs iOS 14.0 or later

4. **Build and run**
   - Press `Cmd+R` or click the play button in Xcode to build and run the app

## Implementation Notes

### Architecture

The app follows a simple MVC (Model-View-Controller) architecture:

- **Models**: `Product` and `Rating` for API data
- **Views**: Custom collection and table view cells
- **Controllers**: `ViewController`, `ProductDetailViewController`, and `CartViewController`

### Networking

- Uses `URLSession` for API requests
- Error handling implemented for all network operations
- Images are loaded asynchronously

### Data Management

- Products are fetched from the Fake Store API (https://fakestoreapi.com/products)
- Cart is managed in-memory with the `CartManager` singleton
- Notifications are used to synchronize UI updates when cart changes

### UI Components

- Programmatic UI with Auto Layout
- Grid layout for products
- Detail view with scrollable content
- Cart with table view and swipe-to-delete functionality
- Loading indicators and error states
- Pull-to-refresh for product list

## Known Limitations

- No persistence (cart items are lost when the app is restarted)
- No search functionality
- No product filtering or sorting
- No user authentication
- Images are loaded on-demand which may cause some delay

## Future Enhancements

- Implement Core Data or UserDefaults for cart persistence
- Add search functionality
- Add product filtering by category
- Add product sorting options
- Implement user authentication
- Add product reviews
- Implement wishlist feature separate from cart
- Add payment processing integration 

import Foundation

class CartManager {
    static let shared = CartManager()
    
    private init() {}
    
    private var cartItems: [Product] = []
    
    var cartCount: Int {
        return cartItems.count
    }
    
    func getCartItems() -> [Product] {
        return cartItems
    }
    
    func addToCart(product: Product) {
        if !isInCart(product: product) {
            cartItems.append(product)
        }
    }
    
    func removeFromCart(product: Product) {
        cartItems.removeAll { $0.id == product.id }
    }
    
    func isInCart(product: Product) -> Bool {
        return cartItems.contains { $0.id == product.id }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
} 
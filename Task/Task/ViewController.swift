//
//  ViewController.swift
//  Task
//
//  Created by Venkata.n on 16/04/25.
//

import UIKit

class ViewController: UIViewController {
    
    // UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Error loading products. Pull to refresh."
        label.textAlignment = .center
        label.textColor = .red
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // Properties
    private var products: [Product] = []
    private var cartBadgeButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Store"
        view.backgroundColor = .white
        
        setupUI()
        setupCollectionView()
        setupRefreshControl()
        setupCartButton()
        
        // Add observer for cart updates
        NotificationCenter.default.addObserver(self, selector: #selector(cartUpdated), name: NSNotification.Name("CartUpdated"), object: nil)
        
        // Fetch products
        fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCartBadge()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupCartButton() {
        let cartButton = UIButton(type: .system)
        cartButton.setImage(UIImage(systemName: "cart"), for: .normal)
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        
        cartBadgeButton = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItem = cartBadgeButton
        
        updateCartBadge()
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        fetchProducts()
    }
    
    @objc private func cartButtonTapped() {
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc private func cartUpdated() {
        updateCartBadge()
        
        // Also update the collection view cells to reflect changes in the cart
        collectionView.reloadData()
    }
    
    // MARK: - API Calls
    
    private func fetchProducts() {
        errorLabel.isHidden = true
        activityIndicator.startAnimating()
        
        NetworkService.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.collectionView.reloadData()
                    
                case .failure(let error):
                    print("Error fetching products: \(error)")
                    self?.errorLabel.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateCartBadge() {
        let cartCount = CartManager.shared.cartCount
        
        if let cartButton = cartBadgeButton?.customView as? UIButton {
            if cartCount > 0 {
                let badgeLabel = UILabel(frame: CGRect(x: 20, y: -5, width: 20, height: 20))
                badgeLabel.layer.cornerRadius = 10
                badgeLabel.layer.masksToBounds = true
                badgeLabel.backgroundColor = .red
                badgeLabel.textColor = .white
                badgeLabel.font = UIFont.systemFont(ofSize: 12)
                badgeLabel.textAlignment = .center
                badgeLabel.text = "\(cartCount)"
                cartButton.addSubview(badgeLabel)
            } else {
                // Remove any existing badge
                cartButton.subviews.forEach { subview in
                    if let label = subview as? UILabel, label.backgroundColor == .red {
                        label.removeFromSuperview()
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let product = products[indexPath.item]
        cell.configure(with: product)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}


//
//  OrderBookCell.swift
//  PrestoLabs
//
//  Created by tzh .
//

import UIKit

/**
 A custom collection view cell used to display order book data.
 
 This cell displays order book details such as price and quantity for either Buy or Sell orders.
 */
class OrderBookCell: UICollectionViewCell {
    
    /// Label to display the first data value (either price or quantity depending on order side).
    
    private let lblFirst : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
        
    }()
    /// Label to display the second data value (either price or quantity depending on order side).
    private let lblSecond: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /**
     Initializes a new `OrderBookCell` instance with a given frame.
     
     - Parameter frame: The frame rectangle for the cell.
     
     This initializer sets up the UI elements within the cell by calling the `setupUI()` method.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Sets up the UI elements within the cell.
     
     This private method adds the first and second data labels as subviews to the content view,
     and defines their layout constraints.
     */
    private func setupUI() {
        contentView.addSubview(lblFirst)
        contentView.addSubview(lblSecond)
        
        NSLayoutConstraint.activate([
            lblFirst.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            lblFirst.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            lblFirst.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            lblSecond.topAnchor.constraint(equalTo: lblFirst.topAnchor),
            lblSecond.leadingAnchor.constraint(equalTo: lblFirst.trailingAnchor, constant: 8),
            lblSecond.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            lblSecond.heightAnchor.constraint(equalTo: lblFirst.heightAnchor) // Set the same height as lblQty
        ])
    }
    
    /**
     Configures the cell with order book item data.
     
     - Parameter orderBookItem: The order book item containing price and quantity information.
     
     This method updates the cell's labels with order book item information.
     It also adjusts text colors and alignments based on the order side (Buy or Sell).
     */
    func configure(orderBookItem: OrderBookItem) {
        if orderBookItem.side == "Sell" {
            lblFirst.text = String(orderBookItem.price)
            lblSecond.text = String(orderBookItem.qty ?? 0)
            lblFirst.textColor = .red
            lblSecond.textColor = .gray
            lblFirst.textAlignment = .left
            lblSecond.textAlignment = .right
            
        } else {
            lblFirst.text = String(orderBookItem.qty ?? 0)
            lblSecond.text = String(orderBookItem.price)
            lblSecond.textColor = .green
            lblFirst.textColor = .gray
            lblFirst.textAlignment = .left
            lblSecond.textAlignment = .right
            
            
        }
    }
    
    
    
}

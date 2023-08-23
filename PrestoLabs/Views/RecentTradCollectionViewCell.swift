//
//  RecentTradCollectionViewCell.swift
//  PrestoLabs
//
//  Created by tzh .
//

import UIKit

/**
 A custom collection view cell used to display recent trade data.
 
 This cell displays trade details such as quantity, price, and time in a collection view.
 */
class RecentTradCollectionViewCell: UICollectionViewCell {
    /// Label to display the trade quantity.
    private let lblQty : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
        
    }()
    
    /// Label to display the trade price.
    private let lblPrice: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /// Label to display the trade time.
    private let lblTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /**
     Initializes a new `RecentTradCollectionViewCell` instance with a given frame.
     
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
     
     This private method adds the trade quantity, price, and time labels as subviews to the content view,
     and defines their layout constraints.
     */
    private func setupUI() {
        contentView.addSubview(lblQty)
        contentView.addSubview(lblPrice)
        contentView.addSubview(lblTime)
        
        NSLayoutConstraint.activate([
            lblPrice.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            lblPrice.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            lblPrice.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            lblQty.topAnchor.constraint(equalTo: lblPrice.topAnchor),
            lblQty.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            lblQty.heightAnchor.constraint(equalTo: lblPrice.heightAnchor)
        ])
        NSLayoutConstraint.activate([
            lblTime.topAnchor.constraint(equalTo: lblPrice.topAnchor),
            lblTime.leadingAnchor.constraint(equalTo: lblQty.trailingAnchor, constant: 8),
            lblTime.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            lblTime.heightAnchor.constraint(equalTo: lblPrice.heightAnchor)
        ])
    }
    
    /**
     Configures the cell with trade data.
     
     - Parameter trade: The trade object containing trade information.
     
     This method updates the cell's labels with trade information such as quantity, price, and time.
     It also adjusts text colors based on the trade side (Buy or Sell).
     */
    
    func configure(trade: Trade) {
        lblQty.text = String(trade.size)
        lblPrice.text = String(trade.price)
        lblTime.text = trade.dateStr
        
        self.setTextColor(side: trade.side)
    }
    
    /**
     Sets the text color of the labels based on the trade side.
     
     - Parameter side: The trade side, which can be "Buy" or "Sell".
     
     This private method adjusts the text color of the labels to red for Sell trades and green for Buy trades.
     */
    private func setTextColor(side : String) {
        if side == "Sell" {
            self.lblPrice.textColor = .red
            self.lblQty.textColor = .red
            self.lblTime.textColor = .red
            
        } else {
            self.lblPrice.textColor = .green
            self.lblQty.textColor = .green
            self.lblTime.textColor = .green
            
            
        }
    }
    
}

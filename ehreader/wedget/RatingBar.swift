//
//  RatingBar.swift
//  RatingBar
//
//  Created by Jose Hernandez on 03/01/2016.
//  Copyright © 2016 Jose Hernandez. All rights reserved.
//

import UIKit

@IBDesignable
public final class RatingBar: UIControl {

    /*
     * Load the images ONLY once the first time they are required.  Subsequent uses will simply reference the same
     * objects to save memory.
     */
    private let bundle : NSBundle! = NSBundle(forClass: RatingBar.self)

    private lazy var normalStarImage : UIImage! = {
        return UIImage(named: "EmptyStar", inBundle: self.bundle, compatibleWithTraitCollection: nil)
    }()
    
    private lazy var highlightedStarImage : UIImage! = {
        UIImage(named: "FullStar", inBundle: self.bundle, compatibleWithTraitCollection: nil)
    }()

    // A convenience ordered array of subviews whose contents mirrors the self.subviews property
    private var images : [UIImageView] = []

    // Number of stars to show in the rating bar
    private var _stars : Int = 5 {
        didSet {
            self.updateUI()
        }
    }

    // Transient variable that normalises the star count on its way in and out of the rating bar
    @IBInspectable
    public var stars : Int {
        get { return max(0, self._stars) }
        set { self._stars = max(0, newValue) }
    }

    /*
     * Rating value used to highlight the appropriate number of stars.  Please note that a value changed event is sent
     * whenever the rating value is updated.
     */
    private var _rating : Float = 0.0 {
        didSet {
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
            self.updateUI()
        }
    }

    // Transient variable that normalises the rating values on their way in and out of the rating bar
    @IBInspectable
    public var rating : Float {
        get { return min(Float(_stars), max(0.0, self._rating)) }
        set { self._rating = min(Float(_stars), max(0.0, newValue)) }
    }

    // MARK: - Intialisers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.updateUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.updateUI()
    }

    // MARK: - UI updates

    private func updateUI() {
        for index in 0 ..< max(_stars, images.count) {
            if (index >= _stars) {
                // Remove old images if the number of stars has decreased
                images.removeAtIndex(_stars).removeFromSuperview()
            } else if (index >= images.count) {
                // Add new images if the number of stars has increased
                let star = UIImageView(image: normalStarImage, highlightedImage: highlightedStarImage)
                star.contentMode = UIViewContentMode.ScaleAspectFit
                star.highlighted = Float(index) < _rating
                star.tag = index
                self.addSubview(star)
                self.images.append(star)
            } else {
                // Update the selection state according to the ratings
                images[index].highlighted = Float(index) < _rating
            }
        }
    }

    // MARK: - Resizing and layout

    /*
     * Called by iOS to calculate the optimal size for the star rating bar to allow it to play well with autolayouts
     */
    public override func intrinsicContentSize() -> CGSize {
        let starWidth = CGRectGetWidth(self.frame) / CGFloat(self._stars)
        let starHeight = CGRectGetHeight(self.frame)
        let starLength = min(starWidth, starHeight)
        return CGSizeMake(CGFloat(_stars) * starLength, CGFloat(starLength))
    }

    /*
     * Lays out the stars within the control using the bar's height as the star's height and the bar's width divided by
     * the number of stars as the star's width. Stars are physically arranged to start from the top left of the
     * containing view.
     *
     * Compute the 'length' to be the minumum of the width and height so that it fits the star horizontally and
     * vertically within the containing view whilst maintaining the aspect ratio.
     */
    public override func layoutSubviews() {
        let length = min(self.frame.width / CGFloat(self._stars), self.frame.height)
        for (index, value) in images.enumerate() {
            value.frame = CGRectMake(CGFloat(index) * length, CGFloat(0), length, length)
        }
    }
    
    // MARK: - Update ratings via user interaction (touch)

    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        return updateRating(touch)
    }
    
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        return updateRating(touch)
    }

    /*
     * Updates the rating value based on where the user touch was detected on the rating bar
     */
    private func updateRating(touch : UITouch) -> Bool {
        let point = touch.locationInView(self)
        if point.x < 0 {
            self._rating = 0.0
        } else {
            for (index, value) in images.enumerate() {
                if value.frame.contains(point) {
                    self._rating = Float(index + 1)
                    break
                }
            }
        }
        return true;
    }

}

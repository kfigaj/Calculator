//
//  GraphView.h
//  Calculator
//
//  Created by Krzysztof Figaj on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

// data source for funtion values
@protocol GraphViewDataSource

- (double) calculateFor:(GraphView *)sender valueFor:(double)x;

@end

@interface GraphView : UIView

@property (nonatomic, weak) id<GraphViewDataSource> graphViewData;
// graph properties
@property (nonatomic) CGFloat scale; 
@property (nonatomic) CGPoint origin;

- (IBAction) handlePinchFrom:(UIGestureRecognizer *) gestureRecognizer;
- (IBAction) handlePanFrom:(UIGestureRecognizer *) gestureRecognizer;
- (IBAction) handleTapFrom:(UITapGestureRecognizer *) gestureRecognizer;

@end

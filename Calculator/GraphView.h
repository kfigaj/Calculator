//
//  GraphView.h
//  Calculator
//
//  Created by Krzysztof Figaj on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource

- (double) calculateFor:(GraphView *)sender valueFor:(double)x;

@end

@interface GraphView : UIView

@property (nonatomic, weak) id<GraphViewDataSource> graphViewData;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;



@end

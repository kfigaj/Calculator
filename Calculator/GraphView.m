//
//  GraphView.m
//  Calculator
//
//  Created by Krzysztof Figaj on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize graphViewData = _graphViewData;
@synthesize scale = _scale;
@synthesize origin = _origin;

#define DEFAULT_SCALE 1

- (void) setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // redraw only when it's needed
    }
}

- (CGFloat) scale {
    if (!_scale) { // do not allow zero scale
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) scale:self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextBeginPath(context);
    /*
    for (doube ; <#condition#>; <#increment#>) {
        <#statements#>
    }*/
    
    CGContextStrokePath(context);
}

@end

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

- (void) setOrigin:(CGPoint)origin {
    if (!CGPointEqualToPoint(origin, _origin)) {
        _origin = origin;
        [self setNeedsDisplay]; // redraw only when it's needed
    }
}

- (CGPoint) origin {
    if(CGPointEqualToPoint(CGPointZero, _origin)) { // TODO get value from user dict
        _origin.x = self.bounds.size.width/2;
        _origin.y = self.bounds.size.height/2;
    }
    return _origin;
}

- (IBAction) handlePinchFrom:(UIPinchGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged ||
        gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.scale *= gestureRecognizer.scale;
        gestureRecognizer.scale = 1; // use incremental scale
    }
    
}

- (IBAction) handlePanFrom:(UIPanGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged ||
        gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [gestureRecognizer setTranslation:CGPointZero inView:self]; // use incremental translation
    }
}

- (IBAction) handleTapFrom:(UITapGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint newOrigin = [gestureRecognizer locationInView:self];
        self.origin = newOrigin;
    }
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    
    CGFloat step = 1/[self contentScaleFactor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    
    CGContextBeginPath(context);
    //start from left hand side of the view
    CGContextMoveToPoint(context, self.bounds.origin.x,  self.origin.y);
    
    for (double x=0 ; x < self.bounds.size.width; x += step) {
        // convert x to units and get value of funtion for it from data source
        double y = [self.graphViewData calculateFor:self valueFor:(x-self.origin.x)/self.scale];
        
        // convert result to view coordinates and draw a line
        CGContextAddLineToPoint(context, x, (self.origin.y - y*self.scale));
        
        // move point 
        CGContextMoveToPoint(context, x, (self.origin.y - y*self.scale));
    }
    
    CGContextStrokePath(context);
}

@end

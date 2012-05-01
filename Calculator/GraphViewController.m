//
//  GraphViewController.m
//  Calculator
//
//  Created by Krzysztof Figaj on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"

@interface GraphViewController () <GraphViewDataSource>

@property (nonatomic, weak) IBOutlet GraphView* graphView;

@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphView = _graphView;

- (void) setProgram:(id)program {
    _program = program;
    [self.graphView setNeedsDisplay];
}

- (void) setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    self.graphView.graphViewData = self;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self.graphView action:@selector(handlePinchFrom:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handlePanFrom:)]];
    
    // we require three taps to move origin to selected point
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handleTapFrom:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLoad{
    self.title = [CalculatorBrain descriptionOfProgram:self.program];
}


- (double) calculateFor:(GraphView *)sender valueFor:(double)x {
    return [CalculatorBrain runProgram:self.program usingVariableValues: [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:x] forKey:@"x"]];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end

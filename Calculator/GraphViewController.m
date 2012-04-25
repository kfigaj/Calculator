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
    _graphView.graphViewData = self;
}

- (void)viewDidLoad{
    self.title = [CalculatorBrain descriptionOfProgram:self.program];
}


- (double) calculateFor:(GraphView *)sender valueFor:(double)x {
    return [CalculatorBrain runProgram:self.program usingVariableValues: [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:x] forKey:@"x"]];
}

@end

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
@property (nonatomic, weak) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* splitViewBarButtonItem;

@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void) updateTitleInToolbar {
    // Initialy there are three button in toolbar. Midle one is for displaying program description
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    UIBarButtonItem *titleButton = [items objectAtIndex:[items count]/2];
    titleButton.title = [CalculatorBrain descriptionOfProgram:self.program];
    self.toolbar.items = items;
}

- (void) setProgram:(id)program {
    _program = program;
    if (_toolbar) [self updateTitleInToolbar];
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

- (void) awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // set title on IPhone
    self.title = [CalculatorBrain descriptionOfProgram:self.program];
    // get default view settings
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.graphView.scale = [userDefaults doubleForKey:@"graphViewScale"];
    self.graphView.origin = CGPointMake([userDefaults doubleForKey:@"graphViewOriginX"], [userDefaults doubleForKey:@"graphViewOriginY"]);
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // save defualt settings - works for IPhone only
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:self.graphView.scale forKey:@"graphViewScale"];
    [userDefaults setDouble:self.graphView.origin.x forKey:@"graphViewOriginX"];
    [userDefaults setDouble:self.graphView.origin.y forKey:@"graphViewOriginY"];
    [userDefaults synchronize];
}


// Calculate value of program for given x
- (double) calculateFor:(GraphView *)sender valueFor:(double)x {
    if ([[CalculatorBrain descriptionOfProgram:self.program] isEqualToString:@""]) {
        return NAN; // return nothing if program is not provided
    }
    return [CalculatorBrain runProgram:self.program usingVariableValues: [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:x] forKey:@"x"]];
}

- (void) handleBarButtonItem:(UIBarButtonItem *) barButtonItem {
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    if(_splitViewBarButtonItem) [items removeObject:_splitViewBarButtonItem];
    if(barButtonItem) [items insertObject:barButtonItem atIndex:0];
    self.toolbar.items = items;
    _splitViewBarButtonItem = barButtonItem;
}


// Split view controller deletation methods
- (BOOL) splitViewController:(UISplitViewController *)svc 
    shouldHideViewController:(UIViewController *)vc 
               inOrientation:(UIInterfaceOrientation)orientation {
    // hide button in potrait mode
    return UIInterfaceOrientationIsPortrait(orientation) ? YES: NO;
}

- (void) splitViewController:(UISplitViewController *)svc 
      willShowViewController:(UIViewController *)aViewController 
   invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self handleBarButtonItem:nil];
}

- (void) splitViewController:(UISplitViewController *)svc 
      willHideViewController:(UIViewController *)aViewController 
           withBarButtonItem:(UIBarButtonItem *)barButtonItem 
        forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Calculator";
    [self handleBarButtonItem:barButtonItem];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end

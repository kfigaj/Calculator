//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Krzysztof Figaj on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringNumber; // hold state
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues; // values are provided by test buttons
- (void) runProgramAndUpdateUI;
@end

@implementation CalculatorViewController
@synthesize variableValues = _variableValues;
@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringNumber = _userIsInTheMiddleOfEnteringNumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *) brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit  = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringNumber && 
        ![@"0" isEqualToString:self.display.text]) { // prevent addng two zeros. 
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text  = digit;
        self.userIsInTheMiddleOfEnteringNumber = YES;
    }
}

- (IBAction)dotPressed {
    if(self.userIsInTheMiddleOfEnteringNumber) {
        // add only one dot
        NSRange currentDotRange = [self.display.text rangeOfString:@"."];
        if(currentDotRange.location == NSNotFound)
            self.display.text = [self.display.text stringByAppendingString:@"."];
    } else{ // shortcut for user insted of pressing 0 and . 
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringNumber = YES;
    }
}

- (IBAction)enterPressed {
    NSString  *currentText = self.display.text;
    if([currentText hasSuffix:@"."]){
        // just becasue 0. looks bad for me in history label.
        currentText = [currentText substringToIndex:[currentText length]-1];
    }
    [self.brain pushOperand:[currentText doubleValue]];
    self.history.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    self.userIsInTheMiddleOfEnteringNumber = NO;
}

- (void) runProgramAndUpdateUI{
    id result = [CalculatorBrain runProgram:[self.brain program] usingVariableValues:[self testVariableValues]];
    if ([result isKindOfClass:[NSString class]]) { // error occured
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self.brain removeLastElement];
        return;
    }
    // Update all labels
    self.display.text = [[NSString alloc] initWithFormat:@"%g", [result doubleValue]];
    self.history.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    self.variableValues.text = @"";
    for (NSString *variable in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        id value = [self.testVariableValues objectForKey:variable] ? [self.testVariableValues objectForKey:variable]: @"0"; // displaying result as x = (null) is ugly so show default value
        self.variableValues.text = [self.variableValues.text stringByAppendingFormat:@"%@ = %@ ", variable, value];
    }
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) { 
        [self enterPressed]; // perform automatic enter when operation is pressed
    }

    [self.brain pushOperation:[sender currentTitle]];
    [self runProgramAndUpdateUI];
}

- (IBAction)clearPressed:(id)sender {
    [self.brain clear];
    self.display.text = @"0";
    self.history.text = @"";
    self.variableValues.text = @"";
    self.userIsInTheMiddleOfEnteringNumber = NO;
}

- (IBAction)backspacePressed:(id)sender {
    if(self.userIsInTheMiddleOfEnteringNumber) {
        NSString* withoutLast = [self.display.text substringToIndex:[self.display.text length]-1];
        if ([withoutLast length] == 0 || [withoutLast isEqualToString:@"-"]) {
            [self runProgramAndUpdateUI];
            self.userIsInTheMiddleOfEnteringNumber = NO;
        } else {
            self.display.text = withoutLast;
        }
    } else {
        [self.brain removeLastElement];
        [self runProgramAndUpdateUI];
    }
}

- (IBAction)changeSignPressed:(id)sender {
    NSString *currentDisplay = self.display.text;
    if ([currentDisplay doubleValue] == 0.0) {
        // no need to change a sign of zero
        return;
    }
    
    if (self.userIsInTheMiddleOfEnteringNumber) {
        if ([currentDisplay hasPrefix:@"-"]) {
            self.display.text = [currentDisplay substringFromIndex:1];
        } else {
            self.display.text = [@"-" stringByAppendingString:currentDisplay];
        }
    } else {
        [self operationPressed:sender];
    }
}

- (IBAction)variablePressed:(id)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) { 
        [self enterPressed]; // perform automatic enter when operation is pressed
    }
    // simply send variable and update history display
    [self.brain pushVariable:[sender currentTitle]];
    self.history.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

- (IBAction)testValuesPressed:(UIButton *)sender {
    // set variables to one of the predifined testcase set
    if ([@"Test 1" isEqualToString:sender.currentTitle]) {
        self.testVariableValues =  nil;
    }else if([@"Test 2" isEqualToString:sender.currentTitle]){
        self.testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys: [[NSNumber alloc] initWithDouble:0.0], @"x", [[NSNumber alloc] initWithDouble:5], @"y", [[NSNumber alloc] initWithDouble:-4], @"z", nil];
    }else if([@"Test 3" isEqualToString:sender.currentTitle]){
        self.testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys: [[NSNumber alloc] initWithDouble:0.5], @"x", @"x", @"y", @"85", @"z", nil];
    }
    
    [self runProgramAndUpdateUI];
}

@end

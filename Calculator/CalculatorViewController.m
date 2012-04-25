//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Krzysztof Figaj on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringNumber; // hold state
@property (nonatomic, strong) CalculatorBrain *brain;
- (void) runProgramAndUpdateUI;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringNumber = _userIsInTheMiddleOfEnteringNumber;
@synthesize brain = _brain;

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
    double result = [CalculatorBrain runProgram:[self.brain program]];
    // Update all the labels
    self.display.text = [[NSString alloc] initWithFormat:@"%g", result];
    self.history.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"DrawGraph"]){
        [segue.destinationViewController setProgram:[self.brain program]];
    }
    
}


@end

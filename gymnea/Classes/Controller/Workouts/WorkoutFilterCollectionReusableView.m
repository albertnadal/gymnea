//
//  WorkoutFilterCollectionReusableView.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 22/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutFilterCollectionReusableView.h"

@implementation WorkoutFilterCollectionReusableView


- (IBAction)showWorkoutTypeSelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showWorkoutTypeSelector)])
        [self.delegate showWorkoutTypeSelector];
}

- (IBAction)showWorkoutFrequencySelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showWorkoutFrequencySelector)])
        [self.delegate showWorkoutFrequencySelector];
}

- (IBAction)showWorkoutLevelSelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showWorkoutLevelSelector)])
        [self.delegate showWorkoutLevelSelector];
}

- (void)workoutTypeNameSelected:(NSString *)name
{
    [self.typeButton setTitle:name forState:UIControlStateNormal];
}

- (void)workoutFrequencyNameSelected:(NSString *)name
{
    [self.frequencyButton setTitle:name forState:UIControlStateNormal];
}

- (void)workoutLevelNameSelected:(NSString *)name
{
    [self.levelButton setTitle:name forState:UIControlStateNormal];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES];

    if([self.delegate respondsToSelector:@selector(searchWorkoutWithTextDidBegin)]) {
        [self.delegate searchWorkoutWithTextDidBegin];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];

    if([searchBar.text length]) {
        [searchBar setText:@""];
    }

    if([self.delegate respondsToSelector:@selector(searchWorkoutWithText:)]) {
        [self.delegate searchWorkoutWithText:@""];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if([searchBar.text length] != 0) {
        if([self.delegate respondsToSelector:@selector(searchWorkoutWithText:)]) {
            [self.delegate searchWorkoutWithText:searchBar.text];
        }
    }

    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
}

@end

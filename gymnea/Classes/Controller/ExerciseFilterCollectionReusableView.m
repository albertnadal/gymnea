//
//  ExerciseFilterCollectionReusableView.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 13/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExerciseFilterCollectionReusableView.h"

@implementation ExerciseFilterCollectionReusableView


- (IBAction)showExerciseTypeSelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showExerciseTypeSelector)])
        [self.delegate showExerciseTypeSelector];
}

- (IBAction)showMuscleSelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showMuscleSelector)])
        [self.delegate showMuscleSelector];
}

- (IBAction)showEquipmentSelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showEquipmentSelector)])
        [self.delegate showEquipmentSelector];
}

- (IBAction)showExerciseLevelSelector:(id)sender
{
    if([self.delegate respondsToSelector:@selector(showExerciseLevelSelector)])
        [self.delegate showExerciseLevelSelector];
}

- (void)exerciseTypeNameSelected:(NSString *)name
{
    [self.typeButton setTitle:name forState:UIControlStateNormal];
}

- (void)muscleNameSelected:(NSString *)name
{
    [self.muscleButton setTitle:name forState:UIControlStateNormal];
}

- (void)equipmentNameSelected:(NSString *)name
{
    [self.equipmentButton setTitle:name forState:UIControlStateNormal];
}

- (void)exerciseLevelNameSelected:(NSString *)name
{
    [self.levelButton setTitle:name forState:UIControlStateNormal];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES];

    if([self.delegate respondsToSelector:@selector(searchExerciseWithTextDidBegin)]) {
        [self.delegate searchExerciseWithTextDidBegin];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];

    if([searchBar.text length]) {
        [searchBar setText:@""];
    }

    if([self.delegate respondsToSelector:@selector(searchExerciseWithText:)]) {
        [self.delegate searchExerciseWithText:@""];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if([searchBar.text length] != 0) {
        if([self.delegate respondsToSelector:@selector(searchExerciseWithText:)]) {
            [self.delegate searchExerciseWithText:searchBar.text];
        }
    }

    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
}

/*
- (void)awakeFromNib
{
    // Initialization code
}*/

@end

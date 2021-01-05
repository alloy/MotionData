/*
     File: TypeSelectionViewController.m 
 Abstract: Table view controller to allow the user to select the recipe type.
 The options are presented as items in the table view; the selected item has a check mark in the accessory view. The controller caches the index path of the selected item to avoid the need to perform repeated string comparisons after an update.
  
  Version: 1.4 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "TypeSelectionViewController.h"
#import "Recipe.h"


@interface TypeSelectionViewController()
@property (nonatomic, retain) NSArray *recipeTypes;
@end


@implementation TypeSelectionViewController

@synthesize recipe;
@synthesize recipeTypes;


#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	// Fetch the recipe types in alphabetical order by name from the recipe's context.
	NSManagedObjectContext *context = [recipe managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"RecipeType" inManagedObjectContext:context]];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *types = [context executeFetchRequest:fetchRequest error:&error];
	self.recipeTypes = types;
	
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark UITableView Delegate/Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of recipe types
    return [recipeTypes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }
    
    // Configure the cell
	NSManagedObject *recipeType = [recipeTypes objectAtIndex:indexPath.row];
    cell.textLabel.text = [recipeType valueForKey:@"name"];
    
    if (recipeType == recipe.type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // If there was a previous selection, unset the accessory view for its cell.
	NSManagedObject *currentType = recipe.type;
	
    if (currentType != nil) {
		NSInteger index = [recipeTypes indexOfObject:currentType];
		NSIndexPath *selectionIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:selectionIndexPath];
        checkedCell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Set the checkmark accessory for the selected row.
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];    

     // Update the type of the recipe instance
    recipe.type = [recipeTypes objectAtIndex:indexPath.row];
    
    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc {
    [recipe release];
    [recipeTypes release];
    [super dealloc];
}


@end

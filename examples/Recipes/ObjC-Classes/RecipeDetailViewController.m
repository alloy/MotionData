/*
     File: RecipeDetailViewController.m 
 Abstract: Table view controller to manage an editable table view that displays information about a recipe.
 The table view uses different cell types for different row types.
  
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

#import "RecipeDetailViewController.h"

#import "Recipe.h"
#import "Ingredient.h"

#import "InstructionsViewController.h"
#import "TypeSelectionViewController.h"
#import "RecipePhotoViewController.h"
#import "IngredientDetailViewController.h"


@interface RecipeDetailViewController (PrivateMethods)
- (void)updatePhotoButton;
@end




@implementation RecipeDetailViewController

@synthesize recipe;
@synthesize ingredients;

@synthesize tableHeaderView;
@synthesize photoButton;
@synthesize nameTextField, overviewTextField, prepTimeTextField;


#define TYPE_SECTION 0
#define INGREDIENTS_SECTION 1
#define INSTRUCTIONS_SECTION 2


#pragma mark -
#pragma mark View controller

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Create and set the table header view.
    if (tableHeaderView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DetailHeaderView" owner:self options:nil];
        self.tableView.tableHeaderView = tableHeaderView;
        self.tableView.allowsSelectionDuringEditing = YES;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
	
    [photoButton setImage:recipe.thumbnailImage forState:UIControlStateNormal];
	self.navigationItem.title = recipe.name;
    nameTextField.text = recipe.name;    
    overviewTextField.text = recipe.overview;    
    prepTimeTextField.text = recipe.prepTime;    
	[self updatePhotoButton];

	/*
	 Create a mutable array that contains the recipe's ingredients ordered by displayOrder.
	 The table view uses this array to display the ingredients.
	 Core Data relationships are represented by sets, so have no inherent order. Order is "imposed" using the displayOrder attribute, but it would be inefficient to create and sort a new array each time the ingredients section had to be laid out or updated.
	 */
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedIngredients = [[NSMutableArray alloc] initWithArray:[recipe.ingredients allObjects]];
	[sortedIngredients sortUsingDescriptors:sortDescriptors];
	self.ingredients = sortedIngredients;

	[sortDescriptor release];
	[sortDescriptors release];
	[sortedIngredients release];
	
	// Update recipe type and ingredients on return.
    [self.tableView reloadData]; 
}


- (void)viewDidUnload {
    self.tableHeaderView = nil;
	self.photoButton = nil;
	self.nameTextField = nil;
	self.overviewTextField = nil;
	self.prepTimeTextField = nil;
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
	[self updatePhotoButton];
	nameTextField.enabled = editing;
	overviewTextField.enabled = editing;
	prepTimeTextField.enabled = editing;
	[self.navigationItem setHidesBackButton:editing animated:YES];
	

	[self.tableView beginUpdates];
	
    NSUInteger ingredientsCount = [recipe.ingredients count];
    
    NSArray *ingredientsInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:ingredientsCount inSection:INGREDIENTS_SECTION]];
    
    if (editing) {
        [self.tableView insertRowsAtIndexPaths:ingredientsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
		overviewTextField.placeholder = @"Overview";
	} else {
        [self.tableView deleteRowsAtIndexPaths:ingredientsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
		overviewTextField.placeholder = @"";
    }
    
    [self.tableView endUpdates];
	
	/*
	 If editing is finished, save the managed object context.
	 */
	if (!editing) {
		NSManagedObjectContext *context = recipe.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	if (textField == nameTextField) {
		recipe.name = nameTextField.text;
		self.navigationItem.title = recipe.name;
	}
	else if (textField == overviewTextField) {
		recipe.overview = overviewTextField.text;
	}
	else if (textField == prepTimeTextField) {
		recipe.prepTime = prepTimeTextField.text;
	}
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


#pragma mark -
#pragma mark UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    // Return a title or nil as appropriate for the section.
    switch (section) {
        case TYPE_SECTION:
            title = @"Category";
            break;
        case INGREDIENTS_SECTION:
            title = @"Ingredients";
            break;
        default:
            break;
    }
    return title;;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    /*
     The number of rows depends on the section.
     In the case of ingredients, if editing, add a row in editing mode to present an "Add Ingredient" cell.
	 */
    switch (section) {
        case TYPE_SECTION:
        case INSTRUCTIONS_SECTION:
            rows = 1;
            break;
        case INGREDIENTS_SECTION:
            rows = [recipe.ingredients count];
            if (self.editing) {
                rows++;
            }
            break;
		default:
            break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
     // For the Ingredients section, if necessary create a new cell and configure it with an additional label for the amount.  Give the cell a different identifier from that used for cells in other sections so that it can be dequeued separately.
    if (indexPath.section == INGREDIENTS_SECTION) {
		NSUInteger ingredientCount = [recipe.ingredients count];
        NSInteger row = indexPath.row;
		
        if (indexPath.row < ingredientCount) {
            // If the row is within the range of the number of ingredients for the current recipe, then configure the cell to show the ingredient name and amount.
			static NSString *IngredientsCellIdentifier = @"IngredientsCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:IngredientsCellIdentifier];
			
			if (cell == nil) {
				 // Create a cell to display an ingredient.
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IngredientsCellIdentifier] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
            Ingredient *ingredient = [ingredients objectAtIndex:row];
            cell.textLabel.text = ingredient.name;
			cell.detailTextLabel.text = ingredient.amount;
        } else {
            // If the row is outside the range, it's the row that was added to allow insertion (see tableView:numberOfRowsInSection:) so give it an appropriate label.
			static NSString *AddIngredientCellIdentifier = @"AddIngredientCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:AddIngredientCellIdentifier];
			if (cell == nil) {
				 // Create a cell to display "Add Ingredient".
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddIngredientCellIdentifier] autorelease];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            cell.textLabel.text = @"Add Ingredient";
        }
    } else {
         // If necessary create a new cell and configure it appropriately for the section.  Give the cell a different identifier from that used for cells in the Ingredients section so that it can be dequeued separately.
        static NSString *MyIdentifier = @"GenericCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        NSString *text = nil;
        
        switch (indexPath.section) {
            case TYPE_SECTION: // type -- should be selectable -> checkbox
                text = [recipe.type valueForKey:@"name"];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case INSTRUCTIONS_SECTION: // instructions
                text = @"Instructions";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                break;
            default:
                break;
        }
        
        cell.textLabel.text = text;
    }
    return cell;
}


#pragma mark -
#pragma mark Editing rows

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
    NSInteger section = indexPath.section;
    BOOL isEditing = self.editing;
    
    // If editing, don't allow instructions to be selected
    // Not editing: Only allow instructions to be selected
    if ((isEditing && section == INSTRUCTIONS_SECTION) || (!isEditing && section != INSTRUCTIONS_SECTION)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        rowToSelect = nil;    
    }

	return rowToSelect;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    UIViewController *nextViewController = nil;
    
    /*
     What to do on selection depends on what section the row is in.
     For Type, Instructions, and Ingredients, create and push a new view controller of the type appropriate for the next screen.
     */
    switch (section) {
        case TYPE_SECTION:
            nextViewController = [[TypeSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
            ((TypeSelectionViewController *)nextViewController).recipe = recipe;
            break;
			
        case INSTRUCTIONS_SECTION:
            nextViewController = [[InstructionsViewController alloc] initWithNibName:@"InstructionsView" bundle:nil];
            ((InstructionsViewController *)nextViewController).recipe = recipe;
            break;
			
        case INGREDIENTS_SECTION:
            nextViewController = [[IngredientDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
            ((IngredientDetailViewController *)nextViewController).recipe = recipe;
            
            if (indexPath.row < [recipe.ingredients count]) {
                Ingredient *ingredient = [ingredients objectAtIndex:indexPath.row];
                ((IngredientDetailViewController *)nextViewController).ingredient = ingredient;
            }
            break;
			
        default:
            break;
    }
    
    // If we got a new view controller, push it .
    if (nextViewController) {
        [self.navigationController pushViewController:nextViewController animated:YES];
        [nextViewController release];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    // Only allow editing in the ingredients section.
    // In the ingredients section, the last row (row number equal to the count of ingredients) is added automatically (see tableView:cellForRowAtIndexPath:) to provide an insertion cell, so configure that cell for insertion; the other cells are configured for deletion.
    if (indexPath.section == INGREDIENTS_SECTION) {
        // If this is the last item, it's the insertion row.
        if (indexPath.row == [recipe.ingredients count]) {
            style = UITableViewCellEditingStyleInsert;
        }
        else {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    
    return style;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Only allow deletion, and only in the ingredients section
    if ((editingStyle == UITableViewCellEditingStyleDelete) && (indexPath.section == INGREDIENTS_SECTION)) {
        // Remove the corresponding ingredient object from the recipe's ingredient list and delete the appropriate table view cell.
        Ingredient *ingredient = [ingredients objectAtIndex:indexPath.row];
        [recipe removeIngredientsObject:ingredient];
        [ingredients removeObject:ingredient];
        
        NSManagedObjectContext *context = ingredient.managedObjectContext;
        [context deleteObject:ingredient];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}


#pragma mark -
#pragma mark Moving rows

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canMove = NO;
    // Moves are only allowed within the ingredients section.  Within the ingredients section, the last row (Add Ingredient) cannot be moved.
    if (indexPath.section == INGREDIENTS_SECTION) {
        canMove = indexPath.row != [recipe.ingredients count];
    }
    return canMove;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *target = proposedDestinationIndexPath;
    
    /*
     Moves are only allowed within the ingredients section, so make sure the destination is in the ingredients section.
     If the destination is in the ingredients section, make sure that it's not the Add Ingredient row -- if it is, retarget for the penultimate row.
     */
	NSUInteger proposedSection = proposedDestinationIndexPath.section;
	
    if (proposedSection < INGREDIENTS_SECTION) {
        target = [NSIndexPath indexPathForRow:0 inSection:INGREDIENTS_SECTION];
    } else if (proposedSection > INGREDIENTS_SECTION) {
        target = [NSIndexPath indexPathForRow:([recipe.ingredients count] - 1) inSection:INGREDIENTS_SECTION];
    } else {
        NSUInteger ingredientsCount_1 = [recipe.ingredients count] - 1;
        
        if (proposedDestinationIndexPath.row > ingredientsCount_1) {
            target = [NSIndexPath indexPathForRow:ingredientsCount_1 inSection:INGREDIENTS_SECTION];
        }
    }
	
    return target;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	/*
	 Update the ingredients array in response to the move.
	 Update the display order indexes within the range of the move.
	 */
    Ingredient *ingredient = [ingredients objectAtIndex:fromIndexPath.row];
    [ingredients removeObjectAtIndex:fromIndexPath.row];
    [ingredients insertObject:ingredient atIndex:toIndexPath.row];
	
	NSInteger start = fromIndexPath.row;
	if (toIndexPath.row < start) {
		start = toIndexPath.row;
	}
	NSInteger end = toIndexPath.row;
	if (fromIndexPath.row > end) {
		end = fromIndexPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		ingredient = [ingredients objectAtIndex:i];
		ingredient.displayOrder = [NSNumber numberWithInteger:i];
	}
}


#pragma mark -
#pragma mark Photo

- (IBAction)photoTapped {
    // If in editing state, then display an image picker; if not, create and push a photo view controller.
	if (self.editing) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		[self presentModalViewController:imagePicker animated:YES];
		[imagePicker release];
	} else {	
		RecipePhotoViewController *recipePhotoViewController = [[RecipePhotoViewController alloc] init];
        recipePhotoViewController.hidesBottomBarWhenPushed = YES;
		recipePhotoViewController.recipe = recipe;
		[self.navigationController pushViewController:recipePhotoViewController animated:YES];
		[recipePhotoViewController release];
	}
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
	
	// Delete any existing image.
	NSManagedObject *oldImage = recipe.image;
	if (oldImage != nil) {
		[recipe.managedObjectContext deleteObject:oldImage];
	}
	
    // Create an image object for the new image.
	NSManagedObject *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:recipe.managedObjectContext];
	recipe.image = image;

	// Set the image for the image managed object.
	[image setValue:selectedImage forKey:@"image"];
	
	// Create a thumbnail version of the image for the recipe object.
	CGSize size = selectedImage.size;
	CGFloat ratio = 0;
	if (size.width > size.height) {
		ratio = 44.0 / size.width;
	} else {
		ratio = 44.0 / size.height;
	}
	CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
	
	UIGraphicsBeginImageContext(rect.size);
	[selectedImage drawInRect:rect];
	recipe.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    [self dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)updatePhotoButton {
	/*
	 How to present the photo button depends on the editing state and whether the recipe has a thumbnail image.
	 * If the recipe has a thumbnail, set the button's highlighted state to the same as the editing state (it's highlighted if editing).
	 * If the recipe doesn't have a thumbnail, then: if editing, enable the button and show an image that says "Choose Photo" or similar; if not editing then disable the button and show nothing.  
	 */
	BOOL editing = self.editing;
	
	if (recipe.thumbnailImage != nil) {
		photoButton.highlighted = editing;
	} else {
		photoButton.enabled = editing;
		
		if (editing) {
			[photoButton setImage:[UIImage imageNamed:@"choosePhoto.png"] forState:UIControlStateNormal];
		} else {
			[photoButton setImage:nil forState:UIControlStateNormal];
		}
	}
}


#pragma mark -
#pragma mark dealloc

- (void)dealloc {
    [tableHeaderView release];
    [photoButton release];
    [nameTextField release];
    [overviewTextField release];
    [prepTimeTextField release];
    [recipe release];
    [ingredients release];
    [super dealloc];
}


@end

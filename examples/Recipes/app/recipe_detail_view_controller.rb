class RecipeDetailViewController < UITableViewController
  TYPE_SECTION         = 0
  INGREDIENTS_SECTION  = 1
  INSTRUCTIONS_SECTION = 2

  attr_accessor :recipe, :ingredients, :tableHeaderView, :photoButton,
                :nameTextField, :overviewTextField, :prepTimeTextField

  def viewDidLoad
    navigationItem.rightBarButtonItem = editButtonItem

    unless @tableHeaderView
      NSBundle.mainBundle.loadNibNamed('DetailHeaderView', owner:self, options:nil)
      tableView.tableHeaderView = @tableHeaderView
      tableView.allowsSelectionDuringEditing = true
    end
  end

  def viewWillAppear(animated)
    super

    #@photoButton.setImage(recipe.thumbnailImage, forState:UIControlStateNormal)
    @photoButton.setImage(@recipe.image, forState:UIControlStateNormal)
    navigationItem.title = @nameTextField.text = @recipe.name
    overviewTextField.text = @recipe.overview
    prepTimeTextField.text = @recipe.prepTime
    updatePhotoButton

    # Create a mutable array that contains the recipe's ingredients ordered by displayOrder.
    # The table view uses this array to display the ingredients.
    #
    # Core Data relationships are represented by sets, so have no inherent order. Order is "imposed"
    # using the displayOrder attribute, but it would be inefficient to create and sort a new array
    # each time the ingredients section had to be laid out or updated.
    sortDescriptor = NSSortDescriptor.alloc.initWithKey('displayOrder', ascending:true)
    @ingredients   = recipe.ingredients.allObjects.sortedArrayUsingDescriptors([sortDescriptor])

    tableView.reloadData
  end

  def viewDidUnload
    @tableHeaderView = @photoButton = @nameTextField = @overviewTextField = @prepTimeTextField = nil
    super
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    orientation != UIInterfaceOrientationPortraitUpsideDown
  end

  def setEditing(editing, animated:animated)
    super

    updatePhotoButton
    @nameTextField.enabled = @overviewTextField.enabled = @prepTimeTextField.enabled = editing?
    navigationItem.setHidesBackButton(editing, animated:true)

    tableView.beginUpdates
    addIngredientIndexPath = [NSIndexPath.indexPathForRow(@recipe.ingredients.count, inSection:INGREDIENTS_SECTION)]
    if editing?
      tableView.insertRowsAtIndexPaths(addIngredientIndexPath, withRowAnimation:UITableViewRowAnimationTop)
      @overviewTextField.placeholder = 'Overview'
    else
      tableView.deleteRowsAtIndexPaths(addIngredientIndexPath, withRowAnimation:UITableViewRowAnimationTop)
      @overviewTextField.placeholder = ''
    end
    tableView.endUpdates

    unless editing?
      # TODO
      error = Pointer.new(:object)
      unless MotionData::Context.main.save(error)
        puts "Unresolved error: #{error[0].debugDescription}"
      end
    end
  end

  def textFieldShouldEndEditing(textField)
    case textField
    when @nameTextField
      @recipe.name = navigationItem.title = @nameTextField.text
    when @overviewTextField
      @recipe.overview = @overviewTextField.text
    when @prepTimeTextField
      @recipe.prepTime = @prepTimeTextField.text
    end
    true
  end

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    true
  end

  # UITableView delegate/data source

  def numberOfSectionsInTableView(tableView)
    4
  end

  def tableView(tableView, titleForHeaderInSection:section)
    case section
    when TYPE_SECTION        then 'Category'
    when INGREDIENTS_SECTION then 'Ingredients'
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
    when TYPE_SECTION, INSTRUCTIONS_SECTION
      1
    when INGREDIENTS_SECTION
      rows = @recipe.ingredients.count
      editing? ? rows + 1 : rows
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = nil
    if indexPath.section == INGREDIENTS_SECTION
      if indexPath.row < @recipe.ingredients.count
        unless cell = tableView.dequeueReusableCellWithIdentifier('IngredientsCell')
          cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'IngredientsCell')
          cell.accessoryType = UITableViewCellAccessoryNone
        end
        ingredient = @ingredients[indexPath.row]
        cell.textLabel.text = ingredient.name
        cell.detailTextLabel.text = ingredient.amount

      else
        unless cell = tableView.dequeueReusableCellWithIdentifier('AddIngredientCell')
          cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'AddIngredientCell')
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        end
        cell.textLabel.text = 'Add Ingredient'
      end

    else
      unless cell = tableView.dequeueReusableCellWithIdentifier('GenericCell')
        cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'GenericCell')
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end
      cell.textLabel.text = case indexPath.section
                            when TYPE_SECTION
                              cell.accessoryType = UITableViewCellAccessoryNone
                              cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator
                              @recipe.type.name
                            when INSTRUCTIONS_SECTION
                              cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
                              cell.editingAccessoryType = UITableViewCellAccessoryNone
                              'Instructions'
                            end
    end
    cell
  end

  # Editing rows

  def tableView(tableView, willSelectRowAtIndexPath:indexPath)
    # * If editing, don't allow instructions to be selected
    # * Not editing: Only allow instructions to be selected
    if (editing? && indexPath.section == INSTRUCTIONS_SECTION) || (!editing? && section != INSTRUCTIONS_SECTION)
      tableView.deselectRowAtIndexPath(indexPath, animated:true)
      nil
    else
      indexPath
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    controller = nil
    case indexPath.section
    when TYPE_SECTION
      controller = TypeSelectionViewController.alloc.initWithStyle(UITableViewStyleGrouped)
    when INSTRUCTIONS_SECTION
      controller = InstructionsViewController.alloc.initWithNibName('InstructionsView', bundle:nil)
    when INGREDIENTS_SECTION
      controller = IngredientDetailViewController.alloc.initWithStyle(UITableViewStyleGrouped)
      controller.ingredient = @ingredients[indexPath.row] if indexPath.row < recipe.ingredients.count
    end
    if controller
      controller.recipe = @recipe
      navigationController.pushViewController(controller, animated:true)
    end
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    if editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == INGREDIENTS_SECTION
      ingredient = @ingredients.delete_at(indexPath.row)
      recipe.removeIngredientsObject(ingredient)
      # TODO
      #ingredient.delete
      MotionData::Context.main.deleteObject(ingredient)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationTop)
    end
  end

  # Moving rows

  def tableView(tableView, canMoveRowAtIndexPath:indexPath)
    # Moves are only allowed within the ingredients section.  Within the
    # ingredients section, the last row (Add Ingredient) cannot be moved.
    indexPath.section == INGREDIENTS_SECTION && indexPath.row != @recipe.ingredients.count
  end

  def tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath, toProposedIndexPath:destinationIndexPath)
    # Moves are only allowed within the ingredients section, so make sure the
    # destination is in the ingredients section.  If the destination is in the
    # ingredients section, make sure that it's not the Add Ingredient row -- if
    # it is, retarget for the penultimate row.
    if destinationIndexPath.section < INGREDIENTS_SECTION
      NSIndexPath.indexPathForRow(0, inSection:INGREDIENTS_SECTION)
    elsif destinationIndexPath.section > INGREDIENTS_SECTION
      NSIndexPath.indexPathForRow(@recipe.ingredients.count - 1, inSection:INGREDIENTS_SECTION)
    elsif destinationIndexPath.row > (@recipe.ingredients.count - 1)
      NSIndexPath.indexPathForRow(@recipe.ingredients.count - 1, inSection:INGREDIENTS_SECTION)
    else
      destinationIndexPath
    end
  end

  def tableView(tableView, moveRowAtIndexPath:fromIndexPath, toIndexPath:toIndexPath)
    # Update the ingredients array in response to the move.
    # Update the display order indexes within the range of the move.
    ingredient = @ingredients.delete_at(fromIndexPath.row)
    @ingredients.insertObject(ingredient, atIndex:toIndexPath.row)

    startRow = fromIndexPath.row
    startRow = toIndexPath.row if toIndexPath.row < startRow
    endRow   = toIndexPath.row
    endRow   = fromIndexPath.row if fromIndexPath.row > endRow

    startRow.upto(endRow) { |row| @ingredients[row].displayOrder = row }
  end

  # Photo

  def photoTapped
    if editing?
      controller = UIImagePickerController.new
      controller.delegate = self
      presentModalViewController(controller, animated:true)
    else
      controller = RecipePhotoViewController.new
      controller.hidesBottomBarWhenPushed = true
      controller.recipe = @recipe
      navigationController.pushViewController(controller, animated:true)
    end
  end

  # TODO move generating thumbnail to model so this works as well when
  # generating seeds.
  def imagePickerController(controller, didFinishPickingImage:selectedImage, editingInfo:info)
    #@recipe.image.delete if @recipe.image
    MotionData::Context.main.deleteObject(@recipe.image) if @recipe.image

    # TODO this should also use the @recipe's context, instead of the current/main.
    #image = @recipe.newImage({})
    image = Image.new(:image => selectedImage)
    @recipe.image = image

    size  = selectedImage.size
    ratio = size.width > size.height ? 44.0 / size.width : 44.0 / size.height
    rect  = CGRectMake(0, 0, ratio * size.width, ratio * size.height)

    UIGraphicsBeginImageContext(rect.size)
    selectedImage.drawInRect(rect)
    @recipe.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    dismissModalViewControllerAnimated(true)
  end

  def imagePickerControllerDidCancel(controller)
    dismissModalViewControllerAnimated(true)
  end

  # How to present the photo button depends on the editing state and whether
  # the recipe has a thumbnail image.
  # * If the recipe has a thumbnail, set the button's highlighted state to the
  #   same as the editing state (it's highlighted if editing).
  # * If the recipe doesn't have a thumbnail, then: if editing, enable the
  #   button and show an image that says "Choose Photo" or similar; if not
  #   editing then disable the button and show nothing.
  def updatePhotoButton
    if @recipe.thumbnailImage
      @photoButton.highlighted = editing?
    elsif @photoButton.enabled = editing?
      @photoButton.setImage(UIImage.imageNamed('choosePhoto.png'), forState:UIControlStateNormal)
    else
      @photoButton.setImage(nil, forState:UIControlStateNormal)
    end
  end
end

class NSIndexPath
  def self.[](section, row)
    indexPathForRow(row, inSection:section)
  end
end

class IngredientDetailViewController < UITableViewController
  attr_accessor :recipe, :ingredient, :editingTableViewCell

  def initWithStyle(style)
    if super
      navigationItem.title = 'Ingredient'
      navigationItem.leftBarButtonItem  = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel,
                                                                                     target:self,
                                                                                     action:'cancel:')
      navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemSave,
                                                                                     target:self,
                                                                                     action:'save:')
    end
    self
  end

  def viewDidLoad
    super
    tableView.allowsSelection = tableView.allowsSelectionDuringEditing = false
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    orientation != UIInterfaceOrientationPortraitUpsideDown
  end

  # UITableView data source

  def tableView(tableView, numberOfRowsInSection:section)
    2
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    unless cell = tableView.dequeueReusableCellWithIdentifier('IngredientsCell')
      NSBundle.mainBundle.loadNibNamed('EditingTableViewCell', owner:self, options:nil)
      cell, @editingTableViewCell = @editingTableViewCell, nil
    end
    case indexPath.row
    when 0
      cell.label.text = 'Ingredient'
      cell.textField.text = @ingredient.name if @ingredient
      cell.textField.placeholder = 'Name'
    when 1
      cell.label.text = cell.textField.placeholder = 'Amount'
      cell.textField.text = @ingredient.amount if @ingredient
    end
    cell
  end

  # Save and cancel

  def save(sender)
    unless @ingredient
      # TODO
      #@ingredient = @recipe.ingredients.new
      @ingredient = Ingredient.new(:displayOrder => @recipe.ingredients.count)
      @recipe.addIngredientsObject(@ingredient)
    end

    @ingredient.name   = tableView.cellForRowAtIndexPath(NSIndexPath[0, 0]).textField.text
    @ingredient.amount = tableView.cellForRowAtIndexPath(NSIndexPath[0, 1]).textField.text

    # TODO
    error = Pointer.new(:object)
    unless MotionData::Context.main.save(error)
      raise "Unresolved error: #{error[0].debugDescription}"
    end

    navigationController.popViewControllerAnimated(true)
  end

  def cancel(sender)
    navigationController.popViewControllerAnimated(true)
  end
end

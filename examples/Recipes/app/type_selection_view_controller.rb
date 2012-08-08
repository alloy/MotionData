class TypeSelectionViewController < UITableViewController
  attr_accessor :recipe, :recipeTypes

  def viewWillAppear(animated)
    super

    # TODO
    request = NSFetchRequest.new
    request.entity = RecipeType.entityDescription
    request.sortDescriptors = [NSSortDescriptor.alloc.initWithKey('name', ascending:true)]
    error = Pointer.new(:object)
    @recipeTypes = MotionData::Context.main.executeFetchRequest(request, error:error)
    raise "Unresolved error: #{error[0].debugDescription}" if error[0]
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    orientation != UIInterfaceOrientationPortraitUpsideDown
  end

  # UITableView delegate/data source

  def tableView(tableView, numberOfRowsInSection:section)
    @recipeTypes.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    unless cell = tableView.dequeueReusableCellWithIdentifier('RecipeTypeCell')
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'RecipeTypeCell')
    end
    type = @recipeTypes[indexPath.row]
    cell.textLabel.text = type.name
    cell.accessoryType = UITableViewCellAccessoryCheckmark if type == @recipe.type
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if @recipe.type
      previousIndexPath = NSIndexPath.indexPathForRow(@recipeTypes.index(@recipe.type), inSection:0)
      cell = tableView.cellForRowAtIndexPath(previousIndexPath)
      cell.accessoryType = UITableViewCellAccessoryNone
    end
    tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
    @recipe.type = @recipeTypes[indexPath.row]
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end
end

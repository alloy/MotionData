class RecipeListTableViewController < UITableViewController
  def viewDidLoad
    self.title = 'Recipes'
    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd,
                                                                                   target:self,
                                                                                   action:'add:')
    tableView.rowHeight = 44

    error = Pointer.new(:object)
    unless fetchedResultsController.performFetch(error)
      puts "Error occured during fetch: #{error.localizedDescription}"
    end
  end

  def add(sender)
    
  end

  def recipeAddViewController(controller, didAddRecipe:recipe)
    
  end

  def showRecipe(recipe, animated:animated)
    controller = RecipeDetailViewController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.recipe = recipe
    navigationController.pushViewController(controller, animated:animated)
  end

  def fetchedResultsController
    @fetchedResultsController ||= begin
      request = NSFetchRequest.new
      request.entity = Recipe.entityDescription
      request.sortDescriptors = [NSSortDescriptor.alloc.initWithKey('name', ascending:true)]

      controller = NSFetchedResultsController.alloc.initWithFetchRequest(request,
                                                    managedObjectContext:MotionData::Context.current,
                                                      sectionNameKeyPath:nil,
                                                               cacheName:'Root')
      controller.delegate = self
      controller
    end
  end

  def numberOfSectionsInTableView(tableView)
    count = fetchedResultsController.sections.count
    count == 0 ? 1 : count
  end

  def tableView(tableView, numberOfRowsInSection:index)
    if section = fetchedResultsController.sections[index]
      section.numberOfObjects
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    unless recipeCell = tableView.dequeueReusableCellWithIdentifier('RecipeCellIdentifier')
      recipeCell = RecipeTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'RecipeCellIdentifier')
      recipeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end
    recipeCell.recipe = fetchedResultsController.objectAtIndexPath(indexPath)
    recipeCell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    showRecipe(fetchedResultsController.objectAtIndexPath(indexPath), animated:true)
  end
end

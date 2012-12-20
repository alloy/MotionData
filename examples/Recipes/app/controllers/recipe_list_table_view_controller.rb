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
    controller = RecipeAddViewController.alloc.initWithNibName('RecipeAddView', bundle:nil)
    controller.delegate = self
    # TODO do in new context?
    controller.recipe = Recipe.new

    navigationController = UINavigationController.alloc.initWithRootViewController(controller)
    presentModalViewController(navigationController, animated:true)
  end

  def recipeAddViewController(controller, didAddRecipe:recipe)
    showRecipe(recipe, animated:false) if recipe
    dismissModalViewControllerAnimated(true)
  end

  def showRecipe(recipe, animated:animated)
    controller = RecipeDetailViewController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.recipe = recipe
    navigationController.pushViewController(controller, animated:animated)
  end

  def fetchedResultsController
    # TODO
    # @fetchedResultsController ||= Recipe.all.sortBy(:name, ascending:true).resultsController('Root').tap { |c| c.delegate = self }
    # @fetchedResultsController ||= Recipe.all.sortBy(:name).resultsController('Root').tap { |c| c.delegate = self }
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

  def controllerWillChangeContent(controller)
    self.tableView.beginUpdates
  end

  def controller(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forchangeType: type)
    case type
    when NSFetchedResultsChangeInsert
      then self.tableView.insertSections(NSIndexSet.indexSetWithIndex(sectionIndex), withRowAnimation:UITableViewRowAnimationFade)
    when NSFetchedResultsChangeDelete
      then self.tableView.deleteSections(NSIndexSet.indexSetWithIndex(sectionIndex), withRowAnimation:UITableViewRowAnimationFade)
    end
  end

  def controller(controller, didChangeObject:anObject, atIndexPath:indexPath, forChangeType:type, newIndexPath:newIndexPath)
    tableView = self.tableView
    case type
    when NSFetchedResultsChangeInsert
      then tableView.insertRowsAtIndexPaths(NSArray.arrayWithObject(newIndexPath),
                                            withRowAnimation:UITableViewRowAnimationFade)
    when NSFetchedResultsChangeDelete
      then tableView.deleteRowsAtIndexPaths(NSArray.arrayWithObject(indexPath),
                                            withRowAnimation:UITableViewRowAnimationFade)
      #TODO case for NSFetchedResultsChangeUpdate is complaining that self does not have configureCell:atIndexPath method.
      #cannot figure out how to call it appropriately. leaving commented it out for now.
      #http://developer.apple.com/library/ios/#documentation/CoreData/Reference/NSFetchedResultsControllerDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/NSFetchedResultsControllerDelegate/controllerWillChangeContent:
      #when NSFetchedResultsChangeUpdate
      # then self.configureCell(tableView.cellForRowAtIndexPath(indexPath),
      #                        atIndexPath:indexPath)
    when NSFetchedResultsChangeMove
      then
      tableView.deleteRowsAtIndexPaths(NSArray.arrayWithObject(indexPath),
                                       withRowAnimation:UITableViewRowAnimationFade)
      tableView.insertRowsAtIndexPaths(NSArray.arrayWithObject(newIndexPath),
                                       withRowAnimation:UITableViewRowAnimationFade)
    end
  end

  def controllerDidChangeContent(controller)
    self.tableView.endUpdates
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

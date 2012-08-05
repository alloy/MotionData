class RecipeListTableViewController < UITableViewController
  def viewDidLoad
    self.title = 'Recipes'
    self.navigationItem.leftBarButtonItem = editButtonItem
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd,
                                                                                        target:self,
                                                                                        action:'add:')
    self.tableView.rowHeight = 44

    error = Pointer.new(:object)
    unless fetchedResultsController.performFetch(error)
      puts "Error occured during fetch: #{error.localizedDescription}"
    end

    p fetchedResultsController.fetchedObjects
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
      recipeCell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'RecipeCellIdentifier')
      recipeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end
    recipeCell.textLabel.text = fetchedResultsController.objectAtIndexPath(indexPath).name
    recipeCell
  end
end

class UnitConverterTableViewController < UIViewController
end

class AppDelegate
  attr_accessor :window, :tabBarController, :recipeListController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    setupCoreDataStack

    recipe = Recipe.new(:name => 'Fries')
    p recipe
    p recipe.ingredients
    p recipe.image
    p recipe.type

    #p Recipe.all

    nib = UINib.nibWithNibName('MainWindow', bundle:nil)
    nib.instantiateWithOwner(application, options:{ UINibExternalObjects => { 'AppDelegate' => self }})

    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible

    true
  end

  def setupCoreDataStack
    storePath = File.join(applicationDocumentsDirectory, 'Recipes.sqlite')
    #unless File.exist?(storePath)
      #defaultStorePath = NSBundle.mainBundle.pathForResource('RecipeData/Recipes', ofType:'sqlite')
      #NSFileManager.defaultManager.copyItemAtPath(defaultStorePath, toPath:storePath, error:nil)
    #end
    MotionData.setupCoreDataStackWithSQLiteStore(storePath)
    #p MotionData::StoreCoordinator.default.persistentStores.first.metadata
  end

  def applicationDocumentsDirectory
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).last
  end
end

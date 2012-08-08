class UnitConverterTableViewController < UIViewController
end

class AppDelegate
  attr_accessor :window, :tabBarController, :recipeListController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    setupCoreDataStack

    loadSeeds
    #p Recipe.all

    nib = UINib.nibWithNibName('MainWindow', bundle:nil)
    nib.instantiateWithOwner(application, options:{ UINibExternalObjects => { 'AppDelegate' => self }})

    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible

    true
  end

  def loadSeeds
    recipe = Recipe.new(
      :name         => 'Fries',
      :prepTime     => '40 minutes',
      :overview     => 'French fries (American English, with "French" often capitalized), ' \
                       'or chips, fries, or French-fried potatoes are batons of deep-fried potato.',
      :instructions => <<-EOS
Rinse cut potatoes in a large bowl with lots of cold running water until water becomes clear. Cover with water by 1-inch and cover with ice. Refrigerate at least 30 minutes and up to 2 days.

In a 5-quart pot or Dutch oven fitted with a candy or deep-frying thermometer, (or in an electric deep fryer), heat oil over medium-low heat until the thermometer registers 325 degrees F. Make sure that you have at least 3 inches of space between the top of the oil and the top of the pan, as fries will bubble up when they are added.

Drain ice water from cut fries and wrap potato pieces in a clean dishcloth or tea towel and thoroughly pat dry. Increase the heat to medium-high and add fries, a handful at a time, to the hot oil. Fry, stirring occasionally, until potatoes are soft and limp and begin to turn a blond color, about 6 to 8 minutes. Using a skimmer or a slotted spoon, carefully remove fries from the oil and set aside to drain on paper towels. Let rest for at least 10 minutes or up to 2 hours.

When ready to serve the French fries, reheat the oil to 350 degrees F. Transfer the blanched potatoes to the hot oil and fry again, stirring frequently, until golden brown and puffed, about 1 minute. Transfer to paper lined platter and sprinkle with salt and pepper, to taste. Serve immediately.
EOS
    )
    recipe.type = RecipeType.new(:name => 'Fast-food')
    recipe.image = Image.new(:image => UIImage.imageNamed('fries.jpg'))
  end

  def setupCoreDataStack
    storePath = File.join(applicationDocumentsDirectory, 'Recipes.sqlite')
    #unless File.exist?(storePath)
      #loadSeeds
      #defaultStorePath = NSBundle.mainBundle.pathForResource('RecipeData/Recipes', ofType:'sqlite')
      #NSFileManager.defaultManager.copyItemAtPath(defaultStorePath, toPath:storePath, error:nil)
    #end
    MotionData.setupCoreDataStackWithSQLiteStore(storePath)
  end

  def applicationDocumentsDirectory
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).last
  end
end

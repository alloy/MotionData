class RecipeListTableViewController < UIViewController
end

class UnitConverterTableViewController < UIViewController
end

class AppDelegate
  attr_accessor :window, :tabBarController, :recipeListController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    nib = UINib.nibWithNibName('MainWindow', bundle:nil)
    nib.instantiateWithOwner(application, options:{ UINibExternalObjects => { 'AppDelegate' => self }})

    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible

    true
  end
end

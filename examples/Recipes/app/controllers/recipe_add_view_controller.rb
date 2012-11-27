class RecipeAddViewController < UIViewController
  attr_accessor :recipe, :nameTextField, :delegate

  def viewDidLoad
    self.title = 'Add Recipe'

    self.navigationItem.leftBarButtonItem  = UIBarButtonItem.alloc.initWithTitle('Cancel',
                                                                           style:UIBarButtonItemStyleBordered,
                                                                          target:self,
                                                                          action:'cancel')
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle('Save',
                                                                           style:UIBarButtonItemStyleDone,
                                                                          target:self,
                                                                          action:'save')

    @nameTextField.becomeFirstResponder
  end

  def viewDidUnload
    @nameTextField = nil
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    orientation != UIInterfaceOrientationPortraitUpsideDown
  end

  def textFieldShouldReturn(textField)
    if textField == @nameTextField
      @nameTextField.resignFirstResponder
      save
    end
    true
  end

  def save
    @recipe.name = @nameTextField.text
    #At Context.main.saveChanges, this will make the changes get "bubbled up" to the parent context.
    #However, the *parent context hasn't persisted them to disk* yet.
    MotionData::Context.main.saveChanges
    #You have to save the top parent context, Context.root, to actually persist the changes
    #See https://github.com/alloy/MotionData/issues/8
    MotionData::Context.root.saveChanges
    @delegate.recipeAddViewController(self, didAddRecipe:@recipe)
    #TODO once saved, it does not update RecipeListTableViewController
  end

  def cancel
    # TODO
    # @recipe.delete
    MotionData::Context.main.deleteObject(@recipe)
    # TODO
    MotionData::Context.main.saveChanges
    MotionData::Context.root.saveChanges
    @delegate.recipeAddViewController(self, didAddRecipe:nil)
  end
end

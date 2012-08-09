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
    # TODO
    error = Pointer.new(:object)
    unless MotionData::Context.main.save(error)
      raise "Unresolved error #{error[0].debugDescription}"
    end
    @delegate.recipeAddViewController(self, didAddRecipe:@recipe)
  end

  def cancel
    # TODO
    # @recipe.delete
    MotionData::Context.main.deleteObject(@recipe)
    # TODO
    error = Pointer.new(:object)
    unless MotionData::Context.main.save(error)
      raise "Unresolved error #{error[0].debugDescription}"
    end
    @delegate.recipeAddViewController(self, didAddRecipe:nil)
  end
end

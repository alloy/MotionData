class RecipeTableViewCell < UITableViewCell
  attr_accessor :recipe, :imageView, :nameLabel, :overviewLabel, :prepTimeLabel

  def initWithStyle(style, reuseIdentifier:identifier)
    if super
      @imageView = UIImageView.alloc.initWithFrame(CGRectZero)
      @imageView.contentMode = UIViewContentModeScaleAspectFit
      contentView.addSubview(@imageView)

      @overviewLabel = UILabel.alloc.initWithFrame(CGRectZero)
      @overviewLabel.font = UIFont.systemFontOfSize(12)
      @overviewLabel.textColor = UIColor.darkGrayColor
      @overviewLabel.highlightedTextColor = UIColor.whiteColor
      contentView.addSubview(@overviewLabel)

      @prepTimeLabel = UILabel.alloc.initWithFrame(CGRectZero)
      @prepTimeLabel.textAlignment = UITextAlignmentRight
      @prepTimeLabel.font = UIFont.systemFontOfSize(12)
      @prepTimeLabel.textColor = UIColor.blackColor
      @prepTimeLabel.highlightedTextColor = UIColor.whiteColor
      @prepTimeLabel.minimumFontSize = 7
      @prepTimeLabel.lineBreakMode = UILineBreakModeTailTruncation
      contentView.addSubview(@prepTimeLabel)

      @nameLabel = UILabel.alloc.initWithFrame(CGRectZero)
      @nameLabel.font = UIFont.boldSystemFontOfSize(14)
      @nameLabel.textColor = UIColor.blackColor
      @nameLabel.highlightedTextColor = UIColor.whiteColor
      contentView.addSubview(@nameLabel)
    end
    self
  end

  def layoutSubviews
    super
    @imageView.frame = imageViewFrame
    @nameLabel.frame = nameLabelFrame
    @overviewLabel.frame = overviewLabelFrame
    @prepTimeLabel.frame = prepTimeLabelFrame
    @prepTimeLabel.alpha = editing? ? 0 : 1
  end

  IMAGE_SIZE        = 42
  EDITING_INSET     = 10
  TEXT_LEFT_MARGIN  = 8
  TEXT_RIGHT_MARGIN = 5
  PREP_TIME_WIDTH   = 80

  def imageViewFrame
    CGRectMake(editing? ? EDITING_INSET : 0, 0, IMAGE_SIZE, IMAGE_SIZE)
  end

  def nameLabelFrame
    if editing?
      CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 4, contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16)
    else
      CGRectMake(IMAGE_SIZE + TEXT_RIGHT_MARGIN, 4, contentView.bounds.size.width - IMAGE_SIZE - TEXT_RIGHT_MARGIN * 2 - PREP_TIME_WIDTH, 16)
    end
  end

  def overviewLabelFrame
    if editing?
      CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 22, contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16)
    else
      CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 22, contentView.bounds.size.width - IMAGE_SIZE - TEXT_LEFT_MARGIN, 16)
    end
  end

  def prepTimeLabelFrame
    CGRectMake(contentView.bounds.size.width - PREP_TIME_WIDTH - TEXT_RIGHT_MARGIN, 4, PREP_TIME_WIDTH, 16)
  end

  def recipe=(recipe)
    @recipe = recipe
    @imageView.image = recipe.thumbnailImage
    @nameLabel.text = recipe.name
    @overviewLabel.text = recipe.overview
    @prepTimeLabel.text = recipe.prepTime
  end
end

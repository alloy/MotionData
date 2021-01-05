class ImageToDataTransformer < NSValueTransformer
  def self.allowsReverseTransformation
    true
  end

  def self.transformedValueClass
    NSData
  end

  def transformedValue(value)
    UIImagePNGRepresentation(value)
  end

  def reverseTransformedValue(value)
    UIImage.alloc.initWithData(value)
  end
end

# TODO Curretly these have to be defined first, so that there entityDescription
# can be used while defining associations. This should not be needed.
class Image < MotionData::ManagedObject
end

class Ingredient < MotionData::ManagedObject
end

class RecipeType < MotionData::ManagedObject
end

class Recipe < MotionData::ManagedObject
end

class Image < MotionData::ManagedObject
  property :image, Transformable, :transformer => ImageToDataTransformer

  hasOne :recipe, :destinationEntity => Recipe.entityDescription, :inverse => :image
end

class Ingredient < MotionData::ManagedObject
  property :amount,       String
  property :name,         String
  property :displayOrder, Integer16

  hasOne :recipe, :destinationEntity => Recipe.entityDescription, :inverse => :ingredients
end

class RecipeType < MotionData::ManagedObject
  property :name,         String

  hasMany :recipes, :destinationEntity => Recipe.entityDescription, :inverse => :type
end

class Recipe < MotionData::ManagedObject
  property :instructions,   String
  property :name,           String
  property :overview,       String
  property :prepTime,       String
  property :thumbnailImage, Transformable, :transformer => ImageToDataTransformer

  hasMany :ingredients, :destinationEntity => Ingredient.entityDescription, :inverse => :recipe
  hasOne :image, :destinationEntity => Image.entityDescription, :inverse => :recipe
  hasOne :type, :destinationEntity => RecipeType.entityDescription, :inverse => :recipes

  def image=(imageEntity)
    writeAttribute(:image, imageEntity)

    image = imageEntity.image
    size  = image.size
    ratio = size.width > size.height ? 44.0 / size.width : 44.0 / size.height
    rect  = CGRectMake(0, 0, ratio * size.width, ratio * size.height)

    UIGraphicsBeginImageContext(rect.size)
    image.drawInRect(rect)
    self.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  end
end

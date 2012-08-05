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

  hasOne :recipe, :destinationEntity => Recipe.entityDescription, :inverse => :image #, :inverseRelationship => Recipe.entityDescription.relationshipsByName['image']
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
end

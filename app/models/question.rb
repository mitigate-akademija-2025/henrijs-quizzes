class Question < ApplicationRecord
  belongs_to :quiz
  has_many :guesses, dependent: :destroy
  has_many :options, dependent: :destroy

  validates :content, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }

  has_one_attached :image
  attr_accessor :remove_image

  def changed_for_autosave?
    super || ActiveModel::Type::Boolean.new.cast(remove_image)
  end

  before_save :purge_image_if_requested
  validate :image_constraints

  accepts_nested_attributes_for :options, allow_destroy: true

  def self.build_for(kind)
    klass = kind.to_s == "TextQuestion" ? TextQuestion : ChoiceQuestion

    klass.new(points: 1).tap do |q|
      if klass == ChoiceQuestion
        q.max_selections ||= 1
        2.times { q.options.build(correct: false) }
      else
        q.max_selections = nil
        q.options.build(correct: true)
      end
    end
  end

  private

  def purge_image_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(remove_image)
    image.purge_later if image.attached?
  end

  def image_constraints
    return unless image.attached?
    if image.byte_size > 5.megabytes
      errors.add(:image, "is too large (max 5MB)")
    end
    acceptable = %w[image/jpeg image/png image/webp]
    errors.add(:image, "must be JPEG/PNG/WEBP") unless acceptable.include?(image.content_type)
  end
end

class Question < ApplicationRecord
  belongs_to :quiz
  has_many :guesses, dependent: :destroy
  has_many :options, dependent: :destroy

  validates :content, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }

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
end

class ChoiceQuestion < Question
  validates :max_selections, numericality: { only_integer: true, greater_than: 0 }
end
class TextQuestion < Question
  validates :max_selections, absence: true
end

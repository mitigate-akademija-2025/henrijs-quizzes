class ChoiceQuestion < Question
  validates :max_selections, numericality: { only_integer: true, greater_than: 0 }

  before_validation :sync_max_selections

  private
  def sync_max_selections
    self.max_selections = options.count { |o| o.correct? && !o.marked_for_destruction? }
  end
end

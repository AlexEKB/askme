class Hashtag < ApplicationRecord

  belongs_to :question

  validates :question, presence: true

  before_save :downcase_name

  private
  def downcase_name
    self.name = name.mb_chars.downcase
  end

end

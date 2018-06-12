class Question < ApplicationRecord

  belongs_to :user

  has_many :hashtags, dependent: :destroy

  # макс длина вопроса 255
  validates :text, :user, length: {maximum: 255}, presence: true

  before_save :update_hashtags

  private
  def update_hashtags
    transaction do
      hashtags.destroy_all

      text.scan(/(?:^|\s)#([[:word:]]+)/).flatten.each do |tag_name|
        hashtags.build(name: tag_name)
      end
    end
  end
end

# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  long_url   :string(255)
#  short_url  :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'securerandom'

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :uniqueness => true, :presence => true

  def self.random_code
    new_url = nil
    while self.exists?(:short_url => new_url) || new_url.nil?
      new_url = SecureRandom::urlsafe_base64
    end
    new_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    short_url = self.random_code

    ShortenedUrl.create!(:long_url => long_url, :short_url => short_url, :user_id => user.id)
  end

  belongs_to(
    :submitter,
    :class_name => 'User',
    :foreign_key => 'user_id',
    :primary_key => 'id'
  )

end

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

  has_many(
    :visits,
    :class_name => 'Visit',
    :foreign_key => :shortened_url_id,
    :primary_key => :id
    )

  has_many(
    :visited_users,
    :through => :visits,
    :source => :visitor
  )

  def num_clicks
    self.visits.count
  end

  def num_uniques
    self.visits.select(:user_id).distinct.count
  end

  def num_recent_uniques # test again at 3:20, should be 0
    visits = Visit.where('updated_at >= ?', 10.minutes.ago)
    unique_visits = visits.select(:user_id).distinct.count
    unique_visits
  end

end

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
  validates_length_of :long_url, maximum: 1024
  validate :user_cannot_submit_over_5_in_1_min
  validate :premium_access

  def self.prune(n)
    prune_list = ShortenedUrl.where('updated_at < ?', n.minutes.ago)

    prune_list.each { |el| ShortenedUrl.destroy(el) }
  end

  belongs_to :submitter,
    :class_name => 'User',
    :foreign_key => 'user_id',
    :primary_key => 'id'

  has_many(
    :visits,
    :class_name => 'Visit',
    :foreign_key => :shortened_url_id,
    :primary_key => :id
    )

  has_many(
    :visited_users,
    Proc.new { distinct },
    :through => :visits,
    :source => :visitor
  )

  has_many(
    :taggings,
    :class_name => 'Tagging',
    :foreign_key => 'url_id',
    :primary_key => 'id'
  )

  has_many(
    :tags,
    :through => :taggings,
    :source => :tag
  )

  def self.random_code
    new_url = nil
    while self.exists?(:short_url => new_url) || new_url.nil?
      new_url = SecureRandom::urlsafe_base64
    end
    new_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    short_url = self.random_code

    ShortenedUrl.create!(
      :long_url => long_url,
      :short_url => short_url,
      :user_id => user.id
    )
  end

  def num_clicks
    self.visits.count
  end

  def num_uniques
    self.visited_users.count
  end

  def num_recent_uniques # test again at 3:20, should be 0
    visits = Visit.where('updated_at >= ?', 10.minutes.ago)
    unique_visits = visits.select(:user_id).distinct.count
    unique_visits
  end

  def user_cannot_submit_over_5_in_1_min
    visits = ShortenedUrl.where('updated_at >= ? and user_id = ?', 5.minutes.ago, submitter)
    errors[:email] << "can't create more than 5 urls!" if visits.count > 5
  end

  def premium_access
    unless submitter.premium
      errors[:premium] << "can't create more than 5 URLs for non-premium access" if submitter.submitted_urls.count > 5
    end
  end

end

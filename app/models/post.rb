# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  body       :text(65535)      not null
#  images     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Post < ApplicationRecord
  belongs_to :user
  mount_uploaders :images, PostImageUploader
  serialize :images, JSON

  validates :body, presence: true, length: { maximum: 1000 }
  validates :images, presence: true

  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  # 投稿にいいねしたユーザーをlikesテーブルを通して取得できるようにする。
  has_many :like_users, through: :likes, source: :user

  # 本文、コメント、ユーザー名に対する検索のスコープを定義
  scope :body_contain, ->(word) { where('posts.body LIKE ?', "%#{word}%") }
  # 投稿に関連付けたコメントやユーザー名を検索するのでテーブル同士を結合するjoinsメソッドを使う
  scope :comment_body_contain, ->(word) { joins(:comments).where('comments.body LIKE ?', "%#{word}%") }
  scope :username_contain, ->(word) { joins(:user).where('username LIKE ?', "%#{word)}%") }
end

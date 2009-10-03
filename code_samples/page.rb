class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  has_many :related_links
  has_many :external_links
  has_many :pdf_links

  accepts_nested_attributes_for :related_links, :allow_destroy => true
  accepts_nested_attributes_for :external_links, :allow_destroy => true
  accepts_nested_attributes_for :pdf_links, :allow_destroy => true

  # STI
  #set_inheritance_column :page_type

  validates_presence_of :user_id
  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :status

  before_validation :update_or_create_slug
  before_create :create_published_at

  acts_as_enum :status, [:draft, :reviewed, :published, :hidden]
  acts_as_voteable
  acts_as_taggable_on :tags

  default_scope :order => 'published_at desc'

  named_scope :published, :conditions => {:status => Page.status(:published)}

  named_scope :random, :order => 'RAND()'
  named_scope :recently_published, :order => 'published_at desc'
  named_scope :limit, lambda{|num|{:limit => num}}

  # Thinking Sphinx (search)
  define_index do
    # Fields
    indexes title
    indexes slug
    indexes meta_description
    indexes summary
    indexes body
    indexes implementation
    indexes author, :sortable => true
    indexes author_credentials
    indexes tags.name

    # Attributes
    has status, published_at, votes.vote
  end

  def self.find_related_topics(pages)
    rt = pages.collect{|p| p.topic}.uniq.compact[0...10]
  end

  def author_and_credentials
    author_credentials.blank? ? author : "#{author}, #{author_credentials}"
  end

  def not_blank_related_links
    not_blank_links(:related_links)
  end

  def not_blank_external_links
    not_blank_links(:external_links)
  end

  def not_blank_pdf_links
    not_blank_links(:pdf_links)
  end

  protected
    def not_blank_links(child)
      links = eval("self.#{child}")
      l = links.select do |rl|
        !rl.title.blank? || !rl.uri.blank?
      end
      l.blank? ? nil : l
    end

    def update_or_create_slug
      if self.new_record? || self.title_changed? || self.slug.blank?
        self.slug = self.title.try(:parameterize)
      elsif self.slug_changed?
        self.slug = self.slug.parameterize
      end
    end

    def create_published_at
      self.published_at = Time.now.utc
    end
end

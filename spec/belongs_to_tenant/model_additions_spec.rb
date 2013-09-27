require 'spec_helper'

# Setup the db
ActiveRecord::Schema.define(:version => 1) do
  create_table :organizations, :force => true do |t|
    t.string :name
  end

  create_table :articles, :force => true do |t|
    t.belongs_to :organization
  end

  create_table :users, :force => true do |t|
    t.belongs_to :organization
  end

  create_table :projects, :force => true do |t|
    t.belongs_to :organization
    t.belongs_to :user
  end

  create_table :comments, :force => true do |t|
    t.belongs_to :user
    t.belongs_to :organization
    t.belongs_to :commentable
    t.string :commentable_type
  end

  create_table :likes, :force => true do |t|
    t.belongs_to :user
    t.belongs_to :article
    t.belongs_to :organization
  end
end

# Setup the models
class Organization < ActiveRecord::Base
  has_many :users
  has_many :articles
  has_many :comments
  has_many :projects
end

class Article < ActiveRecord::Base
  extend BelongsToTenant::ModelAdditions
  has_many :comments, as: :commentable
  belongs_to_tenant :organization
end

class User < ActiveRecord::Base
  extend BelongsToTenant::ModelAdditions
  has_many :comments
  has_many :projects
  belongs_to_tenant :organization
end

class Project < ActiveRecord::Base
  extend BelongsToTenant::ModelAdditions
  belongs_to_tenant :organization
  belongs_to :user
end

class Comment < ActiveRecord::Base
  extend BelongsToTenant::ModelAdditions
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to_tenant :organization
end

class Like < ActiveRecord::Base
  extend BelongsToTenant::ModelAdditions
  belongs_to :user
  belongs_to :article
  belongs_to_tenant :organization, default_through: :user
end


describe BelongsToTenant::ModelAdditions do
  let(:organization) { Organization.create!(name: 'Primary') }
  let(:user) { organization.users.create! }
  let(:comment) { organization.comments.create! }
  let(:new_comment) { Comment.new }

  let(:other_organization) { Organization.create!(name: 'Other') }
  let(:other_user) { other_organization.users.create! }
  let(:other_article) { other_organization.articles.create! }

  it 'belongs to tenant' do
    expect(comment).to belong_to(:organization)
  end

  context 'when it is a new record' do
    it 'does not raise an error when setting tenant fk' do
      expect do
        new_comment.organization_id = other_organization.id
      end.not_to raise_error
    end

    it 'does not raise an error when setting tenant fk' do
      expect do
        new_comment.organization = other_organization
      end.not_to raise_error
    end
  end

  context 'when it is a persisted record' do
    it 'raises an error when attempt is made to change tenant fk' do
      expect do
        comment.organization_id = other_organization.id
      end.to raise_error(BelongsToTenant::TenantIsImmutable)
    end

    it 'raises an error when attempt is made to change tenant' do
      expect do
        comment.organization = other_organization
      end.to raise_error(BelongsToTenant::TenantIsImmutable)
    end
  end

  it 'is invalid if there is no tenant fk' do
    expect(new_comment).not_to be_valid
    new_comment.organization_id = organization.id
    expect(new_comment).to be_valid
  end

  it 'is invalid when we try to add a belongs_to that is owned by a different tenant' do
    expect(comment).to be_valid
    comment.user = other_user
    comment.save
    expect(comment.errors[:user]).to include('association must belong to the same tenant')
  end

  it 'still validates when belongs_to_tenant is called before a belongs_to macro' do
    project = organization.projects.create!
    expect(project).to be_valid
    project.user = other_user
    project.save
    expect(project.errors[:user]).to include('association must belong to the same tenant')
  end

  it 'is invalid when we try to add a polymorphic belongs_to that is owned by a different tenant' do
    expect(comment).to be_valid
    comment.commentable = other_article
    comment.save
    expect(comment.errors[:commentable]).to include('association must belong to the same tenant')
  end

  context 'when default_through option is given' do
    let(:article) { Article.create(organization: organization) }

    it 'automatically sets tenant association if one is not already set' do
      like = Like.create!({ user: user, article: article })
      expect(like.organization).to eq(organization)
    end

    it 'does not overwrite tenant association if one is already set' do
      expect do
        Like.create!({
          user: user,
          article: article,
          organization_id: other_organization.id
        })
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
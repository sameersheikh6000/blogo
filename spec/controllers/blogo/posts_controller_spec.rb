require 'spec_helper'

describe Blogo::PostsController do
  render_views

  describe '#index' do
    it 'assigns @meta' do
      get :index

      meta = assigns(:meta)
      expect(meta[:title]).to be_present
      expect(meta[:site_name]).to be_present
      expect(meta[:keywords]).to be_present
    end

    it 'assigns @tag if was in a route' do
      get :index, tag: 'poetry'
      expect(assigns(:tag)).to eq 'poetry'
    end

    it 'assigns @recent_posts' do
      post1 = FactoryBot.create(:post)
      post2 = FactoryBot.create(:post)
      post3 = FactoryBot.create(:post)
      allow(Blogo.config).to receive(:recent_posts).and_return(2)

      get :index
      expect(assigns(:recent_posts)).to eq [post3, post2]
    end

    it 'assigns @tags' do
      tag1 = FactoryBot.create(:tag, name: 'unu')
      tag2 = FactoryBot.create(:tag, name: 'du')

      get :index
      expect(assigns(:tags)).to match_array([tag1, tag2])
    end

    it 'assigns @paginator' do
      allow(Blogo.config).to receive(:posts_per_page).and_return(13)
      allow(Blogo.config).to receive(:paginator_size).and_return(11)

      get :index, page: 2

      paginator = assigns(:paginator)
      expect(paginator).to be_a Blogo::Paginator
      expect(paginator.per_page).to eq 13
      expect(paginator.size).to eq 11
      expect(paginator.page).to eq 2
    end
  end

  describe '#show' do
    before do
      @post = FactoryBot.create(:post)
      get :show, permalink: @post.permalink
    end

    it 'assigns @post' do
      expect(assigns(:post)).to eq @post
    end

    it 'assigns @meta' do
      keys = [:title, :description, :keywords, :url, :image, :type, :site_name]
      keys.each do |key|
        expect(assigns(:meta)).to have_key(key)
      end
    end

    it 'assigns @recent_posts' do
      expect(assigns(:recent_posts)).to be_present
    end

    it 'assigns @tags' do
      expect(assigns(:tags)).to be_present
    end
  end

  describe '#feed' do
    it 'renders atom feed' do
      FactoryBot.create(:post, title: 'How do you do?')
      FactoryBot.create(:post, title: 'Sleeping in hijacked car')

      get  :feed, format: 'atom'

      expect(response).to be_success
      expect(@response.content_type).to eq 'application/atom+xml'
      expect(@response.body).to include('How do you do?')
      expect(@response.body).to include('Sleeping in hijacked car')
    end
  end
end

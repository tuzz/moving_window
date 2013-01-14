require 'spec_helper'

describe MovingWindow do

  class User < ActiveRecord::Base
  end

  class Review < ActiveRecord::Base
    belongs_to :user

    scope :scope1, MovingWindow.scope { 6.months.ago }
    scope :scope2, MovingWindow.scope { [6.months.ago, 1.day.ago] }
    scope :scope3, MovingWindow.scope(:published_at) { [6.months.ago, 1.day.ago] }
    scope :scope4, MovingWindow.scope(:published_at) { [1.day.ago, 6.months.ago] }
    scope :scope5, MovingWindow.scope(:published_at) { [6.months.from_now, 1.day.ago] }

    scope :neg1, MovingWindow.scope { 6.months.ago }.not
    scope :neg2, MovingWindow.scope { [6.months.ago, 1.day.ago] }.not
    scope :neg3, MovingWindow.scope(:published_at) { [6.months.ago, 1.day.ago] }.not
    scope :neg4, MovingWindow.scope(:published_at) { [1.day.ago, 6.months.ago] }.not
    scope :neg5, MovingWindow.scope(:published_at) { [6.months.from_now, 1.day.ago] }.not

    scope :positive, w = MovingWindow.scope { 6.months.ago }
    scope :negative, w.not
  end

  before do
    @ancient = Review.create!(
      :created_at   => 20.months.ago,
      :published_at => 15.months.ago
    )

    @old = Review.create!(
      :created_at   => 9.months.ago,
      :published_at => 5.months.ago
    )

    @new = Review.create!(
      :created_at   => 1.month.ago,
      :published_at => 2.weeks.ago
    )

    @cutting_edge = Review.create!(
      :created_at   => 10.minutes.ago,
      :published_at => 30.seconds.ago
    )

    @future = Review.create!(
      :created_at   => 1.hours.from_now,
      :published_at => 3.hours.from_now
    )
  end

  after do
    Review.destroy_all
  end

  it 'filters the reviews accordingly' do
    Review.scope1.to_a.should               == [@new, @cutting_edge]
    Review.scope2.to_a.should               == [@new]
    Review.scope3.to_a.should               == [@old, @new]
    Review.scope4.to_a.should               == Review.scope3.to_a
    Review.scope5.to_a.should               == [@cutting_edge, @future]

    Review.scope1.scope3.to_a.should        == [@new]
    Review.scope1.scope5.to_a.should        == [@cutting_edge]
    Review.scope1.scope2.scope3.to_a.should == [@new]
    Review.scope3.scope5.to_a.should        == []

    Review.scope1.limit(1).to_a.should      == [@new]

    now = 6.months.ago
    Time.stub(:now).and_return(now)

    Review.scope1.should                    == [@old]
    Review.scope5.should                    == [@old, @new, @cutting_edge]
  end

  it 'supports negations' do
    Review.neg1.to_a.should == [@ancient, @old, @future]
    Review.neg2.to_a.should == [@ancient, @old, @cutting_edge, @future]
    Review.neg3.to_a.should == [@ancient, @cutting_edge, @future]
    Review.neg4.to_a.should == Review.neg3.to_a
    Review.neg5.to_a.should == [@ancient, @old, @new]

    Review.neg1.neg3.to_a.should      == [@ancient, @future]
    Review.neg1.neg5.to_a.should      == [@ancient, @old]
    Review.neg1.neg2.neg3.to_a.should == [@ancient, @future]
    Review.neg3.neg5.to_a.should      == [@ancient]
  end

  it 'supports manual invocation' do
    window1 = MovingWindow.new { [2.months.ago, 2.months.from_now] }
    window2 = MovingWindow.new { 45.seconds.ago }

    window1.filter(Review).to_a.should == [@new, @cutting_edge, @future]
    window2.filter(Review).to_a.should == []

    window2.filter(Review, :column => :published_at).to_a.should == [@cutting_edge]

    filtered = window1.filter(Review.limit(1))
    window2.filter(filtered, :column => :published_at).to_a.should == [@cutting_edge]

    window1.filter(Review, :negate => true).to_a.should == [@ancient, @old]
    window2.filter(Review, :negate => true).to_a.size.should == 5

    window2.filter(Review, :column => :published_at, :negate => true).to_a.
      should == [@ancient, @old, @new, @future]

    filtered = window1.filter(Review.limit(1))
    window2.filter(filtered, :column => :published_at, :negate => true).to_a.
      should == [@new]
  end

  it 'maintains purity when negating' do
    Review.positive.to_a.should_not == Review.negative.to_a

    Review.negative.to_sql.should     match /not/
    Review.positive.to_sql.should_not match /not/
  end

  it 'is explicit about table name when joining' do
    expect {
      Review.scope1.joins(:user).to_a
    }.to_not raise_error
  end

end

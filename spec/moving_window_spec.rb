require 'spec_helper'

describe MovingWindow do

  class Review < ActiveRecord::Base
    scope :scope1, MovingWindow.scope { 6.months.ago }
    scope :scope2, MovingWindow.scope { [6.months.ago, 1.day.ago] }
    scope :scope3, MovingWindow.scope(:published_at) { [6.months.ago, 1.day.ago] }
    scope :scope4, MovingWindow.scope(:published_at) { [1.day.ago, 6.months.ago] }
    scope :scope5, MovingWindow.scope(:published_at) { [6.months.from_now, 1.day.ago] }
  end

  before do
    @ancient = Review.create!(
      :created_at   => 20.months.ago,
      :updated_at   => 18.months.ago,
      :published_at => 15.months.ago
    )

    @old = Review.create!(
      :created_at   => 9.months.ago,
      :updated_at   => 7.months.ago,
      :published_at => 5.months.ago
    )

    @new = Review.create!(
      :created_at   => 1.month.ago,
      :updated_at   => 3.weeks.ago,
      :published_at => 2.weeks.ago
    )

    @cutting_edge = Review.create!(
      :created_at   => 10.minutes.ago,
      :updated_at   => 10.minutes.ago,
      :published_at => 30.seconds.ago
    )

    @future = Review.create!(
      :created_at   => 1.hours.from_now,
      :updated_at   => 2.hours.from_now,
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

  it 'supports manual invocation' do
    window1 = MovingWindow.new { [2.months.ago, 2.months.from_now] }
    window2 = MovingWindow.new { 45.seconds.ago }

    window1.filter(Review).to_a.should == [@new, @cutting_edge, @future]
    window2.filter(Review).to_a.should == []

    window2.filter(Review, :published_at).to_a.should == [@cutting_edge]

    filtered = window1.filter(Review.limit(1))
    window2.filter(filtered, :published_at).to_a.should == [@cutting_edge]
  end

end

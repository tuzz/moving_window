## Moving Window

A helper for building scopes that deal with moving windows.

## Usage

```ruby
require 'moving_window'

class Review < ActiveRecord::Base
  scope :recent, MovingWindow.scope { 6.months.ago }
end

Review.recent # Returns reviews from the last 6 months.
```

You can specify an end to the window with an array. The ordering does not matter:

```ruby
scope :a_while_ago, MovingWindow.scope { [3.months.ago, 6.months.ago] }
```

By default, `created_at` is used. If you want to specify a different column:

```ruby
scope :recently_published, MovingWindow.scope(:published_at) { 6.months.ago }
```

Dates in the future will also work.

Note: There's no need to worry about invoking the scope with a lambda. The timestamps will be re-evaluated on each call.

## Manual Invocation

You'll find that `.scope` won't work outside of an active record model. Invoke things manually instead:

```ruby
window = MovingWindow.new { 6.months.ago }
window.filter(Review, :published_at)
```

Arel is fully supported:

```ruby
window.filter(Review.published).limit(5)
```

## Contribution

Feel free to contribute. No commit is too small.

You should follow me: [@cpatuzzo](https://twitter.com/cpatuzzo)

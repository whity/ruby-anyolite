# Anyolite

A very simple ruby web framework based on hanami-router.

## Usage

```ruby
require 'anyolite'

app = Anyolite.new(
  templates: "#{__dir__}/templates",
  # layout : 'default', (optional)
  # context_class: My::Context::Class (optional)
)

# use rack middleware

app.use(My::Rack::Middleware, xpto: 1)

# define the actions

# rendering text
app.get(
  '/text',
  to: lambda { |ctx|
    ctx.render_text('lambda action')
  }
)

# rendering json
app.get(
  '/json',
  to: lambda { |ctx|
    ctx.render_json({xpto: 1})
  }
)

# rendering template inline (erb)
app.get(
  '/template-inline',
  to: lambda { |ctx|
    ctx.render_template_inline(
      'hello <%= name %>',
      locals: {name: 'world'},
      layout: 'alternative' # optional
    )

    # ctx.render_template(
    #   'hello <%= name %>',
    #   locals: {name: 'world'},
    #   layout: 'alternative', # optional
    #   inline: true,
    # )
  }
)

# rendering template file (erb)
app.get(
  '/template-file',
  to: lambda { |ctx|
    ctx.render_template(
      'index',
      locals: {name: 'world'},
      layout: 'alternative' # optional
    )
  }
)
```

### Inherit

```ruby
class App < Anyolite
  module Actions
    class Index
      include Anyolite::Action

      def call!(ctx)
        # by default will try to render a template
        ctx.render('index')
      end
    end
  end

  # def initialize(**options)
  #   super(**options, namespace: Actions)
  # end

  def startup
    get(
      '/index',
      to: Actions::Index
      # to: 'actions#index' # wil search for App::Actions::Index
    )
  end
end
```

### Action Middleware

```ruby
class MyActionMiddleware
  def initialize(app, **options)
    @app     = app
    @options = options
  end

  def call!(ctx)
    # my action middleware

    # call next middleware in chain
    @app.call!(ctx)
  end
end

class MyAction
  include Anyolite::Action

  use(MyActionMiddlware, test_option: 1)

  def call!(ctx)
    ctx.render('my-action', type: :text)
  end
end
```
## TODO

- better doc
- unit tests
- ...

## Contributing

1. Fork it ( https://github.com/[your-github-name]/ruby-anyolite/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- whity(https://github.com/whity) André Brás - creator, maintainer

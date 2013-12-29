# NAME

MT::App::Lite - lightweight Movable Type base web application class

# SYNOPSIS

    package MyLiteApp;
    use strict;

    use MT::App::Lite;

    setup Renderer => 'Xslate';

    get '/' => sub {
      my $app = shift;
      $app->render('index.tt', {
        blog => MT->model('blog')->load(1),
        entries => [MT->model('entry')->load({blog_id => 1})],
      });
    };
    
    get '/index_mt' => sub {
      my $app = shift;
      $app->render('index_mt.mtml', {
        blog => MT->model('blog')->load(1),
        entries => [MT->model('entry')->load({blog_id => 1})],
      }, 'MTML');
    };
    
    1;
    
    __DATA__
    
    @@ index.tt
    <!doctype html>
    <html>
    <head>
      <meta charset="utf-8">
      <title><: $blog.name :></title>
    </head>
    <body>
      <ul>
      : for $entries -> $entry {
        <li><a href="<: $entry.permalink :>"><: $entry.title :></a></li>
      : }
      </ul>
    </body>
    </html>
    
    @@ index_mt.mtml
    <!doctype html>
    <html>
    <head>
      <meta charset="<$mt:PublishCharset$>">
      <title><$mt:BlogName$></title>
    </head>
    <body>
      <ul>
      <mt:Entries>
        <li><a href="<$mt:EntryPermalink$>"><$mt:EntryTitle$></a></li>
      </mt:Entries>
      </ul>
    </body>
    </html>

# DESCRIPTION

MT::App::Lite is lightweight Movable Type base web application class.

Its still only supports running MT with PSGI.

# HOW TO USE WITH A MT PLUGIN

## config.yaml

    name: MyLiteApp
    id:   myliteapp
    
    applications:
      lite_app:
        handler: MyLiteApp
        script: sub { 'app' }
        cgi_path: sub { '/' }

## MyLiteApp (handler)

    package MyLiteApp;
    use strict;

    use MT::App::Lite;

    setup Renderer => 'Xslate';

    get '/' => sub {
      my $app = shift;
      $app->render('index.tt', {
        blog => MT->model('blog')->load(1),
        entries => [MT->model('entry')->load({blog_id => 1})],
      });
    };

    get '/entry/:id' => sub {
      my $app = shift;
      $app->render('entry.tt', {
        blog => MT->model('blog')->load(1),
        entry => [MT->model('entry')->load($app->param('id'))],
      });
    };
    
    1;
    
    __DATA__

    @@ index.tt
    <!doctype html>
    <html>
    <head>
      <meta charset="utf-8">
      <title><: $blog.name :></title>
    </head>
    <body>
      <ul>
      : for $entries -> $entry {
        <li><a href="<: $entry.permalink :>"><: $entry.title :></a></li>
      : }
      </ul>
    </body>
    </html>
   
    @@ entry.tt
    <!doctype html>
    <html>
    <head>
      <meta charset="utf-8">
      <title><: $entry.title :> | <: $blog.name :></title>
    </head>
    <body>
      <h1><: $entry.title :></h1>
      <div>
        <: $entry.text | mark_raw :>
      </div>
    </body>
    </html>

Try to access `http://yourdomain/app/` and `http://yourdomain/app/entry/1`(entry\_id).

# FUNCTIONS AND METHODS

## get($path:Str, $code:CodeRef)

    get '/' => sub { ... };

Add new route, handles GET method.

## post($path:Str, $code:CodeRef)

    post '/' => sub { ... };

Add new route, handles POST method.

## any($path:Str, $code:CodeRef)

    any '/' => sub { ...  };

Add new route, handles any HTTP method.

SEE [Router::Simple::Sinatraish](http://search.cpan.org/~tokuhirom/Router-Simple-Sinatraish-0.03/lib/Router/Simple/Sinatraish.pm).

## setup($config:Str, $value:Str)

    setup Renderer => 'MTML'

### Renderer (support (Xslate|MTML))

Set renderer. Default renderer is Xslate.

## $app->render($template\_name:Str, $param:HashRef[, $renderer:Str])

    $app->render('index.tt', {
      blog => MT->model('blog')->load(1),
      entries => [MT->model('entry')->load({blog_id => 1})],
    });

If you want use other renderer, set renderer name to third argument.

## $app->render\_string($template\_string:Str, $param:HashRef[, $renderer:Str])

    $app->render_string('<: $blog.name :>', {
      blog => MT->model('blog')->load(1),
    });

If you want use other renderer, set renderer name to third argument.
 
# REQUIREMENTS PERL MODULE

- All the Movable Type modules
- Text::Xslate
- Data::Section::Simple
- Router::Simple::Sinatraish

See `cpanfile`.

# TODO

- Write test.

# LICENSE

Copyright (C) HIGASHI Taiju.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

HIGASHI Taiju <higashi@taiju.info>

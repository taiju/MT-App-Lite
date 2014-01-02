package MT::App::Lite;

use strict;
use warnings;

our $VERSION = '0.2';

use parent qw(MT::App);

use Router::Simple::Sinatraish;
use Data::Section::Simple qw(get_data_section);
use File::Basename qw(fileparse);
use Plack::MIME;

sub import {
  my $caller = caller;
  no strict 'refs';
  push @{"${caller}::ISA"}, 'MT::App::Lite';
  Router::Simple::Sinatraish->export_to_level(1);
  *{"${caller}::setup"} = sub {
    my ($key, $value) = @_;
    ${"${caller}::${key}"} = $value;
  };
}

sub init_request {
  my $app = shift;
  $app->SUPER::init_request(@_);
  $app->add_methods( dispatch => \&dispatch );
  $app->{default_mode} = 'dispatch';
  my $app_class = ref $app;

  no strict 'refs';
  my $renderer_name = ${"${app_class}::Renderer"} || 'Xslate';
  $app->set_renderer($renderer_name) or return $app->error;
  $app->set_templates or return $app->error;
}

sub dispatch {
  my $app = shift;
  my $app_class = ref $app;
  $app->router->{routes} = $app_class->router->{routes};
  my $route = $app->router->match($app->{query}->env);
  return $app->error('Not Found route') unless $route;
  my $code = $route->{code};
  delete $route->{code};
  $app->param($_, $route->{$_}) for keys %$route;
  $code->($app);
}

sub render {
  my $app = shift;
  my ($file_path, $param, $subclass) = @_;
  my ($filename, $dirname, $suffix) = fileparse($file_path, qr/\.[^.]*/);
  my $mime_type = Plack::MIME->mime_type($suffix);
  $app->send_http_header($mime_type) if $mime_type;
  my $tmpl = $app->{templates}->{$file_path} || $app->read_tmpl_from_file($file_path);
  return $app->error('Not Found Template') unless $tmpl;
  $app->set_renderer($subclass) if $subclass;
  return $app->error($app->{_errstr}) if $app->{_errstr};
  $app->{renderer}->render($tmpl, $param);
}

sub render_string {
  my $app = shift;
  my ($string, $param, $subclass) = @_;
  $app->set_renderer($subclass) if $subclass;
  return $app->error($app->{_errstr}) if $app->{_errstr};
  $app->{renderer}->render_string($string, $param);
}

sub read_tmpl_from_file {
  my $app = shift;
  my $file_path = shift;
  my $app_class = ref $app;
  my $tmpl_path;
  {
    no strict 'refs';
    $tmpl_path = ${"${app_class}::TemplatePath"};
    $tmpl_path =~ s{/$}{};
  }
  my $fmgr = MT::FileMgr->new('Local') or die $app->error(MT::FileMgr->errstr);
  $fmgr->get_data("$tmpl_path/$file_path");
}

sub set_renderer {
  my $app = shift;
  my $subclass = shift;
  my $renderer_class = "MT::App::Lite::Renderer::$subclass";
  eval "require $renderer_class";
  $app->error($@) if $@;
  $app->{renderer} = $renderer_class->new if $subclass;
}

sub set_templates {
  my $app = shift;
  my $app_class = ref $app;
  my $reader = Data::Section::Simple->new($app_class);
  my $templates = $reader->get_data_section;
  $app->{templates} = $templates;
}

1;
__END__

=encoding utf-8

=head1 NAME

MT::App::Lite - lightweight Movable Type base web application class

=head1 SYNOPSIS

  package MyLiteApp;
  use strict;

  use MT::App::Lite;

  setup Renderer     => 'Xslate';
  setup TemplatePath => '/path/to/templates';

  get '/' => sub {
    my $app = shift;
    $app->render('index.html', {
      blog => MT->model('blog')->load(1),
      entries => [MT->model('entry')->load({blog_id => 1})],
    });
  };
  
  get '/index_mt' => sub {
    my $app = shift;
    $app->render('index_mt.html', {
      blog => MT->model('blog')->load(1),
      entries => [MT->model('entry')->load({blog_id => 1})],
    }, 'MTML');
  };
  
  get '/titles.json' => sub {
    my $app = shift;
    my @entries = MT->model('entry')->load({blog_id => 1});
    my @titles = grep { $_} map { $_->title } @entries;
    my $json = MT::Util::to_json(\@titles);
    $app->render('titles.json', { json => $json });
  };

  1;
  
  __DATA__
  
  @@ index.html
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
  
  @@ index_mt.html
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

  @@ titles.json
  <: $json | mark_raw :>

=head1 DESCRIPTION

MT::App::Lite is lightweight Movable Type base web application class.

Its still only supports running MT with PSGI.

=head1 HOW TO USE WITH A MT PLUGIN

=head2 config.yaml

  name: MyLiteApp
  id:   myliteapp
  
  applications:
    lite_app:
      handler: MyLiteApp
      script: sub { 'app' }
      cgi_path: sub { '/' }

=head2 MyLiteApp (handler)

  package MyLiteApp;
  use strict;

  use MT::App::Lite;

  setup Renderer => 'Xslate';

  get '/' => sub {
    my $app = shift;
    $app->render('index.html', {
      blog => MT->model('blog')->load(1),
      entries => [MT->model('entry')->load({blog_id => 1})],
    });
  };

  get '/entry/:id' => sub {
    my $app = shift;
    $app->render('entry.html', {
      blog => MT->model('blog')->load(1),
      entry => [MT->model('entry')->load($app->param('id'))],
    });
  };

  get '/titles.json' => sub {
    my $app = shift;
    my @entries = MT->model('entry')->load({blog_id => 1});
    my @titles = grep { $_} map { $_->title } @entries;
    my $json = MT::Util::to_json(\@titles);
    $app->render('titles.json', { json => $json });
  };
  
  1;
  
  __DATA__

  @@ index.html
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

  @@ entry.html
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

  @@ titles.json
  <: $json | mark_raw :>

Try to access http://yourdomain/app/, http://yourdomain/app/entry/1(entry_id) and http://yourdomain/app/titles.json.

=head1 FUNDTIONS AND METHODS

=head2 get($path:Str, $code:CodeRef)

  get '/' => sub { ... };

Add new route, handles GET method.

=head2 post($path:Str, $code:CodeRef)

  post '/' => sub { ... };

Add new route, handles POST method.

=head2 any($path:Str, $code:CodeRef)

  any '/' => sub { ...  };

Add new route, handles any HTTP method.

SEE L<Router::Simple::Sinatraish>.

=head2 setup($config:Str, $value:Str)

  setup Renderer     => 'MTML';
  setup TemplatePath => '/path/to/templates';

=head3 Renderer (support (Xslate|MTML))

Set renderer. Default renderer is Xslate.

=head3 TemplatePath

Set static template file path.

=head2 $app->render($template_name:Str, $param:HashRef[, $renderer:Str])

  $app->render('index.html', {
    blog => MT->model('blog')->load(1),
    entries => [MT->model('entry')->load({blog_id => 1})],
  });

If you want use other renderer, set renderer name to third argument.

=head2 $app->render_string($template_string:Str, $param:HashRef[, $renderer:Str])

  $app->render_string('<: $blog.name :>', {
    blog => MT->model('blog')->load(1),
  });

If you want use other renderer, set renderer name to third argument.

=head1 REQUIREMENTS PERL MODULE

=over 4

=item * All the Movable Type modules

=item * L<Text::Xslate>

=item * L<Data::Section::Simple>

=item * L<Router::Simple::Sinatraish>

=back

See cpanfile.

=head1 LICENSE

Copyright (C) HIGASHI Taiju.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

HIGASHI Taiju E<lt>higashi@taiju.infoE<gt>

=cut

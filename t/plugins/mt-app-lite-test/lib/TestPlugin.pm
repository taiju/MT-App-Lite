package TestPlugin;

use strict;
use warnings;

use MT::App::Lite;

setup TemplatePath => 't/plugins/mt-app-lite-test/templates';

get '/hello' => sub {
  'hello!';
};

get '/ref-app' => sub {
  ref shift;
};

get '/xslate-string' => sub {
  my $app = shift;
  $app->render_string('<: $xslate :>', { xslate => 'xslate' });
};

get '/mtml-string' => sub {
  my $app = shift;
  $app->render_string('<$mt:Var name="mtml"$>', { vars => { mtml => 'mtml' } }, 'MTML');
};

get '/xslate-template' => sub {
  my $app = shift;
  $app->render('xslate', { xslate => 'xslate' });
};

get '/mtml-template' => sub {
  my $app = shift;
  $app->render('mtml', { vars => { mtml => 'mtml' } }, 'MTML');
};

get '/capture/:keyword' => sub {
  my $app = shift;
  $app->render_string('<: $keyword :>', { keyword => $app->param('keyword') });
};

get '/foo/bar/baz' => sub {
  my $app = shift;
  $app->render('foo/bar/baz', { xslate => 'xslate' });
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
@@ xslate
<: $xslate :>

@@ mtml
<$mt:Var name="mtml"$>

@@ titles.json
<: $json | mark_raw :>

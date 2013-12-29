package TestPlugin;

use strict;
use warnings;

use MT::App::Lite;

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

1;

__DATA__
@@ xslate
<: $xslate :>

@@ mtml
<$mt:Var name="mtml"$>

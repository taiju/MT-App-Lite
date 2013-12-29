use strict;
use warnings;

use lib qw(lib extlib t/lib);

use Test::More;

BEGIN {
  use_ok 'MT::App::Lite';
  use_ok 'MT::App::Lite::Renderer::Xslate';
  use_ok 'MT::App::Lite::Renderer::MTML';
}

done_testing;

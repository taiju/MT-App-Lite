use strict;
use warnings;

use lib qw(lib extlib t/lib);

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use MT::Test qw(:db);
use MT::PSGI;

# TestPlugin into t/plugins/mt-app-lite-test
my $app = MT::PSGI->new( applications => 'mt-app-lite-test' )->to_app();
my $test = Plack::Test->create($app);

is $test->request(GET '/test/hello')->content, 'hello!', 'Return string';
is $test->request(GET '/test/ref-app')->content, 'TestPlugin', 'Return ref $app';
is $test->request(GET '/test/xslate-string')->content, 'xslate', 'Return built string as xslate renderer';
is $test->request(GET '/test/mtml-string')->content, 'mtml', 'Return built string as mtml renderer';
like $test->request(GET '/test/xslate-template')->content, qr/^xslate\s*/, 'Return built template as xslate renderer';
like $test->request(GET '/test/mtml-template')->content, qr/^mtml\s*/, 'Return built template as mtml renderer';

is $test->request(GET '/test/capture/hello')->content, 'hello', 'Get capture string as GET parameter';

done_testing;

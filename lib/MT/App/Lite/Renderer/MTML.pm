package MT::App::Lite::Renderer::MTML;

use MT::Builder;
use MT::Template::Context;

sub new {
  my $class = shift;
  my $self = shift;
  $self->{builder} = MT::Builder->new;
  $self->{ctx} = MT::Template::Context->new;
  bless $self, $class;
}

sub render {
  my $self = shift;
  my ($tmpl, $param) = @_;
  my $builder = $self->{builder};
  my $ctx = $self->{ctx};
  $ctx->{__stash} = $param;
  my $tokens = $builder->compile($ctx, $tmpl);
  $builder->build($ctx, $tokens);
}

*render_string = \&render;

1;

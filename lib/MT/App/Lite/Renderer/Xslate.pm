package MT::App::Lite::Renderer::Xslate;

use strict;
use warnings;

use Text::Xslate;

sub new {
  my $class = shift;
  my $self = shift;
  $self->{tx} = Text::Xslate->new;
  bless $self, $class;
}

sub render {
  my $self = shift;
  $self->{tx}->render_string(@_);
}

*render_string = \&render;

1;

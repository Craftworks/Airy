package Airy::View::Xslate;

use Airy;
use base 'Airy::View';
use Text::Xslate;

sub initialize {
    my $self = shift;

    unless ( $self->config ) {
        $self->config({});
    }

    $self->{'tx'} = Text::Xslate->new(
        'path' => [ 'template' ],
        %{ $self->config },
        @_,
    );
}

sub render {
    my ($self, $template, $vars) = @_;

    my $suffix = $self->{'tx'}{'suffix'};

    unless ( $template =~ /$suffix$/o ) {
        $template = $template . $suffix;
    }

    $vars->{'content'} = $template;

    $self->{'tx'}->render("wrapper$suffix", $vars);
}

1;

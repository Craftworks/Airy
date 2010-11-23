package Airy::View::Xslate;

use Airy;
use base 'Airy::View';
use Text::Xslate;
use Class::Inspector;

sub initialize {
    my $self = shift;

    unless ( $self->config ) {
        $self->config({});
    }

    $self->{'tx'} = Text::Xslate->new(
        'path' => [ 'template' ],
        'function' => $self->setup_function,
        %{ $self->config },
        @_,
    );
}

sub setup_function {
    my $self = shift;

    my $function;
    my $methods = Class::Inspector->methods(ref $self, 'private', 'expanded');

    no strict 'refs';
    for my $method ( @$methods ) {
        if ( $method->[2] =~ /^__function_(\w+)/o ) {
            $function->{ $1 } = $method->[3];
        }
    }

    return $function;
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

package Airy::View::Xslate;

use Airy;
use base 'Airy::View';
use Text::Xslate qw/html_builder html_escape mark_raw/;
use Class::Inspector;
use HTML::FillInForm::Lite;

my $app_class = Airy::Util::app_class;

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
        $template .= $suffix;
    }

    $self->{'tx'}->render($template, $vars);
}

sub render_web {
    my ($self, $stash) = @_;
    no warnings 'once';
    my $c = $Airy::CONTEXT;

    my $template = $stash->{'template'};

    my $suffix = $self->{'tx'}{'suffix'};
    unless ( $template =~ /$suffix$/o ) {
        $template .= $suffix;
    }

    $self->log->info(qq{Rendering template "$template"});

    unless ( $stash->{'nowrapper'} ) {
        $stash->{'content'} = $template;
        $template = 'wrapper';
    }

    $stash->{'env'}     = $c->req->env;
    $stash->{'param'}   = $c->req->parameters->as_hashref_mixed;

    my $body = $self->render($template, $stash);
    $body = $c->encoding->encode($body) if utf8::is_utf8($body);
    $c->res->body($body);

    if ( $body =~ /^\s*<(?:!DOCTYPE|html)/io ) {
        $c->res->content_type('text/html');
    }
}

sub __function__ {
    my ($format, @args) = @_;
    html_escape $_ for @args;
    mark_raw("$app_class\::I18N"->loc($format, @args));
}

sub __function_fillinform {
    my @vars = @_;
    my $fif = HTML::FillInForm::Lite->new;
    return html_builder {
        my ($html) = @_;
        $fif->fill(\$html, \@vars);
    };
}

1;

package Airy::View::JSON;

use Airy;
use base 'Airy::View';
use JSON;

sub render {
    my ($self, $vars) = @_;

    my $json = encode_json($vars);

    return $json;
}

sub render_web {
    my ($self, $stash) = @_;
    no warnings 'once';
    my $c = $Airy::CONTEXT;

    # TODO support callback switching
    my $cb_param = ( 1 || 'allow_callback' )
        ? ( 'callback' ) : undef;
    my $cb = $cb_param ? $c->req->param($cb_param) : undef;

    my $encoding = $c->encoding->mime_name;
    my $body;

    # add UTF-8 BOM if the client is Safari
    if ( $encoding eq 'UTF-8' ) {
        my $user_agent = $c->req->user_agent || '';
        if ( $user_agent =~ m/\bSafari\b/ && $user_agent !~ m/\bChrome\b/ ) {
            $body = "\xEF\xBB\xBF";
        }
    }

    $body .= "$cb(" if $cb;
    $body .= $self->render($stash->{'json'});
    $body .= ");"   if $cb;

    $c->res->body($body);

    if ( ($c->req->user_agent || '') =~ /Opera/ ) {
        $c->res->content_type("application/x-javascript; charset=$encoding");
    }
    else {
        $c->res->content_type("application/json; charset=$encoding");
    }
}

1;

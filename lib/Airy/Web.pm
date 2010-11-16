package Airy::Web;

use Airy -base;
use Airy::Container;
use UNIVERSAL::require;
use Module::Pluggable::Object;

sub import {
    my $class  = shift;
    my $caller = caller 0;

    $class->request_class->use or die $@;
    $class->response_class->use or die $@;
    $class->setup_view;
}

sub request_class  { 'Plack::Request'  };
sub response_class { 'Plack::Response' };

sub request  { shift->{'request'}  }
sub req      { shift->{'request'}  }
sub response { shift->{'response'} }
sub res      { shift->{'response'} }

sub setup_view {
    my $class = shift;

    my $app_class = Airy::Util->app_class;
    my @path = (qw(View));
    my @components = Module::Pluggable::Object->new(
        'search_path' => [ map "$app_class\::$_", @path ],
    )->plugins;

    my %view_class;
    for my $module ( @components ) {
        $module->use or die $@;
        my $obj = $module->new;
        my ($name) = $module =~ /View::(.+)/o;
        $view_class{ $name } = $obj;
    }

    *view_class = sub { \%view_class };
}

sub controller {
    my ($c, $module) = @_;

    my $class = ref $c;
    my $name  = $c->{'name'};
    my $controller = "$class\::Controller::$name\::$module";

    Airy::Container->get($controller);
}

sub api {
    my ($c, $module) = @_;
    my $app_class = Airy::Util->app_class;
    Airy::Container->get("$app_class\::API::$module");
}

sub handler {
    my ($class, $name) = @_;

    my $request_class  = $class->request_class;
    my $response_class = $class->response_class;
    $request_class->use  or die $@;
    $response_class->use or die $@;

    my $dispatcher_class = "$class\::Dispatcher::$name";
    $dispatcher_class->use or die $@;

    sub {
        my $env = shift;
        my $req = $request_class->new($env);
        my $res = $response_class->new(200);
        my $stash = {};

        my $c = $class->new(
            'name'         => $name,
            'request'      => $req,
            'response'     => $res,
            'stash'        => $stash,
        );

        no warnings 'redefine';
        local $Airy::CONTEXT = $c;

        $c->log->info(sprintf '"%s" request for "%s" from "%s"',
            @$env{qw(REQUEST_METHOD PATH_INFO REMOTE_ADDR)});

        unless ( $dispatcher_class->dispatch($c) ) {
            $c->response_404;
        }

        if ( $res->status !~ /^3/o && !defined $res->body ) {
            $c->render;
        }

        return $res->finalize;
    };
}

sub response_404 {
    my $c = shift;
    $c->{'response'}->status(404);
    $c->{'response'}->body('404 Not Found');
}

sub render {
    my $c = shift;

    my $view_class = $c->{'stash'}{'view_class'} || 'Xslate';
    my $view = $c->view_class->{ $view_class }
        or die qq{view not found "$view_class"};

    my $body = $view->render($c->{'stash'}{'template'}, $c->{'stash'});
    $c->res->body($body);

    if ( $body =~ /^\s*<(?:!DOCTYPE|html)/io ) {
        $c->res->content_type('text/html');
    }

    $c;
}

1;

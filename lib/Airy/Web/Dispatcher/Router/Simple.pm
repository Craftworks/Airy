package Airy::Web::Dispatcher::Router::Simple;

use Airy;
use Router::Simple;

sub import {
    my $class  = shift;
    my $caller = caller 0;

    my $router = Router::Simple->new;

    no strict 'refs';
    *{"$caller\::connect"}   = sub { $router->connect(@_) };
    *{"$caller\::submapper"} = sub { $router->submapper(@_) };
    *{"$caller\::router"}    = sub { $router };
    for my $method (qw(match as_string)) {
        *{"$caller\::$method"} = sub { shift; $router->$method(@_) };
    }
    *{"$caller\::dispatch"}  = \&dispatch;
}

sub dispatch {
    my ($class, $c) = @_;

    if ( my $p = $class->router->match($c->{'request'}->env) ) {
        my ($controller, $action) = delete @$p{qw(controller action)};

        my $path = lc "$controller/$action";
        $path =~ s{::}{/}go;
        $c->log->info("Path is $path");

        $c->{'stash'}{'template'} = $path;
        $c->controller($controller)->$action($c, $p);

        return 1;
    }
}   

1;

package Airy::Web;

use Airy -base;
use Airy::Container;
use Airy::Web::ActionClass;
use UNIVERSAL::require;
use Module::Pluggable::Object;
use Encode ();
use I18N::LangTags ();
use I18N::LangTags::Detect;

our $COUNT = 1;
our $START = time;

my $is_i18n = 0;
my $is_session = 0;

my $encoding = Encode::find_encoding('utf-8') or die $!;
sub encoding { $encoding }

sub request_class  { 'Plack::Request'  }
sub response_class { 'Plack::Response' }

sub request  { shift->{'request'}  }
sub req      { shift->{'request'}  }
sub response { shift->{'response'} }
sub res      { shift->{'response'} }

sub setup {
    my ($class, $name) = @_;

    no warnings 'once';
    *name    = sub { $name };
    *name_lc = sub { lc $name };
    *debug   = sub { shift->{'debug'} };

    $class->request_class->use  or die $@;
    $class->response_class->use or die $@;
    $class->setup_dispatcher;
    $class->setup_controller;
    $class->setup_view;
    Airy::Web::ActionClass->setup;

    return $class;
}

sub setup_dispatcher {
    my $class = shift;

    my $app_class   = Airy::Util->app_class;
    my $name        = $class->name;
    my $search_path = "$app_class\::Web::Dispatcher";
    my $dispatcher  = "$search_path\::$name";

    my @components  = Module::Pluggable::Object->new(
        'search_path' => [ $search_path ],
    )->plugins;
    @components = grep /$dispatcher/o, @components;

    for my $module ( @components ) {
        $module->use or die $@;
    }

    no warnings 'once';
    *dispatcher_class = sub { $dispatcher };
}

sub setup_controller {
    my $class = shift;

    my $app_class   = Airy::Util->app_class;
    my $name        = $class->name;
    my $search_path = "$app_class\::Web::Controller";
    my $controller  = "$search_path\::$name";

    my @components  = Module::Pluggable::Object->new(
        'search_path' => [ $search_path ],
    )->plugins;
    @components = grep /$controller/o, @components;

    for my $module ( @components ) {
        $module->use or die $@;
    }
}

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

    no warnings 'once';
    *view_class = sub { \%view_class };
}

sub controller {
    my ($c, $module) = @_;

    my $app_class = Airy::Util->app_class;
    my $name  = $c->{'name'};
    my $controller = "$app_class\::Web::Controller::$module";

    Airy::Container->get($controller);
}

sub api {
    my ($c, $module) = @_;
    my $app_class = Airy::Util->app_class;
    Airy::Container->get("$app_class\::API::$module");
}

sub handler {
    my $class = shift;

    sub {
        my $env = shift;

        my $secs = time - $START || 1;
        my $avg  = sprintf '%.3f', $COUNT / $secs;
        $class->log->info("*** Request $COUNT ($avg/s) [$$] ***");

        no warnings 'once';
        local $Airy::CONTEXT = my $c = $class->new(
            'debug'        => ( $ENV{'PLACK_ENV'} eq 'development' ),
            'name'         => $class->name,
            'request'      => $class->request_class->new($env),
            'response'     => $class->response_class->new(200),
            'stash'        => +{},
        );

        $c->log->info(sprintf '"%s" request for "%s" from "%s"',
            @$env{qw(REQUEST_METHOD PATH_INFO REMOTE_ADDR)});

        eval {
            $c->prepare;
            $c->dispatch;
            $c->render;
            $c->finalize;
        };
        if ( my $error = $@ ) {
            $c->log->error(qq{Caught exception "$error"});
            if ( !$c->{'debug'} ) {
                $c->response_500($error);
            }
            else {
                die $error;
            }
        }

        $COUNT++;

        return $c->res->finalize;
    };
}

sub prepare {
    my $c = shift;

    my $lang = $c->detect_language;

    if ( $is_i18n || Airy::Util::is_class_loaded("$Airy::APP_CLASS\::I18N") ) {
        $c->{'stash'}{'language'} = $Airy::I18N::Lang = $lang;
        $is_i18n = 1;
    }

    if ( $is_session || Airy::Util::is_class_loaded('Plack::Session') ) {
        $c->{'session'} = Plack::Session->new($c->req->env);
        $c->req->session_options->{'change_id'}++;
        $is_session = 1;
    }
}

sub detect_language {
    my $c = shift;

    my $accept_language = $c->{'request'}{'env'}{'HTTP_ACCEPT_LANGUAGE'};
    my $languages = [ I18N::LangTags::implicate_supers(
        I18N::LangTags::Detect->http_accept_langs($accept_language)
    ) ];

    my ($lang) = $languages->[0] =~ /(\w+)/o;

    return $lang;
}

sub dispatch {
    my $c = shift;

    unless ( $c->dispatcher_class->dispatch($c) ) {
        $c->response_404;
    }
}

sub finalize {
    my $c = shift;
}

sub response_404 {
    my $c = shift;
    $c->{'response'}->status(404);
    $c->{'response'}->body('404 Not Found');
}

sub response_500 {
    my $c = shift;
    $c->{'response'}->status(500);
    $c->{'response'}->body('500 Internal Server Error');
}

sub render {
    my $c = shift;
    my $res = $c->res;

    return $c if ( index($res->status, '3') == 0 || defined $res->body );

    my $view_class = $c->{'stash'}{'view_class'} || 'Xslate';
    my $view = $c->view_class->{ $view_class } or die qq{view not found "$view_class"};

    $view->render_web($c->{'stash'});

    $c;
}

1;

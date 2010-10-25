package Airy::Log;

use strict;
use warnings;
use Log::Dispatch;
use Airy::Config;

my $logger;

sub setup {
    my ( $class, ) = @_;

    *Log::Dispatch::warn  = *Log::Dispatch::warning;
    *Log::Dispatch::fatal = *Log::Dispatch::emergency;

    my $conf = Airy::Config->get('Log::Dispatch');
    unless ( $conf ) {
        warn qq{missing configuration for "Log::Dispatch". use default configuration.\n};
        $conf = +{
            'outputs' => [ [
                'class'     => 'Log::Dispatch::Screen',
                'min_level' => 'debug',
                'stderr'    => 1,
                'format'    => '%d{%Y-%m-%d %H:%M:%S} [%p] %m at %P line %L%n',
            ] ],
        };
    }

    $logger = Log::Dispatch->new(%$conf);
}

sub logger {
    $logger;
}

1;

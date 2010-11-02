package Airy::Log;

use strict;
use warnings;
use POSIX;
use Data::Dumper ();
use Log::Dispatch;
use Airy::Config;

my $logger;

sub setup {
    my ( $class, ) = @_;

    *Log::Dispatch::warn  = *Log::Dispatch::warning;
    *Log::Dispatch::fatal = *Log::Dispatch::emergency;
    *Log::Dispatch::dump  = sub {
        my $self = shift;
        local $Data::Dumper::Terse = 1;
        $self->debug(Data::Dumper::Dumper \@_);
    };

    my $config = Airy::Config->get('Log::Dispatch');
    unless ( $config ) {
        warn qq{missing configuration for "Log::Dispatch". use default configuration.\n}
            unless $ENV{'HARNESS_ACTIVE'};

        $config = +{
            'outputs' => [ [
                'Screen',
                'min_level' => 'debug',
                'stderr'    => 1,
                'newline'   => 1,
            ] ],
            'callbacks' => sub {
                my %log = @_;
                sprintf '%s [%s] %s',
                    POSIX::strftime('%F %T', localtime),
                    @log{qw/level message/};
            },
        };
    }

    $logger = Log::Dispatch->new(%$config);
}

sub logger {
    $logger;
}

1;

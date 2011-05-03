package Airy::Log;

use strict;
use warnings;
use POSIX ();
use Data::Dumper ();
use Log::Dispatch;
use Airy::Config;

my $logger;

sub setup {
    my $class = shift;

    {
        no warnings 'redefine';
        *Data::Dumper::qquote = sub { shift };
    }

    *Log::Dispatch::warn  = *Log::Dispatch::warning;
    *Log::Dispatch::fatal = *Log::Dispatch::emergency;
    *Log::Dispatch::dump  = sub {
        my $self = shift;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Useperl = 1;
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

    if ( $ENV{'HARNESS_ACTIVE'} && !$ENV{'AIRY_LOG'} ) {
        no strict 'refs';
        no warnings 'redefine';
        for (qw(dump warn fatal debug info notice
                warning error critical alert emergency)) {
            *{"Log::Dispatch::$_"} = sub {};
        }
        $logger = Log::Dispatch->new(%$config);
    }
    else {
        $logger = Log::Dispatch->new(%$config);
    }
}

sub logger {
    $logger;
}

1;

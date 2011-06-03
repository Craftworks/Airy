package Airy::DOD::DBI;

use Airy;
use parent 'Airy::DOD';
use Carp;
use Data::Dumper;
use POSIX 'strftime';
use Time::HiRes qw(gettimeofday tv_interval);
use DBIx::Connector;
use SQL::Abstract::Limit;
use SQL::Abstract::Plugin::InsertMulti;

my $log_fh;

$Carp::CarpInternal{'Airy::DOD::DBI'}  = 1;
$Carp::CarpInternal{'DBIx::Connector'} = 1;

sub initialize {
    my $self = shift;

    my $config = $self->config;

    unless ( defined $config ) {
        local $Data::Dumper::Terse = 1;
        die sprintf "config->{'DOD::DBI'} must be defined for %s.\n%s",
            ref $self, Dumper(Airy::Config->get_all);
    }

    $log_fh = $config->{'query_log'} || *STDOUT;

    my $connect_info = $config->{'datasource_key'}
        ? $config->{'datasources'}{ $config->{'datasource_key'} }
        : $config->{'datasource'};

    unless ( ref $connect_info eq 'ARRAY'
        && defined $connect_info->[0] && $connect_info->[0] =~ /^dbi:/io ) {
        local $Data::Dumper::Terse = 1;
        die "invalid connect_info.\n" . Dumper($connect_info);
    }

    my $connect_opts = $connect_info->[3];
    if ( !exists $connect_opts->{'RootClass'} ) {
        $connect_opts->{'RootClass'} = 'Airy::DBI';
    }

    $self->{'sql'} = SQL::Abstract::Limit->new(
        'limit_dialect' => $config->{'limit_dialect'}
    );

    $self->{'dbi'} = DBIx::Connector->new(@$connect_info);
    $self->{'dbi'}->mode('fixup');

    *Airy::DOD::DBI::quote = sub {
        $self->{'dbi'}->dbh->quote(@_);
    };
}

sub dbi {
    shift->{'dbi'};
}

sub sql {
    shift->{'sql'};
}

sub datasource {
    shift->dbi->{'_args'};
}

sub _execute_and_log {
    my ($class, $obj, $code, $stmt, @args) = @_;

    local $obj->{'RaiseError'} = 0;
    local $obj->{'PrintError'} = 0;
    my $time   = [gettimeofday];
    my $rv     = $code->();
    my $error  = $obj->errstr;
    my $elapse = tv_interval($time, [gettimeofday]) || 0.000001;
    my $qps    = 1 / $elapse;

    shift @args if ref $args[0] eq 'HASH';
    my ($i, @bind) = (0, @args);

    my $timestamp = strftime('%F %T', localtime);

    $_ = quote($_) for @bind;
    $stmt =~ s/\?/$bind[$i++]/g;
    $stmt =~ tr/\x0A\x0D\t//d;

    printf $log_fh "%s [query] (%.3fmsec/%.1fqps) %s;\n",
        $timestamp, $elapse * 1000, $qps, $stmt;

    if ( $error ) {
        printf $log_fh "%s [query] execute failed: %s\n", $timestamp, $error;
        croak $error;
    }

    return $rv;
}

package Airy::DBI;
use parent 'DBI';

package Airy::DBI::db;

use strict;
use warnings;
use vars '@ISA';
@ISA = 'DBI::db';

sub do {
    my ($self, @args) = @_;
    Airy::DOD::DBI->_execute_and_log($self, sub {
        $self->SUPER::do(@args);
    }, @args);
}

package Airy::DBI::st;

use strict;
use warnings;
use vars '@ISA';
@ISA = 'DBI::st';

sub execute {
    my ($self, @args) = @_;
    Airy::DOD::DBI->_execute_and_log($self, sub {
        $self->SUPER::execute(@args);
    }, $self->{'Statement'}, @args);
}

1;

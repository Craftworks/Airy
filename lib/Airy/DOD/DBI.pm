package Airy::DOD::DBI;

use Airy;
use parent 'Airy::DOD';
use Data::Dumper;
use DBIx::Connector;
use SQL::Abstract::Limit;
use SQL::Abstract::Plugin::InsertMulti;

sub initialize {
    my $self = shift;

    my $config = $self->config;

    unless ( defined $config ) {
        local $Data::Dumper::Terse = 1;
        die sprintf "config->{'DOD::DBI'} must be defined for %s.\n%s",
            ref $self, Dumper(Airy::Config->get_all);
    }

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

package Airy::DBI;
use parent 'DBI';

package Airy::DBI::db;
use vars '@ISA';
@ISA = 'DBI::db';

package Airy::DBI::st;

use strict;
use warnings;
use vars '@ISA';
use Time::HiRes qw(gettimeofday tv_interval);
use POSIX 'strftime';
@ISA = 'DBI::st';

my $dod = "$Airy::APP_CLASS\::DOD::DBI";
my $dod_config = Airy::Config->get($dod);
my $fh = $dod_config->{'query_log'} || *STDOUT;

*quote = *Airy::DOD::DBI::quote;

sub execute {
    my ($self, @args) = @_;

    local $self->{'PrintError'} = 0;
    my $time   = [gettimeofday];
    my $rv     = $self->SUPER::execute(@args);
    my $elapse = tv_interval($time, [gettimeofday]) || 0.000001;
    my $qps    = 1 / $elapse;

    my ($i, $stmt, @bind) = (0, $self->{'Statement'}, @args);

    my $timestamp = strftime('%F %T', localtime);

    $_ = quote($_) for @bind;
    $stmt =~ s/\?/$bind[$i++]/g;
    $stmt =~ tr/\x0A\x0D\t//d;

    printf $fh "%s [query] (%.3fmsec/%.1fqps) %s;\n",
        $timestamp, $elapse * 1000, $qps, $stmt;

    unless ( $rv ) {
        printf STDOUT 'execute failed: ' . $self->errstr;
    }

    return $rv;
}

1;

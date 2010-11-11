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

    $self->{'sql'} = SQL::Abstract::Limit->new(
        'limit_dialect' => $config->{'limit_dialect'}
    );

    $self->{'dbi'} = DBIx::Connector->new(@$connect_info);
    $self->{'dbi'}->mode('fixup');
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

1;

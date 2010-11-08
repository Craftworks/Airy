package Airy::DOD::DBI;

use Airy;
use parent 'Airy::DOD';
use DBIx::Connector;
use Data::Dumper;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    my $config = $self->config;

    unless ( defined $config ) {
        die qq/config->{'DOD::DBI'} must be defined for $class./;
    }

    my $connect_info = $config->{'datasource_key'}
        ? $config->{'datasources'}{ $config->{'datasource_key'} }
        : $config->{'datasource'};

    unless ( ref $connect_info eq 'ARRAY' && $connect_info->[0] =~ /^dbi/i ) {
        local $Data::Dumper::Terse = 1;
        die "invalid connect_info.\n" . Dumper($connect_info);
    }

    $self->{'dbi'} = DBIx::Connector->new(@$connect_info);

    return $self;
}

sub dbi {
    shift->{'dbi'};
}

sub dbh {
    shift->{'dbi'}->dbh;
}

sub datasource {
    shift->dbi->{'_args'};
}

1;

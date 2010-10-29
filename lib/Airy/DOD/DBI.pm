package Airy::DOD::DBI;

use Airy;
use parent 'Airy::DOD';
use DBIx::Connector;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    my $connect_info = $self->config->{'connect_info'};
    $self->{'dbi'} = DBIx::Connector->new(@$connect_info);

    return $self;
}

sub dbi {
    shift->{'dbi'};
}

sub dbh {
    shift->{'dbi'}->dbh;
}

1;

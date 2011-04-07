package Airy::DAO::Plugin::DBI;

use Airy;
use Carp;
use Exporter::Lite;
use Hash::MoreUtils;

our @EXPORT = qw(slice_def sql placeholders mode dbh run txn svp);

sub sql  { shift->dod('DBI')->{'sql'} }
sub mode { shift->dod('DBI')->{'dbi'}->mode(@_) }
sub dbh  { shift->dod('DBI')->{'dbi'}->dbh(@_)  }
sub run  { shift->dod('DBI')->{'dbi'}->run(@_)  }
sub txn  { shift->dod('DBI')->{'dbi'}->txn(@_)  }
sub svp  { shift->dod('DBI')->{'dbi'}->svp(@_)  }

sub placeholders {
    @_ = @{ $_[0] } if ref $_[0] eq 'ARRAY';
    croak 'not enough arguments' unless @_;
    join q{, }, (('?') x @_);
}

{
    no warnings 'once';
    *slice_def = *Hash::MoreUtils::slice_def;
}

1;

package Airy::DAO::Plugin::Solr;

use Airy;
use Carp;
use Exporter::Lite;

our @EXPORT = qw(query found elapsed);

sub query   { shift->dod('Solr')->query(@_) }
sub found   { shift->dod('Solr')->found(@_) }
sub elapsed { shift->dod('Solr')->elapsed(@_) }

1;

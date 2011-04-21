package Airy::DOD::Solr;

use Airy;
use parent 'Airy::DOD';
use Airy::Config;
use Data::Dumper;
use WWW::Curl::Easy;
use URI;
use URI::QueryParam;
use JSON::XS;

my $curl = WWW::Curl::Easy->new;

sub initialize {
    my $self = shift;

    my $config = $self->config;

    unless ( defined $config ) {
        local $Data::Dumper::Terse = 1;
        die sprintf "config->{'DOD::Solr'} must be defined for %s.\n%s",
            ref $self, Dumper(Airy::Config->get_all);
    }

    my $connect_info = $self->{'datasource'} = $config->{'datasource_key'}
        ? $config->{'datasources'}{ $config->{'datasource_key'} }
        : $config->{'datasource'};
    unless ( $connect_info ) {
        local $Data::Dumper::Terse = 1;
        die sprintf "datasource must be defined for %s.\n%s",
            ref $self, Dumper(Airy::Config->get_all);
    }

    $curl->setopt(CURLOPT_URL, "http://$connect_info/solr/");
    $curl->setopt(CURLOPT_WRITEDATA, \my $buffer);
    unless ( (my $retcode = $curl->perform) == 0 ) {
        die sprintf qq{error: $retcode %s %s "$connect_info"},
            $curl->strerror($retcode), $curl->errbuf;
    }

}

sub query {
    my ($self, $core, $api, $param, $opt) = @_;

    $param->{'wt'} = 'json';

    my $uri = $self->_make_api_uri($core, 'select');
    my $u = URI->new('', 'http');
    $u->query_form_hash($param);
    $uri .= $u->query;

    $self->log->debug($uri);

    my $json;
    $curl->setopt(CURLOPT_URL, $uri);
    $curl->setopt(CURLOPT_WRITEDATA, \$json);

    $self->{'found'} = 0;
    if ( my $rc = $curl->perform ) {
        $self->log->error(sprintf qq{curl: %s %s "%s"},
            $curl->strerror($rc), $curl->errbuf, $uri);
    }
    else {
        $json = JSON::XS::decode_json($json);
        $self->{'facet'}   = $json->{'facet_counts'}{'facet_fields'};
        $self->{'found'}   = $json->{'response'}{'numFound'};
        $self->{'elapsed'} = $json->{'responseHeader'}{'QTime'} / 1000;

        return $json->{'response'}{'docs'};
    }
}

sub _make_api_uri {
    my ($self, $core, $api) = @_;
    sprintf 'http://%s/solr/%s/%s?', $self->{'datasource'}, $core, $api;
}

sub found   { shift->{'found'}   } 
sub elapsed { shift->{'elapsed'} }

1;

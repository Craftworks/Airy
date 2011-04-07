package Airy::Web::ActionClass::Pager;

use Airy;

sub before {
    my ($self, $c, $cargs, $aargs) = @_;

    my $per_page;
    if ( @$aargs > 1 ) {
        my %args = @$aargs;
        $per_page = $args{ $c->{'stash'}{'view_name'} };
    }
    elsif ( @$aargs == 1 ) {
        $per_page = $aargs->[0];
    }
    $per_page = int $per_page || 10;

    my $page = $c->req->param('page');
    $page = 0 unless defined $page;
    my $current = int($page < 1 ? 1 : $page);

    $c->{'stash'}{'pager'} = +{
        'current' => $current,
        'limit'   => $per_page,
        'offset'  => ($current - 1) * $per_page,
    };
}

sub after  {
    my ($self, $c, $cargs, $aargs) = @_;

    my %data = %{ $c->{'stash'}{'pager'} };
    $data{'numrows'} ||= 0;

    $data{'numpages'} = POSIX::ceil($data{'numrows'} / $data{'limit'});
    $data{'first'} = 1;
    $data{'last'} = $data{'numpages'};
    $data{'prev'} = $data{'current'} - 1;
    $data{'next'} = $data{'current'} + 1;
    $data{'isfirst'} = ($data{'current'} == $data{'first'});
    $data{'islast'}  = ($data{'current'} == $data{'last'});
    $data{'from'} = $data{'prev'} * $data{'limit'} + 1;
    $data{'to'}   = ($data{'current'} == $data{'last'})
        ? $data{'numrows'} : $data{'current'} * $data{'limit'};

    # format link uri
    $data{'href'} = $c->req->uri;
    $data{'href'} =~ s#https?://.+?/#/#o;
    $data{'href'} =~ s/&?page=[^&]*//go;
    $data{'href'} =~ s/&/&amp;/go;
    $data{'href'} .= '?' if ( index($data{'href'}, '?') == -1 );
    my $start = $data{'current'} - 4;
    my $end   = $data{'current'} + 4;
    $end   = ($end   <  9) ? 9 : $end;
    if ( $data{'last'} < $end ) {
        $start = $data{'last'} - 8;
        $end   = $data{'last'};
    }
    $start = ($start <= 0) ? 1 : $start;

    my $amp = ($data{'href'} =~ /\?$/o) ? '' : '&amp;';
    for my $i ( $start .. $end ) {
        push @{ $data{'pages'} }, +{
            'num'  => $i,
            'href' => $data{'href'} . $amp . 'page=' . $i,
        };
    }
    $data{'prevhref'}  = $data{'href'} . $amp . 'page=' . $data{'prev'};
    $data{'nexthref'}  = $data{'href'} . $amp . 'page=' . $data{'next'};
    $data{'firsthref'} = $data{'href'} . $amp . 'page=1';
    $data{'lasthref'}  = $data{'href'} . $amp . 'page=' . $data{'last'};

    $c->{'stash'}{'pager'} = \%data;
}

1;

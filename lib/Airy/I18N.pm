package Airy::I18N;

use Airy -base;
use Airy::Util;
use Encode;
use File::Spec;
use File::Find;
use File::Basename;
use Locale::Maketext::Lexicon { _decode => 1 };
use Locale::Maketext::Lexicon::Gettext;

my %file;
my %lexicon;
my $default_lang;
our $Lang;

sub import {
    my $class = shift;
    my $caller = caller 0;

    return if $class eq __PACKAGE__;

    unless ( $class->config ) {
        $class->config({});
    }

    $class->find_message_file;
    $class->parse_message_file;
}

sub find_message_file {
    my $class = shift;

    my $root_dir    = Airy::Util::app_class->root_dir;
    my $locale_dir  = $class->config->{'locale_dir'} || 'locale';
    my $locale_path = ( index($locale_dir, '/') == 0 ) ? $locale_dir
                    : File::Spec->catfile($root_dir, $locale_dir);

    unless ( -d $locale_path ) {
        die qq{locale's dir not found "$locale_path"};
    }

    %file = ();
    find(sub {
        return unless -f && /\.[mp]o$/io;
        my $lang = basename(dirname($File::Find::name));
        push @{ $file{ $lang } }, $File::Find::name;
    }, $locale_path);

    return \%file;
}

sub parse_message_file {
    my $class = shift;

    while ( my ($lang, $files) = each %file ) {
        $lexicon{ $lang } ||= {};

        for my $file ( @$files ) {
            open my $fh, '<', $file or die qq{open: $! "$file"};
            my @content = <$fh>;
            close $fh;

            my $lexicon = Locale::Maketext::Lexicon::Gettext->parse(@content);
            for ( values %$lexicon ) {
                s/\[_(\d+)\]/%$1/go;
                $_ = Encode::decode_utf8($_);
            }
            %{ $lexicon{ $lang } }  = ( %{ $lexicon{ $lang } }, %$lexicon );
        }
    }

    return \%lexicon;
}

sub default_lang {
    1 < @_ ? $default_lang = $_[1] : $default_lang;
}

sub lang {
    my $class = shift;

    if ( @_ ) {
        $Lang = $lexicon{ $_[0] } ? $_[0] : $default_lang;
    }
    else {
        $Lang;
    }
}

sub loc {
    my $class = shift;
    my ($format, @args) = @_;

    $format = $lexicon{ $Lang }{ $format } || $format;
    @args = @{ $args[0] } if ( ref $args[0] eq 'ARRAY' );

    no warnings 'uninitialized';
    sprintf $format, @args;
}

1;

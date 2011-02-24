package Airy::Web::ActionClass;

use strict;
use warnings;
use Airy::Util;
use Airy::Attribute::Container;

my $loaded;

sub setup {
    my $class = shift;

    my $attributes = Airy::Attribute::Container->attributes;

    while ( my ($package, $subs) = each %$attributes ) {
        for my $sub ( @$subs ) {
            my ($code, $attrs) = @$sub{qw/code attrs/};

            my @actions;
            for my $attr ( @$attrs ) {
                my ($action) = $attr =~ /(\w+)/o;
                my @args = $attr =~ /(\(.*\))/o ? eval $1 : ();
                my $action_class = $class->_load_action_class($action);

                push @actions, +{
                    'class'  => $class->_load_action_class($action),
                    'before' => $action_class->can('before'),
                    'after'  => $action_class->can('after'),
                    'args'   => \@args
                };
            }

            $class->_redefine_action($package, $code, \@actions);
        }
    }
}

sub _load_action_class {
    my ($class, $action) = @_;

    return $loaded->{ $action } if $loaded->{ $action };

    my $app_class = Airy::Util->app_class;

    my $action_class = "$app_class\::Web::ActionClass::$action";
    eval { $action_class->use }
    or do {
        $action_class = "Airy::Web::ActionClass::$action";
        $action_class->use;
    }
    or die sprintf qq{Can't locate $app_class\::Web::ActionClass::$action or Airy::Web::ActionClass::$action in \@INC (%s)}, join ' ', @INC;

    if ( $action_class->can('setup') ) {
        $action_class->setup;
    }

    $loaded->{ $action } = $action_class;

    return $action_class;
}

sub _redefine_action {
    my ($class, $package, $code, $actions) = @_;

    my $symbol = $class->_find_symbol($package, $code);

    no warnings 'redefine';
    *$symbol = sub {
        my ($self, $c, $args) = @_;

        for my $action ( @$actions ) {
            if ( my $method = $action->{'before'} ) {
                $method->($self, $c, $args, $action->{'args'});
            }
        }

        my $rv = $code->($self, $c, $args);

        for my $action ( reverse @$actions ) {
            if ( my $method = $action->{'after'} ) {
                $method->($self, $c, $args, $action->{'args'});
            }
        }

        return $rv;
    };
}

sub _find_symbol {
    my ($class, $package, $code) = @_;

	no strict 'refs';
    foreach my $sym ( values %{"$package\::"} ) {
        return \$sym if ( *{$sym}{'CODE'} && *{$sym}{'CODE'} eq $code );
    }
}

1;

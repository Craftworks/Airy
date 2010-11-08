package Airy::DAO;

use Airy -base;
use Airy::Util;
use Airy::Container;

sub dod {
    my ($self, $name) = @_;
    my $app_class = Airy::Util->app_class;
    Airy::Container->get("$app_class\::DOD::$name");
}

1;

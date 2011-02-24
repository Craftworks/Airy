package Airy::Web::ActionClass::Pager;

use Airy;

sub setup {
    warn "setup\n";
}

sub before { warn "Pager before\n" }
sub after  { warn "Pager after\n" }

1;

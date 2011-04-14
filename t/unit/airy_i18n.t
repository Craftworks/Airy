use strict;
use warnings;
use utf8;
use Test::More;
use FindBin;
use Cwd;
use ok 'Airy::I18N';

my $i18n = 'MyApp::I18N';
my $locale_dir = Cwd::abs_path("$FindBin::Bin/../locale");

{
    package MyApp;
    use Airy -app;
    package MyApp::I18N;
    use Airy;
    use parent 'Airy::I18N';
    $i18n->config({ 'locale_dir' => $locale_dir });
}

subtest 'find_message_file' => sub {
    my $files_1st = $i18n->find_message_file;
    my $files_2nd = $i18n->find_message_file;
    is_deeply($files_1st, {
        'en' => [ "$locale_dir/en/main.po" ],
        'ja' => [ "$locale_dir/ja/main.po" ],
    }, 'files');
    is_deeply($files_1st, $files_2nd, 'twice');
};

subtest 'parse_message_file' => sub {
    is_deeply($i18n->parse_message_file, {
        'en' => { 'hello, %s %s!' => 'Hello, %s %s!' },
        'ja' => { 'hello, %s %s!' => "こんにちは、%2\$s %1\$s!" },
    });
};

subtest 'default_lang' => sub {
    ok(!$i18n->default_lang, 'still not set');
    is( $i18n->default_lang('en'), 'en', 'set');
    is( $i18n->default_lang, 'en', 'get');
};

subtest 'lang' => sub {
    ok(!$i18n->lang, 'still not set');
    ok(!$Airy::I18N::Lang);
    is( $i18n->lang('en'), 'en', 'set');
    is( $Airy::I18N::Lang, 'en');
    is( $i18n->lang, 'en', 'get');
};

subtest 'loc' => sub {
    my $text = 'hello, %s %s!';
    $i18n->lang('en');
    is($i18n->loc($text, 'Taro', 'Yamada'), 'Hello, Taro Yamada!');
    $i18n->lang('ja');
    is($i18n->loc($text, 'Taro', 'Yamada'), 'こんにちは、Yamada Taro!');
};

done_testing;

# ex:ts=4:sw=4:sts=4:et
use lib qw(lib);
use Test::More;
eval 'use Test::Pod::Coverage;1' or plan skip_all => 'Test::Pod::Coverage required';
all_pod_coverage_ok({ also_private => [ qr/^[A-Z_]+$/ ] });
use strict;
use warnings;

use Log::Contextual::WarnLogger;  # -levels => [qw(custom1 custom2)];
use Log::Contextual qw{:log set_logger} => -logger =>
   Log::Contextual::WarnLogger->new({ env_prefix => 'FOO' });

use Test::More qw(no_plan);
use Test::Fatal;
use Test::Deep;

{
    my $l;
    like(
        exception { $l = Log::Contextual::WarnLogger->new({ levels => '' }) },
        qr/invalid levels specification: must be non-empty arrayref/,
        'cannot pass empty string for levels',
    );

    like(
        exception { $l = Log::Contextual::WarnLogger->new({ levels => [] }) },
        qr/invalid levels specification: must be non-empty arrayref/,
        'cannot pass empty list for levels',
    );

    is(
        exception { $l = Log::Contextual::WarnLogger->new({ levels => undef, env_prefix => 'FOO' }) },
        undef,
        'ok to leave levels undefined',
    );
    cmp_deeply(
        $l,
        noclass({
            levels => [ qw(trace debug info warn error fatal) ],
            _level_num => {
                trace   => 0,
                debug   => 1,
                info    => 2,
                warn    => 3,
                error   => 4,
                fatal   => 5,
            },
            env_prefix => 'FOO',
        }),
        'object is constructed with default levels',
    );
}


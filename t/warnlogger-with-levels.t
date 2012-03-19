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


{
    my $l = Log::Contextual::WarnLogger->new({
        env_prefix => 'BAR',
        levels => [qw(custom1 custom2)]
    });

    cmp_deeply(
        $l,
        noclass({
            levels => [ qw(custom1 custom2) ],
            _level_num => {
                custom1 => 0,
                custom2 => 1,
            },
            env_prefix => 'BAR',
        }),
        'object is constructed with custom levels',
    );

    like(
        exception { Log::Contextual::WarnLogger->custom1 },
        qr/Can't locate object method "custom1" via package "Log::Contextual::WarnLogger"/,
        'methods do not work without a blessed object instance',
    );

    foreach my $sub (qw(is_custom1 is_custom2 custom1 custom2))
    {
        is(
            exception { $l->$sub },
            undef,
            $sub . ' is handled by AUTOLOAD',
        );
    }

    foreach my $sub (qw(is_foo foo))
    {
        like(
            exception { $l->$sub },
            qr/Can't locate object method "$sub" via package "Log::Contextual::WarnLogger"/,
            'arbitrary subs are still rejected',
        );
    }
}

# these tests taken from t/warnlogger.t

my $l = Log::Contextual::WarnLogger->new({
    env_prefix => 'BAR',
    levels => [qw(custom1 custom2)]
});

{
   local $ENV{BAR_CUSTOM1} = 0;
   local $ENV{BAR_CUSTOM2} = 1;
   ok(!$l->is_custom1, 'is_custom1 is false on WarnLogger');
   ok($l->is_custom2, 'is_custom2 is true on WarnLogger');
}

{
   local $ENV{BAR_UPTO} = 'custom1';

   ok($l->is_custom1, 'is_custom1 is true on WarnLogger');
   ok($l->is_custom2, 'is_custom2 is true on WarnLogger');
}

{
   local $ENV{BAR_UPTO} = 'custom2';

   ok(!$l->is_custom1, 'is_custom1 is false on WarnLogger');
   ok($l->is_custom2, 'is_custom2 is true on WarnLogger');
}


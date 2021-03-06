use strict;
use warnings;

use Test::Tester tests => 21;
use Test::More;
use Test::MockObject;

use lib '../..';

use EBox::Global::TestStub;

BEGIN { use_ok ('EBox::Test', ':all') };

EBox::Global::TestStub::fake();

checkModuleInstantiationTest();

sub fakeModules
{
    Test::MockObject->fake_module('EBox::Simple',
            _create => sub {
                my ($class, @params) = @_;

                my $self =  EBox::Module::Config->_create(name => 'simple', @params);
                bless $self, $class;
                return $self;
            }
    );

    Test::MockObject->fake_module('EBox::Unknown',
            _create => sub {
                my ($class, @params) = @_;

                my $self =  $class->SUPER::_create(@params);
                bless $self, $class;
                return $self;
            }
    );

    Test::MockObject->fake_module('EBox::BadCreate',
            _create =>    sub {
                my ($class, @params) = @_;

                my $self = EBox::Module::Config->_create(name => 'badCreate', @params);
                bless $self, 'EBox::Macaco';
                return $self;
            }
    );

    EBox::Global::TestStub::setAllModules(badCreate => 'EBox::BadCreate', simple => 'EBox::Simple') ;
    # setUp ended
}

sub checkModuleInstantiationTest
{
    # cases setUp:
    fakeModules();

    check_test (
            sub { checkModuleInstantiation('simple', 'EBox::Simple');  },
            { ok => 1 },
    );

    # inexistent module
    diag('checkModuleInstantiation for a inexistent module');
    check_test (
            sub { checkModuleInstantiation('inexistent', 'EBox::Inexistent');  },
            { ok => 0 },
    );

    # unknown module
    diag('checkModuleInstantiation for a unknown by EBox::Global module');
    check_test (
            sub {  checkModuleInstantiation('unknown', 'EBox::Unknown');  },
            { ok => 0 },
    );

    # module that loads but  EBox::Global is not aware of it
    diag('checkModuleInstantiation for a unknown module which fails in instatiaton');
    check_test (
            sub { checkModuleInstantiation('badCreate', 'EBox::BadCreate');  },
            { ok => 0 },
    );
}

1;

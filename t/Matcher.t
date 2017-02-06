package ReturnValue;
use strict;
use FindBin;
use lib ($FindBin::Bin);
use parent 'TestBase';
use Test::Mockify::Matcher qw (
        SupportedTypes
        String
        Number
        HashRef
        ArrayRef
        Object
        Function
        Undef
        Any
    );
use Test::More;
use Test::Exception;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->test_String();
    $self->test_Number();
    $self->test_HashRef();
    $self->test_ArrayRef();
    $self->test_Function();
    $self->test_Object();
    $self->test_Undef();
    $self->test_Any();
    return;
}
#------------------------------------------------------------------------
sub test_String {
    my $self = shift;
    is_deeply(String(), {'string' => 'NoExpectedParameter'} , 'proves that the any matcher for string, returns a hash with type and NoExpectedParameter-flag');
    is_deeply(String('abc'), {'string' => 'abc'} , 'proves that the expected matcher for string, returns a hash with type and value');
    is_deeply(String(123), {'string' => '123'} , 'proves that the expected matcher for string, returns a hash with type and value (perl can´t differ between numbers and strings))');
    throws_ok( sub { String(['abc']) },
        qr/NotAString/,
        'proves that the string matcher don´t accept anything else as string'
    );
}
#------------------------------------------------------------------------
sub test_Number {
    my $self = shift;
    is_deeply(Number(), {'number' => 'NoExpectedParameter'} , 'proves that the any matcher for number, returns a hash with type and NoExpectedParameter-flag');
    is_deeply(Number(123), {'number' => 123} , 'proves that the expected matcher for number, returns a hash with type and value');
    is_deeply(Number('123'), {'number' => 123} , 'proves that the expected matcher for number, returns a hash with type and value (perl can´t differ between numbers and strings))');
    is_deeply(Number(1.23), {'number' => 1.23} , 'proves that the expected matcher for number, returns a hash with type and value (also float))');
    throws_ok( sub { Number('abc') },
        qr/NotANumber/,
        'proves that the number matcher don´t accept anything else as numbers'
    );
}
#------------------------------------------------------------------------
sub test_HashRef {
    my $self = shift;
    is_deeply(HashRef(), {'hashref' => 'NoExpectedParameter'} , 'proves that the any matcher for hashref, returns a hash with type and NoExpectedParameter-flag');
    is_deeply(HashRef({'key'=>'value'}), {'hashref' => {'key'=>'value'}} , 'proves that the expected matcher for hashref, returns a hash with type and value');
    throws_ok( sub { HashRef('abc') },
        qr/NotAHashReference/,
        'proves that the hashref matcher don´t accept anything else as hashrefs'
    );
}
#------------------------------------------------------------------------
sub test_ArrayRef {
    my $self = shift;
    is_deeply(ArrayRef(), {'arrayref' => 'NoExpectedParameter'} , 'proves that the any matcher for arrayref, returns a hash with type and NoExpectedParameter-flag');
    is_deeply(ArrayRef(['one','two']), {'arrayref' => ['one','two']} , 'proves that the expected matcher for arrayref, returns a hash with type and value');
    throws_ok( sub { ArrayRef('abc') },
        qr/NotAnArrayReference/,
        'proves that the arrayref matcher don´t accept anything else as arrayrefs'
    );
}
#------------------------------------------------------------------------
sub test_Function {
    my $self = shift;
    is_deeply(Function(), {'sub' => 'NoExpectedParameter'} , 'proves that the any matcher for sub, returns a hash with type and NoExpectedParameter-flag');

}
#------------------------------------------------------------------------
sub test_Object {
    my $self = shift;
    is_deeply(Object(), {'object' => 'NoExpectedParameter'} , 'proves that the any matcher for object, returns a hash with type and NoExpectedParameter-flag');
    is_deeply(Object('Test1::Package'), {'object' => 'Test1::Package'} , 'proves that the expected matcher for object, returns a hash with type and value');
    is_deeply(Object('T3st'), {'object' => 'T3st'} , 'proves that the expected matcher for object, returns a hash with type and value');
    throws_ok( sub { Object('Test::Bla::shfjsdf::sljldfsd::') },
        qr/NotAnModulPath/,
        'proves that the object matcher don´t accept anything else as valid modul pathes'
    );
    throws_ok( sub { Object('Test/Package') },
        qr/NotAnModulPath/,
        'proves that the object matcher don´t accept anything else as modul pathes'
    );
}
#------------------------------------------------------------------------
sub test_Undef {
    my $self = shift;
    is_deeply(Undef(), {'undef' => 'NoExpectedParameter'} , 'proves that the any matcher for undef, returns a hash with type and NoExpectedParameter-flag');
}
#------------------------------------------------------------------------
sub test_Any {
    my $self = shift;
    is_deeply(Any(), {'any' => 'NoExpectedParameter'} , 'proves that the any matcher for any, returns a hash with type and NoExpectedParameter-flag');
}
__PACKAGE__->RunTest();
1;
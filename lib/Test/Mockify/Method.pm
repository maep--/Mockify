package Test::Mockify::Method;
use Test::Mockify::Parameter;
use Data::Dumper;
use Test::Mockify::TypeTests qw (
        IsInteger
        IsFloat
        IsString
        IsArrayReference
        IsHashReference
        IsObjectReference
        IsCodeReference
);
use Test::Mockify::Matcher qw (SupportedTypes);
use Scalar::Util qw( blessed );
use strict;
use warnings;
use Test::Mockify::CompatibilityTools qw (MigrateMatcherFormat);

#---------------------------------------------------------------------
sub new {
    my $Class = shift;
    my $self  = bless {
        'TypeStore'=> undef,
        'MatcherStore'=> undef,
        'AnyStore'=> undef,
    }, $Class;
    foreach my $Type (SupportedTypes()){
        $self->{'MatcherStore'}{$Type} = [];
    }
    return $self;
}
#---------------------------------------------------------------------
sub when {
    my $self = shift;
    my @Parameters = @_;
    my @Signature;
    my @ParameterValues ;
    $self->_testTypeStore();
    foreach my $hParameter ( @Parameters ){
        $hParameter = MigrateMatcherFormat($hParameter);
        push(@ParameterValues, $self->_getParameterValue($hParameter));
        push(@Signature, $self->_getParameterKey($hParameter));
    }
    $self->_checkExpectedParameters(\@Signature, \@ParameterValues);
    return $self->_addToTypeStore(\@Signature, \@ParameterValues);
}
#---------------------------------------------------------------------
sub whenAny {
    my $self = shift;
    die ('"whenAny" don`t allow any parameters' ) if (@_);
    if((scalar keys %{$self->{'TypeStore'}})){
        die('"whenAny" can only used once. Also it is not possible to use a mixture between "when" and "whenAny"');
    }
    return $self->_addToTypeStore(['UsedWithWhenAny']);
}
#---------------------------------------------------------------------
sub _getParameterKey {
    my $self = shift;
    my ($hParameter) = @_;
    my @Keys =  keys %{$hParameter};
    return $Keys[0];
}
#---------------------------------------------------------------------
sub _getParameterValue {
    my $self = shift;
    my ($hParameter) = @_;
    my @Values = values %{$hParameter};
    return $Values[0];
}
#---------------------------------------------------------------------
sub _checkExpectedParameters{
    my $self = shift;
    my ($Signatur, $NewExpectedParameters) = @_;

    for(my $i = 0; $i < scalar @$NewExpectedParameters; $i++){
        my $Type = $Signatur->[$i];
        my $NewExpectedParameter = $NewExpectedParameters->[$i];
        $self->_testMatcherStore($self->{'MatcherStore'}{$Type}->[$i], $NewExpectedParameter);
        $self->{'MatcherStore'}{$Type}->[$i] =  $NewExpectedParameter;
        $self->_testAnyStore($self->{'AnyStore'}->[$i], $Type);
        $self->{'AnyStore'}->[$i] = $Type;
    }

    my $SignaturKey = join('',@$Signatur);
    foreach my $ExistingParameter (@{$self->{'TypeStore'}{$SignaturKey}}){
        if($ExistingParameter->compareExpectedParameters($NewExpectedParameters)){
            die('It is not possible two add two times the same method signatur.');
        }
    }
}
#---------------------------------------------------------------------
sub _testTypeStore {
    my $self = shift;
    foreach my $Signatur (keys %{$self->{'TypeStore'}}){
        if($Signatur eq 'UsedWithWhenAny'){
            die('It is not possible to use a mixture between "when" and "whenAny"');
        }
    }
}
#---------------------------------------------------------------------
sub _testMatcherStore {
    my $self = shift;
    my ($MatcherStore, $NewExpectedParameter) = @_;
    if($NewExpectedParameter eq 'NoExpectedParameter'){
        if($MatcherStore && $MatcherStore ne 'NoExpectedParameter'){
            die('It is not possibel to mix "any parameter" with previously set "expected parameter".');
        }
    } else {
        if($MatcherStore and $MatcherStore eq 'NoExpectedParameter'){
            die('It is not possibel to mix "expected parameter" with previously set "any parameter".');
        }
    }
    return;
}
#---------------------------------------------------------------------
sub _testAnyStore {
    my $self = shift;
    my ($AnyStore, $Type) = @_;
    if($AnyStore){
        if($AnyStore eq 'any' and $Type ne 'any'){
            die('It is not possibel to mix "specific type" with previously set "any type".');
        }
        if($AnyStore ne 'any' and $Type eq 'any'){
            die('It is not possibel to mix "any type" with previously set "specific type".');
        }
    }
    return;
}
#---------------------------------------------------------------------
sub _addToTypeStore {
    my $self = shift;
    my ($Signatur, $NewExpectedParameters) = @_;
    my $SignaturKey = join('',@$Signatur);
    my $Parameter = Test::Mockify::Parameter->new($NewExpectedParameters);
    push(@{$self->{'TypeStore'}{$SignaturKey}}, $Parameter );
    return $Parameter->buildReturn();
}
#---------------------------------------------------------------------
sub call {
    my $self = shift;
    my @Parameters = @_;
    my $SignaturKey = '';
    for(my $i = 0; $i < scalar @Parameters; $i++){
        if($self->{'AnyStore'}->[$i] && $self->{'AnyStore'}->[$i] eq 'any'){
            $SignaturKey .= 'any';
        }else{
            $SignaturKey .= $self->_getType($Parameters[$i]);
        }
    }
    if($self->{'TypeStore'}{'UsedWithWhenAny'}){
        return $self->{'TypeStore'}{'UsedWithWhenAny'}->[0]->call(@Parameters);
    }else {
        foreach my $ExistingParameter (@{$self->{'TypeStore'}{$SignaturKey}}){
            if($ExistingParameter->matchWithExpectedParameters(@Parameters)){
                return $ExistingParameter->call(@Parameters);
            }
        }
    }
    die ("No matching found for $SignaturKey -> ".Dumper(\@Parameters));
}
#---------------------------------------------------------------------
sub _getType{
    my $self = shift;
    my ($Parameter) = @_;
    return 'arrayref' if(IsArrayReference($Parameter));
    return 'hashref' if(IsHashReference($Parameter));
    return 'object' if(IsObjectReference($Parameter));
    return 'sub' if(IsCodeReference($Parameter));
    return 'number' if(IsFloat($Parameter));
    return 'string' if(IsString($Parameter));
    return 'undef' if( not $Parameter);
    die("UnexpectedParameterType for: '$Parameter'");
}

1;